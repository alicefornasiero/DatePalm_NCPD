#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=batch
#SBATCH -J multiqc
#SBATCH -e multiqc.%J.log
#SBATCH -o multiqc.%J.out
#SBATCH --time=2:00:00
#SBATCH --mem=20G

# Run multiqc tool to summarise individual qc statistics of trimmed samples

# ----------------------------------------------------------------------- #
# Make sure you update input folder path
# PROJECT_FOLDER is the path to the project folder

PROJECT_FOLDER="ENTER_OUTPUT_DIRECTORY_PATH"
# ----------------------------------------------------------------------- #

# Load module
module purge
module load multiqc/1.14

# Change dir to working directory
cd ${PROJECT_FOLDER}

# Run multiqc
multiqc 02_trimming_qc \
--force
