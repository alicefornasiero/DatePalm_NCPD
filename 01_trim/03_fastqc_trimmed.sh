#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --partition=batch
#SBATCH --job-name trim_fastqc
#SBATCH -o trim_fastqc.%J.out
#SBATCH -e trim_fastqc.%J.err
#SBATCH --time=02:00:00
#SBATCH --mem=10G

# Run fastQC on trimmed reads

# ----------------------------------------------------------------------- #
# Make sure you update input and output folder path
# PROJECT_FOLDER is the path to the project folder
# SAMPLE_LIST is a text file with the list of sample names, one per line
# THREADS is the number of threads for parallel processing

PROJECT_FOLDER="ENTER_OUTPUT_DIRECTORY_PATH"
SAMPLE_LIST="ENTER_FILE_NAME_AND_PATH"
THREADS=8
# ----------------------------------------------------------------------- #

# Create output directory and subdirectories
QC_DIR="${PROJECT_FOLDER}/02_trimming_qc"
mkdir -p ${QC_DIR}

# Load modules
module purge
module load fastqc/0.12.0

IFS=$'\n' read -d '' -r -a lines < ${SAMPLE_LIST}
ID=${lines[${SLURM_ARRAY_TASK_ID}]}

# Control the quality of the raw reads with FastQC
fastqc -t ${THREADS} \
-o ${QC_DIR} \
${PROJECT_FOLDER}/01_trim/${ID}_clean_1.fq.gz \
${PROJECT_FOLDER}/01_trim/${ID}_clean_2.fq.gz
