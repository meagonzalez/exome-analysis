#!/bin/bash

#Programs/packages used: Miniconda(conda v24.3.0), FastQC v0.11.9, Trimmomatic v0.39, Sickle v1.33, BWA v0.7.17-r1188, SAMtools v1.12 (using htslib 1.12), XYAlign v1.1.5, GATK v4.5.0.0

#In bash, $1, $2, and so on, represent the files passed to the script. After making sure you have all of the programs/packages needed, to use this pipeline, you'll open your terminal and type "bash nameofthisfile.sh sample_R1.fastq.gz sample_R2.fastq.gz".

#Variables needed so the code can work without any changes for every sample. The "basename" command is used to extract the names of the files, where "file1" is the R1 version of your sample, "file2" is the R2 version and "sample" is the name of your sample.
file1=$(basename "$1" .fastq.gz)
file2=$(basename "$2" .fastq.gz)
sample=$(basename "$1" _R1.fastq.gz)

#The command "echo" will tell you which files are being used by printing them in the terminal. Here you can make sure you selected the right ones.
echo "R1 File: $1"
echo "R2 File: $2"

#Miniconda is a free minimal installer for conda. Conda is a package and environment management system. It was mostly used to solve conflicts between packages and create an environment where all dependencies/libraries coexist without conflict.

#Create the installation directory wherever you'd like with "mkdir miniconda3" and change into that directory with "cd miniconda3"
#Execute "wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" to download the .sh script to make the installation
#Run the bash script with "bash Miniconda3-latest-Linux-x86_64.sh -p ~/miniconda3"
#Restart your Terminal. Now your prompt should list which environment is active (in this case "base")

#To perform a quality check on the fastq.gz files, we'll be using FastQC. To install it run "sudo apt-get install fastqc"

#By typing fastqc filename.fastq.gz a .html will be generated into the root directory with a report on the file
fastqc $file1.fastq.gz
fastqc $file2.fastq.gz

#Trimmomatic is used to trim and clip the adapters in exome files. 
#To download it either visit https://github.com/usadellab/Trimmomatic/files/5854859/Trimmomatic-0.39.zip to get the 0.39 version or run "wget https://github.com/usadellab/Trimmomatic/files/5854859/Trimmomatic-0.39.zip". After that unpack it somewhere convenient.

#Trimmomatic needs the R1 and R2 files as input and will create 4 other files with the paired and unpaired reads of those forward and reverse files.

#Remove leading low quality or N bases (below quality 3) (LEADING:3)
#Remove trailing low quality or N bases (below quality 3) (TRAILING:3)
#Scan the read with a 4-base wide sliding window, cutting when the average quality per base drops below 15 (SLIDINGWINDOW:4:15)
#Drop reads below the 36 bases long (MINLEN:36)

java -jar ../Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 6 $file1.fastq.gz $file2.fastq.gz ${file1}_paired.fastq.gz ${file1}_unpaired.fastq.gz ${file2}_paired.fastq.gz ${file2}_unpaired.fastq.gz LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

#Sickle is a tool that uses sliding windows along with quality and length thresholds to determine when quality is sufficiently low to trim or discard reads.
#To install it first clone sickle's github repository wherever you find it conveninent with "git clone https://github.com/najoshi/sickle"
#Change into that directory with "cd sickle" and build sickle with "make"
#Then, copy or move "sickle" to a directory in your $PATH using something like "sudo mv sickle /usr/bin"

#Sickle Paired End (sickle pe)
#-f, --pe-file1, Input paired-end forward fastq file (Input files must have same number of records)
#-r, --pe-file2, Input paired-end reverse fastq file
#-o, --output-pe1, Output trimmed forward fastq file
#-p, --output-pe2, Output trimmed reverse fastq file. Must use -s option.
#-s, --output-single, Output trimmed singles fastq file
#-t, --qual-type, Type of quality values (solexa (CASAVA < 1.3), illumina (CASAVA 1.3 to 1.7), sanger (which is CASAVA >= 1.8)) (required)
#-q, --qual-threshold, Threshold for trimming based on average quality in a window. Default 20.
#-l, --length-threshold, Threshold to keep a read based on length after trimming. Default 20.
#-g, --gzip-output, Output gzipped files.

sickle pe -f ${file1}_paired.fastq.gz -r ${file2}_paired.fastq.gz -o ${file1}_trimmed.fastq.gz -p ${file2}_trimmed.fastq.gz -s ${sample}_trimmed_singles.fastq.gz -t sanger -q 20 -l 50 -g

#BWA is a software package for mapping DNA sequences against a large reference genome, such as the human genome. To install it first clone the repository with "git clone https://github.com/lh3/bwa.git", open it with "cd bwa" and then build it with "make".

#To download the reference genome run "wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta"
#The .fai that corresponds to the .fasta is also needed: "wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.fai"

#wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta / wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.fai

#You can either run "bwa index -a bwtsw Homo_sapiens_assembly38.fasta" (with "-a" signalling that we want a BWT construction algorithm) or download the indexing files yourself instead of making them. (AMB, ANN, BWT, PAC, and SA files)

#wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.amb
#wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.ann
#wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.bwt
#wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.pac
#wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.sa

#wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.amb / wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.ann / wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.bwt / wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.pac / wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.sa

#BWA-MEM is the latest Burrows-Wheeler Aligner and is generally recommended as it is faster, more accurate and has better performance than the other BWA versions.
#-M            mark shorter split hits as secondary
#-t INT        number of threads [1]

bwa mem -M -t 6 ../bwa/Homo_sapiens_assembly38.fasta ${file1}_trimmed.fastq.gz ${file2}_trimmed.fastq.gz > ${sample}_aligned.bam

#SAMtools is a library and software package for parsing and manipulating alignments in the Binary Alignment/Map (BAM) or in the Sequence Alignment/Map (SAM) format. It's commonly used to sort the standard BAM format emitted by many sequence aligners which, in this case, is BWA. To install it run "sudo apt-get install samtools".

#-@ number of additional threads to use
#-o write final output to FILE rather than standard output

samtools sort -@ 6 ${sample}_aligned.bam -o ${sample}_aligned_sorted.bam

#To avoid the misalignment of sequencing reads and to assure variant calling will work properly, we'll use a tool that corrects erroneous read mapping on the sex chromosomes called XYAlign. Firstly add the necessary channels to conda with "conda config --add channels defaults", "conda config --add channels conda-forge" and "conda config --add channels bioconda". Then, create a conda environment to install XYAlign with "conda create -n xyalign_env xyalign".

#Activate the environment. (You can deactivate conda with "conda deactivate" and activate it with "conda activate")
source activate xyalign_env

#Test if XYAlign is working by typing "xyalign" in the terminal. In case you get an import error with libhts.so.2 while it's trying to run pysam, execute "conda update pysam" and several packages will be downgraded so they can properly work together.

#Preparing the reference file
xyalign --PREPARE_REFERENCE --ref ../bwa/Homo_sapiens_assembly38.fasta --x_chromosome chrX --y_chromosome chrY --output_dir xyalign

#Characterizing the sex chromossomes using 6 cpu cores and 8kb nonoverlapping windows for analysis.
xyalign --CHARACTERIZE_SEX_CHROMS --ref ../bwa/Homo_sapiens_assembly38.fasta --bam ${sample}_aligned_sorted.bam --output_dir xyalign_analysis --sample_id $sample --cpus 6 --window_size 8000 --chromosomes chrX chrY --x_chromosome chrX --y_chromosome chrY

#Sets the user limit of open files to 50000
ulimit -n 50000

#Installs platypus-variant (package needed for remapping to work)
#conda install platypus-variant

#Remapping
xyalign --REMAPPING --ref ../bwa/Homo_sapiens_assembly38.fasta --bam ${sample}_aligned_sorted.bam --output_dir xyalign_output --sample_id $sample --cpus 6 --chromosomes chrX chrY --x_chromosome chrX --y_chromosome chrY --xx_ref_in xyalign/reference/xyalign_noY.masked.fa --xy_ref_in xyalign/reference/xyalign_withY.masked.fa --y_absent

#GATK (Genome Analysis Toolkit) is "a collection of command-line tools for analyzing high-throughput sequencing data with a primary focus on variant discovery" as their website states. To get the 4.5.0.0 version run "wget https://github.com/broadinstitute/gatk/releases/download/4.5.0.0/gatk-4.5.0.0.zip" in the folder of your preference. After unzipping it, go to your home folder and press Ctrl+H so the hidden files appear. Then, look for a file named ".bashrc"(short for bash read command), which is a configuration file for the Bash shell environment. In the end of that file write "alias gatk='/path/to/gatk-package/gatk'", I had to write “alias gatk='/dados/megonzalez/gatk-4.5.0.0/gatk'”.

