#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --partition=batch
#SBATCH --job-name trim
#SBATCH -o logs/trim.%J.out
#SBATCH -e logs/trim.%J.err
#SBATCH --time=20:00:00
#SBATCH --mem=20G

# Set variables for read trimming
outfolder=/ibex/scratch/projects/c2042/celiim/DatePalm_population_genetics/01_trim/Muriel_Weil
n_threads=32

# Change directory
cd $outfolder

# Load modules and create folders
module purge
module load trimmomatic/0.39
mkdir -p logs

IFS=$'\n' read -d '' -r -a lines < /ibex/scratch/projects/c2042/celiim/DatePalm_population_genetics/sample_list/Muriel_Weil_samples_final.list
ID=${lines[${SLURM_ARRAY_TASK_ID}]}

# Commands for trimming reads using TRIMMOMATIC
# TRAILING Remove trailing low quality or N bases (Cut bases off the end of a read, if below quality 3)
# SLIDINGWINDOW:4:20 Scan the read with a 4-base wide sliding window, cutting when the average quality per base drops below 20
# MINLEN Drop reads which are less than 50 bases long after these steps
java -jar $TRIMMOMATIC_JAR \
PE -threads $n_threads \
-trimlog logs/${mysample}_trimmomatic.log \
${mysample}_cutadapt_1.fastq.gz ${mysample}_cutadapt_2.fastq.gz \
${mysample}_clean_1.fq.gz ${mysample}_clean_unpaired_1.fq.gz \
${mysample}_clean_2.fq.gz ${mysample}_clean_unpaired_2.fq.gz \
TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:50
