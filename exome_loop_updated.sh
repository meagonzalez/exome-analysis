#!/bin/bash

#Directory containing your exome files (modify this if you want to use it)
#exome_dir="../Teste"

#Script you want to run on each exome sample (modify this if your file is called something else)
script="../everything with interpolation.sh"

#Creates the directory where the BWA files will be stored and enters that directory
mkdir bwa && cd bwa

#Reference Genome download
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta / wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.fai

#BWA files download
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.amb / wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.ann / wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.bwt / wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.pac / wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.sa

#Leaves BWA directory
cd ..

#Loop through all files in the directory
for R1 in * ; do

  #Check to make sure the R1 file is a regular file and ends with "_R1.fastq.gz" (modify extension if needed)
  if [[ -f "$R1" && "$R1" =~ _R1\.fastq\.gz$ ]] ; then
    
    # Extract the name of the sample without extension
    sample=$(basename "$R1" _R1.fastq.gz)
    
    #Prints the name of the sample to be processed
    echo "Sample: $sample"
    
    #Searches for R2 by assuming R2 file has the same sample name as the R1 file but with "_R2" appended instead
    R2="$sample""_R2.fastq.gz"

    #Check if R2 file exists
    if [[ -f "$R2" ]] ; then
    
      #Creates a directory for the sample being processed and moves the sample files there
      mkdir "$sample" && mv "$R1" "$R2" "$sample"/
      
      #Enters that directory
      cd "$sample"
      
      #Runs the script with R1 and R2 files as arguments
      bash "$script" "$R1" "$R2"
      
      #Prints message saying the script finished running current sample
      echo "Processed: $R1 and $R2"
      
      #Leaves sample directory before process restarts
      cd ..
      
    #In case code doesn't find the R2 file  
    else
    
      #Prints error message
      echo "Error: R2 file not found: $R2"
    fi
  fi
done

