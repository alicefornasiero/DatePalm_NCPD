#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --partition=batch
#SBATCH --job-name trim
#SBATCH -o trim.%J.out
#SBATCH -e trim.%J.err
#SBATCH --time=20:00:00
#SBATCH --mem=10G

# Read trimming using Trimmomatic

# ----------------------------------------------------------------------- #
# Make sure you update the project folder path
# PROJECT_FOLDER is the path to the project folder
# SAMPLE_LIST is a text file with the list of sample prefix, one per line

PROJECT_FOLDER="ENTER_OUTPUT_DIRECTORY_PATH"
SAMPLE_LIST="ENTER_FILE_NAME_AND_PATH"
n_threads=8
# ----------------------------------------------------------------------- #

# Change directory to trimming directory
cd ${PROJECT_FOLDER}/01_trim

# Load modules
module purge
module load trimmomatic/0.39

# Generate the array of slurms
IFS=$'\n' read -d '' -r -a lines < ${SAMPLE_LIST}
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
