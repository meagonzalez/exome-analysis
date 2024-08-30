#!/bin/bash

#Comments are wrriten like "EN-US/PT-BR"/Comentários foram escritos da forma "EN-US/PT-BR"

#Directory containing your exome files (modify this if you want to use it)/Diretório contendos os arquivos de exoma (modifique se você quiser usar)
#exome_dir="../Teste"

#Script you want to run on each exome sample (modify this if your file is called something else)/Script que será rodado em cada amostra (modifique se o seu arquivo tiver outro nome)
script="../exome_analysis_final.sh"

#Creates the directory where the BWA files will be stored and enters that directory/Cria um diretório para armazenar os arquivos do BWA
mkdir bwa
cd bwa

#Reference Genome download/Download do Genoma de Referência
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta 
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.fai
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.dict

#BWA files download/Download dos arquivos do BWA
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.amb
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.ann
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.bwt
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.pac
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.sa

#Leaves BWA directory/Sai do diretório do BWA
cd ..

#Creates a directory to store the databases and enters that directory/Cria um diretório para armazenar as bases de dados e entra nesse diretório
mkdir known_sites
cd known_sites

#Downloads known sites of variation/Download das bases de dados
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.known_indels.vcf.gz
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/hapmap_3.3.hg38.vcf.gz
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/1000G_omni2.5.hg38.vcf.gz
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/1000G_phase1.snps.high_confidence.hg38.vcf.gz
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz

#Downloads indexes of known sites of variation/Download da indexação das bases de dados
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf.idx
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.known_indels.vcf.gz.tbi
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/hapmap_3.3.hg38.vcf.gz.tbi
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/1000G_omni2.5.hg38.vcf.gz.tbi
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz.tbi

#Leaves the directory/Sai do diretório
cd ..

#Creates a folder to store the vcf files/Cria um diretório para armazenar os arquivos vcf
mkdir vcfs

#Loops through all files in the directory/Loop com comandos que será rodado em todos os arquivos do diretório
for R1 in * ; do

  #Check to make sure the R1 file is a regular file and ends with "_R1.fastq.gz" (modify extension if needed)/Checa se o arquivo R1 é um arquivo normal e termina com "_R1.fastq.gz"
  if [[ -f "$R1" && "$R1" =~ _R1\.fastq\.gz$ ]] ; then
    
    #Extract the name of the sample without extension/Extrai o nome do arquivo sem a extensão
    sample=$(basename "$R1" _R1.fastq.gz)
    
    #Prints the name of the sample to be processed/Imprime o nome da amostra que será processada
    echo "Sample: $sample"
    
    #Searches for R2 by assuming R2 file has the same sample name as the R1 file but with "_R2" appended instead/Pesquisa pelo arquivo R2 assumindo que o arquivo tem o nome da amostra com "_R2.fastq.gz" adicionado
    R2="$sample""_R2.fastq.gz"

    #Check if R2 file exists/Checa se o arquivo R2 existe
    if [[ -f "$R2" ]] ; then
    
      #Creates a directory for the sample being processed and moves the sample files there/Cria um diretório para a amostra sendo processada e passa os arquivos dela pra lá
      mkdir "$sample" && mv "$R1" "$R2" "$sample"/
      
      #Enters that directory/Entra nesse diretório
      cd "$sample"
      
      #Runs the script with R1 and R2 files as arguments/Roda o script com os argumentos sendo os arquivos R1 e R2
      bash "$script" "$R1" "$R2"
      
      #Prints message saying the script finished running current sample/Imprime uma mensagem dizendo que terminou de rodar a amostra
      echo "Processed: $R1 and $R2"
      
      #Leaves sample directory before process restarts/Sai do diretório antes que o processo recomece
      cd ..
      
    #In case code doesn't find the R2 file/Caso o código não encontre o arquivo R2
    else
    
      #Prints error message/Imprime mensagem de erro
      echo "Error: R2 file not found: $R2"
    fi
  fi
done
