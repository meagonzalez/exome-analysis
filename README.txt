EN-US

Programs/packages used: FastQC v0.11.9, Trimmomatic v0.39, Sickle v1.33, BWA v0.7.17-r1188, SAMtools v1.12 (using htslib 1.12), GATK v4.5.0.0

To perform a quality check on the fastq.gz files, we'll be using FastQC. To install it run "sudo apt-get install fastqc"

Trimmomatic is used to trim and clip the adapters in exome files. To download it either visit https://github.com/usadellab/Trimmomatic/files/5854859/Trimmomatic-0.39.zip to get the 0.39 version or run "wget https://github.com/usadellab/Trimmomatic/files/5854859/Trimmomatic-0.39.zip". After that unpack it in the same folder the script and the samples are.

Sickle is a tool that uses sliding windows along with quality and length thresholds to determine when quality is sufficiently low to trim or discard reads. To install it first clone sickle's github repository wherever you find it conveninent with "git clone https://github.com/najoshi/sickle". Change into that directory with "cd sickle" and build sickle with "make". Then, copy or move "sickle" to a directory in your $PATH using something like "sudo mv sickle /usr/bin"

BWA is a software package for mapping DNA sequences against a large reference genome, such as the human genome. To install it first clone the repository with "git clone https://github.com/lh3/bwa.git", open it with "cd bwa" and then build it with "make".

SAMtools is a library and software package for parsing and manipulating alignments in the Binary Alignment/Map (BAM) or in the Sequence Alignment/Map (SAM) format. It's commonly used to sort the standard BAM format emitted by many sequence aligners which, in this case, is BWA. To install it run "sudo apt-get install samtools".

GATK (Genome Analysis Toolkit) is "a collection of command-line tools for analyzing high-throughput sequencing data with a primary focus on variant discovery" as their website states. To get the 4.5.0.0 version run "wget https://github.com/broadinstitute/gatk/releases/download/4.5.0.0/gatk-4.5.0.0.zip" in the folder of your preference. Open the script called "exome_analysis_final.sh" and edit the path at the beggining "export PATH="$PATH:/dados/giudicelligc/gatk-4.5.0.0/"" to where you put the unzipped GATK folder.

Make sure your directory looks like this and run "bash exome_loop_updated.sh"

└── samples/
    ├── Trimmomatic-0.39/
    |	└──Trimmomatic Files
    ├── exome_analysis_final.sh
    ├── exome_loop_updated.sh
    ├── sample1_R1.fastq.gz
    ├── sample1_R2.fastq.gz
    ├── sample2_R1.fastq.gz
    └── sample2_R2.fastq.gz

By the end of the program your directory should look like this:

└── samples/
    ├── Trimmomatic-0.39/
    |	└──Trimmomatic Files
    ├── bwa/
    |	├── Reference Genome
    |   ├── Reference Genome indexing and dictionary files
    |   └── BWA files (.AMB, .ANN, .BWT, .PAC, .SA)
    ├── known_sites/
    |	└── Databases
    ├── exome_analysis_final.sh
    ├── exome_loop_updated.sh
    ├── sample1/
    |	├── gatk/
    |   |   └──GATK Files
    |   ├── sample1_R1.fastq.gz
    |   ├── sample1_R2.fastq.gz
    |   └── Files ending in .bam, .bai, etc
    ├── samples2/
    |	├── gatk/
    |   |   └──GATK Files
    |   ├── sample2_R1.fastq.gz
    |   ├── sample2_R2.fastq.gz
    |   └── Files ending in .bam, .bai, etc
    └── vcfs/
    	└──Final .vcf files of all samples


PT-BR

Programas/pacotes usados: FastQC v0.11.9, Trimmomatic v0.39, Sickle v1.33, BWA v0.7.17-r1188, SAMtools v1.12 (usando htslib 1.12), GATK v4.5.0.0

Para realizar uma verificação de qualidade nos arquivos fastq.gz, usaremos FastQC. Para instalá-lo, execute "sudo apt-get install fastqc"

Trimmomatic é usado para cortar e recortar os adaptadores em arquivos exoma. Para baixá-lo, visite https://github.com/usadellab/Trimmomatic/files/5854859/Trimmomatic-0.39.zip para obter a versão 0.39 ou execute "wget ​​https://github.com/usadellab/Trimmomatic/files/5854859 /Trimmomatic-0.39.zip". Depois descompacte-o na mesma pasta que estão o script e as amostras.

Sickle é uma ferramenta que usa janelas deslizantes junto com limites de qualidade e comprimento para determinar quando a qualidade é suficientemente baixa para cortar ou descartar leituras. Para instalá-lo, primeiro clone o repositório github do Sickle onde achar conveniente com "git clone https://github.com/najoshi/sickle". Mude para esse diretório com "cd foice" e construa o Sickle com "make". Em seguida, copie ou mova "sickle" para um diretório em seu $PATH usando algo como "sudo mv sickle /usr/bin"

BWA é um pacote de software para mapear sequências de DNA em um grande genoma de referência, como o genoma humano. Para instalá-lo, primeiro clone o repositório com "git clone https://github.com/lh3/bwa.git", abra-o com "cd bwa" e depois construa-o com "make".

SAMtools é uma biblioteca e pacote de software para analisar e manipular alinhamentos no formato Binary Alignment/Map (BAM) ou no formato Sequence Alignment/Map (SAM). É comumente usado para classificar o formato BAM padrão emitido por muitos alinhadores de sequência que, neste caso, é BWA. Para instalá-lo, execute "sudo apt-get install samtools".

GATK (Genome Analysis Toolkit) é “uma coleção de ferramentas de linha de comando para analisar dados de sequenciamento de alto rendimento com foco principal na descoberta de variantes”, como afirma seu site. Para obter a versão 4.5.0.0 execute "wget ​​https://github.com/broadinstitute/gatk/releases/download/4.5.0.0/gatk-4.5.0.0.zip" na pasta de sua preferência. Abra o script chamado "exome_analysis_final.sh" e edite o caminho no início "export PATH="$PATH:/dados/giudicelligc/gatk-4.5.0.0/"" para onde você colocou a pasta GATK descompactada.

Se certifique que seu diretório esteja nesse estilo e rode "bash exome_loop_updated.sh"

└── amostras/
    ├── Trimmomatic-0.39/
    |	└──arquivos gerados pelo Trimmomatic
    ├── exome_analysis_final.sh
    ├── exome_loop_updated.sh
    ├── amostra1_R1.fastq.gz
    ├── amostra1_R2.fastq.gz
    ├── amostra2_R1.fastq.gz
    └── amostra2_R2.fastq.gz
    
Ao final do programa é esperado que o diretório fique assim:

└── amostras/
    ├── Trimmomatic-0.39/
    |	└──Arquivos gerados pelo Trimmomatic
    ├── bwa/
    |	├── Genoma de Referência
    |   ├── Arquivo de indexação e dicionário do Genoma de Referência
    |   └── Arquivos gerados pelo BWA (.AMB, .ANN, .BWT, .PAC, .SA)
    ├── known_sites/
    |	└── Bases de Dados
    ├── exome_analysis_final.sh
    ├── exome_loop_updated.sh
    ├── amostra1/
    |	├── gatk/
    |   |   └──Arquivos gerados pelo gatk
    |   ├── amostra1_R1.fastq.gz
    |   ├── amostra1_R2.fastq.gz
    |   └── Arquivos .bam, .bai, etc
    ├── amostra2/
    |	├── gatk/
    |   |   └──Arquivos gerados pelo gatk
    |   ├── amostra2_R1.fastq.gz
    |   ├── amostra2_R2.fastq.gz
    |   └── Arquivos .bam, .bai, etc
    └── vcfs/
    	└──Arquivos .vcf finais de todas as amostras 
