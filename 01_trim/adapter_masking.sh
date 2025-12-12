#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --partition=batch
#SBATCH --job-name cutadap
#SBATCH -o cutadap.%J.out
#SBATCH -e cutadap.%J.err
#SBATCH --time=20:00:00
#SBATCH --mem=20G

# Adapter masking using Cutadapt

# ----------------------------------------------------------------------- #
# Make sure you update input and output folder path
# INFOLDER is the path to the folder containing the raw fastq files
# OUTFOLDER is the path to the output folder
INFOLDER="ENTER_INPUT_DIRECTORY_NAME_AND_PATH"
OUTFOLDER="ENTER_OUTPUT_DIRECTORY_NAME AND_PATH"

# Set variables for Illumina Truseq adapter sequence masking
adapter1=AGATCGGAAGAGCACACGTCTGAACTCCAGTCA
adapter2=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
n_cores=32
# ----------------------------------------------------------------------- #

# Generate a list of sample IDs using the names of the fastq.gz files in the initial data directory
cd ${INFOLDER}
if [ -f "sample_list.txt" ]; then
    rm sample_list.txt
fi
for fastq_file in *_R1.fastq.gz; do
        sample_id=$(basename "$fastq_file" _R1.fastq.gz);
done >> sample_id_list.txt

# Create output directory and subdirectories
TRIM_DIR="${OUTFOLDER}/01_trim"
LOG_DIR="${OUTFOLDER}/01_trim/logs"
mkdir -p ${TRIM_DIR}
mkdir -p ${LOG_DIR}

# Change directory to trimming directory
cd $TRIM_DIR

# Load modules
module purge
module load cutadapt/4.3

# Generate the array of slurms
IFS=$'\n' read -d '' -r -a lines < ${INFOLDER}/sample_id_list.txt
ID=${lines[${SLURM_ARRAY_TASK_ID}]}

# Launch cutadapt
cutadapt --cores=$n_cores \
--nextseq-trim=20 \
-a ${adapter1} \
-A ${adapter2} \
--overlap 5 --times 2 --pair-filter=any --minimum-length 50 \
-o ${ID}_cutadapt_1.fastq.gz \
-p ${ID}_cutadapt_2.fastq.gz \
--action=mask \
${INFOLDER}/${ID}_R1.fastq.gz ${INFOLDER}/${ID}_R2.fastq.gz > logs/${ID}_cutadapt.log
