#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --partition=batch
#SBATCH --job-name trim
#SBATCH -o trim.%J.out
#SBATCH -e trim.%J.err
#SBATCH --time=20:00:00
#SBATCH --mem=20G

# Read trimming using Trimmomatic

# ----------------------------------------------------------------------- #
# Make sure you update input and output folder path
# FASTQ_FOLDER is the path to the folder containing the raw fastq files and sample list
# PROJECT_FOLDER is the path to the project folder
FASTQ_FOLDER="ENTER_INPUT_DIRECTORY_PATH"
PROJECT_FOLDER="ENTER_OUTPUT_DIRECTORY_PATH"
n_threads=32
# ----------------------------------------------------------------------- #

# Change directory to trimming directory
cd ${PROJECT_FOLDER}/01_trim

# Load modules
module purge
module load trimmomatic/0.39

# Generate the array of slurms
IFS=$'\n' read -d '' -r -a lines < ${FASTQ_FOLDER}/sample_id_list.txt
ID=${lines[${SLURM_ARRAY_TASK_ID}]}

# TRAILING Remove trailing low quality or N bases (Cut bases off the end of a read, if below quality 3)
# SLIDINGWINDOW:4:20 Scan the read with a 4-base wide sliding window, cutting when the average quality per base drops below 20
# MINLEN Drop reads which are less than 50 bases long after these steps
java -jar $TRIMMOMATIC_JAR \
PE -threads $n_threads \
-trimlog logs/${ID}_trimmomatic.log \
${ID}_cutadapt_1.fastq.gz ${ID}_cutadapt_2.fastq.gz \
${ID}_clean_1.fq.gz ${ID}_clean_unpaired_1.fq.gz \
${ID}_clean_2.fq.gz ${ID}_clean_unpaired_2.fq.gz \
TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:50
