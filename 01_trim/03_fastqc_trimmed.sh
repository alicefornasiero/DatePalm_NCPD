#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --partition=batch
#SBATCH --job-name trim_fastqc
#SBATCH -o trim_fastqc.%J.out
#SBATCH -e trim_fastqc.%J.err
#SBATCH --time=20:00:00
#SBATCH --mem=20G

# Run fastQC on trimmed reads

# ----------------------------------------------------------------------- #
# Make sure you update input and output folder path
# FASTQ_FOLDER is the path to the folder containing the raw fastq files and sample list
# PROJECT_FOLDER is the path to the project folder
FASTQ_FOLDER="ENTER_INPUT_DIRECTORY_PATH"
PROJECT_FOLDER="ENTER_OUTPUT_DIRECTORY_PATH"
n_threads=8
# ----------------------------------------------------------------------- #

# Create output directory and subdirectories
QC_DIR="${PROJECT_FOLDER}/02_trimming_qc"
mkdir -p ${QC_DIR}

# Load modules
module purge
module load fastqc/0.12.0

IFS=$'\n' read -d '' -r -a lines < ${FASTQ_FOLDER}/sample_id_list.txt
ID=${lines[${SLURM_ARRAY_TASK_ID}]}

# Control the quality of the raw reads with FastQC
fastqc -t 8 \
-o ${QC_DIR} \
${PROJECT_FOLDER}/01_trim/${ID}_clean_1.fq.gz \
${PROJECT_FOLDER}/01_trim/${ID}_clean_2.fq.gz
