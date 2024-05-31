#!/bin/bash
conda create --name task4	# Creating conda environment
conda activate task4	# Activating conda environment
conda install -c bioconda -c conda-forge entrez-direct sra-tools fastqc trimmomatic	# Installing utilities
conda install -c bioconda quast	# Installing quast for quality checking
spades pigz -y	# Installing utilities
sudo apt install spades	# Installing spades for genome assembly
mkdir task_4	# Creating a directory for the exercise
mkdir task_4/raw_data	# Creating a directory for the raw data
fastq-dump -O task_4/raw_data --dumpbase --split-files --readids -Q 33 --defline-qual '+' --defline-seq '@$ac_$sn[_$rn]/$ri' SRR20215132	# Extracting the required sequences
pigz -9f task_4/raw_data/*.fastq	# Compressing the extracted sequence files
mkdir ~/task_4/raw_qa	# Creating a directory for quality control (QC) step
fastqc --threads 2 --outdir task_4/raw_qa task_4/raw_data/SRR20215132_1.fastq.gz task_4/raw_data/SRR20215132_2.fastq.gz	# Performing quality check using FastQC
google-chrome task_4/raw_qa/*.html	# Picturing the QC graphs on Google Chrome
mkdir task_4/trim	# Creating directory for trimming step
trimmomatic PE -phred33 task_4/raw_data/SRR20215132_1.fastq.gz task_4/raw_data/SRR20215132_2.fastq.gz task_4/trim/r1.paired.fq.gz task_4/trim/r1_unpaired.fq.gz task_4/trim/r2.paired.fq.gz task_4/trim/r2_unpaired.fq.gz SLIDINGWINDOW:5:30 AVGQUAL:30	# Trimming the reads using Trimmomatic
cat task_4/trim/r1_unpaired.fq.gz ~/task_4/trim/r2_unpaired.fq.gz > task_4/trim/singletons.fq.gz	# Extracting singletons
rm -v task_4/trim/*unpaired*	# Removing the unpaired files
mkdir task_4/asm	# Creating directory for assembly step
spades.py -1 task_4/trim/r1.paired.fq.gz -2 task_4/trim/r2.paired.fq.gz --careful --cov-cutoff auto -o task_4/asm/spades_assembly	# Running spades to perform genome assembly
gzip -k task_4/asm/spades_assembly/spades.log	# Compressing the spades log file
pip3 install biopython	# Installing biopython in conda
./task_4/filter_contigs.py -i task_4/asm/spades_assembly/contigs.fasta -o task_4/srinivasan_assembly.fna	# Filtering contigs to obtain the fna file
quast.py task_4/srinivasan_assembly.fna	# Checking quality of the assembly
gzip -k task_4/srinivasan_assembly.fna	# Compressing the final fna file
conda deactivate	# Deactivating conda environment
