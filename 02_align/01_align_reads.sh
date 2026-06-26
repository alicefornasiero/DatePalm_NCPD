#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --partition=batch
#SBATCH --job-name align
#SBATCH -o align.%J.out
#SBATCH -e align.%J.err
#SBATCH --time=48:00:00
#SBATCH --mem=50G

# Read aligment using BWA mem

# ----------------------------------------------------------------------- #
# PROJECT_FOLDER is the path to the project folder
# SAMPLE_LIST is a text file with the list of sample prefix, one per line
# REFERENCE is the path to the reference genome in fasta format
# MEM_THREADS is the number of threads

PROJECT_FOLDER="ENTER_OUTPUT_DIRECTORY_PATH"
SAMPLE_LIST="ENTER_FILE_NAME_AND_PATH"
REFERENCE="ENTER_REFERENCE_PATH_AND_FILE_NAME"
MEM_THREADS=8
# ----------------------------------------------------------------------- #

# Create output directory and sub-directories
ALIGN_DIR="${PROJECT_FOLDER}/03_alignment"
mkdir -p ${ALIGN_DIR}
mkdir -p ${ALIGN_DIR}/tmp
mkdir -p ${ALIGN_DIR}/aln_stats

# Change directory to alignment directory
cd ${ALIGN_DIR}

# Load modules
module purge
module load bwa/0.7.17/gnu-12.2.0
module load samtools/1.16.1

# Generate the array of slurms
IFS=$'\n' read -d '' -r -a lines < ${SAMPLE_LIST}
ID=${lines[${SLURM_ARRAY_TASK_ID}]}

# Run BWA mem
bwa mem -M -t ${MEM_THREADS} \
${REFERENCE} \
${PROJECT_FOLDER}/01_trim/${ID}_clean_1.fq.gz ${PROJECT_FOLDER}/01_trim/${ID}_clean_2.fq.gz | samtools sort -O bam -T tmp -@ ${MEM_THREADS} - > ${ID}.bam
