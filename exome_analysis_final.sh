#!/bin/bash

#Comments are written like "EN-US/PT-BR"/Comentários foram escritos da forma "EN-US/PT-BR"

#Stating where GATK is stored/Identificando a localização do GATK
export PATH="$PATH:/dados/giudicelligc/gatk-4.5.0.0/"

#Setting up variables to store the R1 and R2 files as well as the name of the sample/Configurando variáveis para armazenar os arquivos R1 e R2, além do nome da amostra
file1=$(basename "$1" .fastq.gz)
file2=$(basename "$2" .fastq.gz)
sample=$(basename "$1" _R1.fastq.gz)

#Prints the R1 and R2 file so we can make sure it grabbed the right files/Imprime os arquivos R1 e R2 para termos certeza que ele pegou os arquivos certos
echo "R1 File: $1"
echo "R2 File: $2"

#Quality check/Faz o teste de qualidade
fastqc $file1.fastq.gz
fastqc $file2.fastq.gz

#Trimms the adapters/Remove os adaptadores
java -jar ../Trimmomatic-0.39/trimmomatic-0.39.jar \
  PE \
  -threads 6 \
  $file1.fastq.gz \
  $file2.fastq.gz \
  ${file1}_paired.fastq.gz \
  ${file1}_unpaired.fastq.gz \
  ${file2}_paired.fastq.gz \
  ${file2}_unpaired.fastq.gz \
  LEADING:3 \
  TRAILING:3 \
  SLIDINGWINDOW:4:15 \
  MINLEN:36

#Cleans the data/Limpa os dados
sickle \
  pe \
  -f ${file1}_paired.fastq.gz \
  -r ${file2}_paired.fastq.gz \
  -o ${file1}_trimmed.fastq.gz \
  -p ${file2}_trimmed.fastq.gz \
  -s ${sample}_trimmed_singles.fastq.gz \
  -t sanger \
  -q 20 \
  -l 50 \
  -g

#Setting up variables to grab the information we'll insert on the sample tag/Configurando variáveis para armazenar as infomações que serão inseridas na tag da amostra  
flowcell_id=$(zcat $1 | sed -n '1p' | cut -d ':' -f 3)
flowcell_lane=$(zcat $1 | sed -n '1p' | cut -d ':' -f 4)
run_id=$(zcat $1 | sed -n '1p' | cut -d ':' -f 2)

#Prints the information stored in the variables/Imprime as informações das variáveis
echo "RGID: ${flowcell_id}.${flowcell_lane}"
echo "RGPU: unit${run_id}"

#Alligment/Alinhamento
bwa mem -M -t 6 -R "@RG\tID:${flowcell_id}.${flowcell_lane}\tSM:$sample\tPL:ILLUMINA\tLB:unknown_library\tPU:unit${run_id}" ../bwa/Homo_sapiens_assembly38.fasta ${file1}_trimmed.fastq.gz ${file2}_trimmed.fastq.gz > ${sample}_aligned.bam

#Prints the sample tag/Imprime a tag da amostra
echo "Tag: $(samtools view -H ${sample}_aligned.bam | grep @RG)"

#Sorting/Ordenação
samtools sort -@ 6 ${sample}_aligned.bam -o ${sample}_aligned_sorted.bam

#Creates an index file/Cria um arquivo de índice
samtools index -@ 6 ${sample}_aligned_sorted.bam

#Creates and enters a directory to store files made by GATK/Cria e entra um diretório para armazenar os arquivos feitos pelo GATK
mkdir gatk
cd gatk

#Marks the duplicates/Marca as duplicatas 
gatk MarkDuplicates \
  -I ../${sample}_aligned_sorted.bam \
  --REMOVE_DUPLICATES true \
  -O ${sample}_sorted_dedup.bam \
  -M ${sample}_dedup_metrics.txt
  
#Validates the file/Valida o arquivo 
gatk ValidateSamFile \
  I=${sample}_sorted_dedup.bam \
  O=${sample}.validate.txt \
  MODE=SUMMARY
 
#Got tired of writing this path so I put it inside a variable/Cansei de escrever os caminhos e enfiei tudo dentro de variáveis
reference="../../bwa/Homo_sapiens_assembly38.fasta"

#The Single Nucleotide Polymorphism Database
dbsnp="../../known_sites/Homo_sapiens_assembly38.dbsnp138.vcf"

#Known INDELs
known_indels="../../known_sites/Homo_sapiens_assembly38.known_indels.vcf.gz"

#International HapMap Project
hapmap="../../known_sites/hapmap_3.3.hg38.vcf.gz"

#1000 Genomes Project
omni="../../known_sites/1000G_omni2.5.hg38.vcf.gz"

thousandG="../../known_sites/1000G_phase1.snps.high_confidence.hg38.vcf.gz"

#No clue where these two came from
mills="../../known_sites/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz"

axiomPoly="../../known_sites/Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz"

#Generates a recalibration table based on various covariates. The default covariates are read group, reported quality score, machine cycle, and nucleotide context/Gera uma tabela de recalibração com base em diversas covariáveis. As covariáveis ​​padrão são grupo de leitura, índice de qualidade relatado, ciclo de máquina e contexto de nucleotídeo
gatk BaseRecalibrator \
  -I ${sample}_sorted_dedup.bam \
  -R $reference \
  --known-sites $dbsnp \
  --known-sites $known_indels \
  --known-sites $hapmap \
  --known-sites $omni \
  --known-sites $thousandG \
  --known-sites $mills \
  --known-sites $axiomPoly \
  -O ${sample}_recalibration.table
  
#BQSR stands for Base Quality Score Recalibration, this line applies the table we just created with our chosen known sites of variation/BQSR significa Base Quality Score Recalibration, esta linha aplica a tabela que acabamos de criar com as bases de dados escolhidas
gatk ApplyBQSR \
  -I ${sample}_sorted_dedup.bam \
  -R $reference \
  --bqsr-recal-file ${sample}_recalibration.table \
  -O ${sample}_recalibratedreads.bam

#Produces a summary of alignment metrics from a SAM or BAM file. This tool takes a SAM/BAM file input and produces metrics detailing the quality of the read alignments as well as the proportion of the reads that passed machine signal-to-noise threshold quality filters/Produz um resumo das métricas de alinhamento de um arquivo SAM ou BAM. Essa ferramenta recebe uma entrada de arquivo SAM/BAM e produz métricas detalhando a qualidade dos alinhamentos de leitura, bem como a proporção de leituras que passaram pelos filtros de qualidade de limite de sinal-ruído da máquina.
gatk CollectAlignmentSummaryMetrics \
  R=$reference \
  I=${sample}_recalibratedreads.bam \
  O=${sample}_recalibratedreads_alignmentsummary_metrics.txt

#This tool provides useful metrics for validating library construction including the insert size distribution and read orientation of paired-end libraries/Esta ferramenta fornece métricas úteis para validar a construção de bibliotecas, incluindo a distribuição de tamanho de inserção e orientação de leitura de bibliotecas emparelhadas.
gatk CollectInsertSizeMetrics \
  INPUT=${sample}_recalibratedreads.bam \
  OUTPUT=${sample}_recalibratedreads_insertsize_metrics.txt \
  HISTOGRAM_FILE=${sample}_recalibratedreads_insertsize_metrics.pdf

#Does a full pass through the input file to calculate and print statistics/Faz uma passagem completa pelo arquivo de entrada para calcular e imprimir estatísticas
samtools flagstat \
  ${sample}_recalibratedreads.bam > \
  ${sample}_recalibratedreads_flagstat.txt

#Outputs an histogram showing the average coverage in each chromossome/Produz um histograma mostrando a cobertura média em cada cromossomo
samtools coverage \
  -m \
  -o ${sample}_recalibratedreads_coverage.txt \
  ${sample}_recalibratedreads.bam

#Calls germline SNPs and INDELs via local re-assembly of haplotypes (calls DNA variants)/Chama SNPs e INDELs da linha germinativa por meio de remontagem local de haplótipos (chama variantes de DNA)
gatk --java-options "-Xmx6g -XX:ParallelGCThreads=6" HaplotypeCaller -R $reference -I ${sample}_recalibratedreads.bam -O ${sample}_rawvariants.vcf

#gatk GenotypeGVCFs \
#  -R $reference \
#  -V ${sample}_rawvariants.vcf \
#  -O ${sample}_rawvariants.vcf

#Selects the SNPs/Seleciona as SNPs
gatk SelectVariants -R $reference -V ${sample}_rawvariants.vcf --select-type SNP -O ${sample}_rawvariants_snps.vcf

#Selects the INDELs/Seleciona os INDELs
gatk SelectVariants -R $reference -V ${sample}_rawvariants.vcf --select-type INDEL -O ${sample}_rawvariants_indels.vcf

#gatk MakeSitesOnlyVcf \
#  -I ${sample}_rawvariants.vcf \
#  -O ${sample}_sitesonly.vcf

#Builds a recalibration model to score variant quality for filtering purposes/Cria um modelo de recalibração para pontuar a qualidade da variante para fins de filtragem
gatk --java-options "-Xmx6g -XX:ParallelGCThreads=6" VariantRecalibrator \
  -V ${sample}_rawvariants_snps.vcf \
  --trust-all-polymorphic \
  -tranche 100.0 -tranche 99.95 -tranche 99.9 -tranche 99.8 -tranche 99.6 \
  -tranche 99.5 -tranche 99.4 -tranche 99.3 -tranche 99.0 -tranche 98.0 \
  -tranche 97.0 -tranche 90.0 \
  -an QD -an MQRankSum -an ReadPosRankSum -an FS -an MQ -an SOR -an DP \
  -mode SNP \
  --max-gaussians 6 \
  -resource:hapmap,known=false,training=true,truth=true,prior=15 $hapmap \
  -resource:omni,known=false,training=true,truth=true,prior=12 $omni \
  -resource:1000G,known=false,training=true,truth=false,prior=10 $thousandG \
  -resource:dbsnp,known=true,training=false,truth=false,prior=7 $dbsnp \
  -O ${sample}_recalibrationmodel_snps.recal \
  --tranches-file ${sample}_recalibrationmodel_snps.tranches

#Applies that recalibration model/Aplica esse modelo de recalibração  
gatk ApplyVQSR \
  -R $reference \
  -V ${sample}_rawvariants_snps.vcf \
  --truth-sensitivity-filter-level 99.0 \
  --tranches-file ${sample}_recalibrationmodel_snps.tranches \
  --recal-file ${sample}_recalibrationmodel_snps.recal \
  -mode SNP \
  -O ${sample}_evaluated_snps.vcf #apply model

#Filters variant calls based on INFO and/or FORMAT annotations/Filtra chamadas de variantes com base em anotações INFO e/ou FORMAT
gatk VariantFiltration \
  -R $reference \
  -V ${sample}_evaluated_snps.vcf \
  --filter-expression "DP < 10.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || QD < 2.0 || ReadPosRankSum < -8.0" \
  --filter-name "SNPFilter" \
  -O ${sample}_evaluated_snps.filtered.vcf

#Builds a recalibration model to score variant quality for filtering purposes/Cria um modelo de recalibração para pontuar a qualidade da variante para fins de filtragem
gatk --java-options "-Xmx24g -XX:ParallelGCThreads=6" VariantRecalibrator \
  -V ${sample}_rawvariants_indels.vcf \
  --trust-all-polymorphic \
  -tranche 100.0 -tranche 99.95 -tranche 99.9 -tranche 99.5 -tranche 99.0 \
  -tranche 97.0 -tranche 96.0 -tranche 95.0 -tranche 94.0 -tranche 93.5 \
  -tranche 93.0 -tranche 92.0 -tranche 91.0 -tranche 90.0 \
  -an FS -an ReadPosRankSum -an MQRankSum -an QD -an SOR -an DP \
  -mode INDEL \
  --max-gaussians 4 \
  -resource:mills,known=false,training=true,truth=true,prior=12 $mills \
  -resource:axiomPoly,known=false,training=true,truth=false,prior=10 $axiomPoly \
  -resource:dbsnp,known=true,training=false,truth=false,prior=2 $dbsnp \
  -O ${sample}_recalibrationmodel_indels.recal \
  --tranches-file ${sample}_recalibrationmodel_indels.tranches

#Applies that recalibration model/Aplica esse modelo de recalibração 	
gatk ApplyVQSR \
  -R $reference \
  -V ${sample}_rawvariants_indels.vcf \
  --truth-sensitivity-filter-level 99.0 \
  --tranches-file ${sample}_recalibrationmodel_indels.tranches \
  --recal-file ${sample}_recalibrationmodel_indels.recal \
  -mode INDEL \
  -O ${sample}_evaluated_indels.vcf
	
#Filters variant calls based on INFO and/or FORMAT annotations/Filtra chamadas de variantes com base em anotações INFO e/ou FORMAT
gatk VariantFiltration \
  -R $reference \
  -V ${sample}_evaluated_indels.vcf \
  --filter-expression "DP < 10.0 || FS > 200.0 || QD < 2.0 || ReadPosRankSum < -20.0 || SOR > 10.0" \
  --filter-name "IndelFilter" \
  -O ${sample}_evaluated_indels.filtered.vcf

#Combines outputs/Combina os outpus
gatk MergeVcfs \
  -I ${sample}_evaluated_snps.filtered.vcf \
  -I ${sample}_evaluated_indels.filtered.vcf \
  -O ${sample}_mergedvariants.vcf

#Removes the variants that failed the requested tranche cutoff and were marked as filtered in the VQSR (Variant Quality Score Recalibration) step/Remove as variantes que falharam no corte da parcela solicitada e foram marcadas como filtradas na etapa VQSR (Variant Quality Score Recalibration)
gatk SelectVariants --exclude-filtered -V ${sample}_mergedvariants.vcf -O ${sample}_mergedvariants_filtered.vcf

#Leaves the GATK directory and the sample one/Sai do diretório do GATK e do da amostra
cd ../..

#Enters the directory where we'll store the vcfs/Entra no diretório que iremos armazenar os vcfs
cd vcfs

#Removes highly polimorphic regions/Remove regiões altamente polimórficas
grep -vE '^chr([1-9]|1[0-9]|2[0-2]|X|Y|Un)_|^HLA-DRB1' ../$sample/gatk/${sample}_mergedvariants_filtered.vcf > $sample.vcf
