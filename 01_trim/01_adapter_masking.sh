#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --partition=batch
#SBATCH --job-name cutadap
#SBATCH -o cutadap.%J.out
#SBATCH -e cutadap.%J.err
#SBATCH --time=10:00:00
#SBATCH --mem=10G

# Adapter masking using Cutadapt

# ----------------------------------------------------------------------- #
# Make sure you update input and output folder path
# FASTQ_FOLDER is the path to the folder containing the raw fastq files
# PROJECT_FOLDER is the path to the project folder
# SAMPLE_LIST is a text file with the list of sample prefix, one per line

FASTQ_FOLDER="ENTER_INPUT_DIRECTORY_NAME_AND_PATH"
PROJECT_FOLDER="ENTER_OUTPUT_DIRECTORY_NAME AND_PATH"
SAMPLE_LIST="ENTER_FILE_NAME_AND_PATH"

# Set variables for Illumina Truseq adapter sequence masking
adapter1=AGATCGGAAGAGCACACGTCTGAACTCCAGTCA
adapter2=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
n_cores=32
# ----------------------------------------------------------------------- #

# Create output directory and subdirectories
TRIM_DIR="${PROJECT_FOLDER}/01_trim"
LOG_DIR="${PROJECT_FOLDER}/01_trim/logs"
mkdir -p ${LOG_DIR}

# Change directory to trimming directory
cd $TRIM_DIR

# Load modules
module purge
module load cutadapt/4.3

# Generate the array of slurms
IFS=$'\n' read -d '' -r -a lines < ${SAMPLE_LIST}
ID=${lines[${SLURM_ARRAY_TASK_ID}]}

# Launch Cutadapt
cutadapt --cores=$n_cores \
--nextseq-trim=20 \
-a ${adapter1} \
-A ${adapter2} \
--overlap 5 --times 2 --pair-filter=any --minimum-length 50 \
-o ${ID}_cutadapt_1.fastq.gz \
-p ${ID}_cutadapt_2.fastq.gz \
--action=mask \
${FASTQ_FOLDER}/${ID}_R1.fastq.gz ${FASTQ_FOLDER}/${ID}_R2.fastq.gz > logs/${ID}_cutadapt.log
