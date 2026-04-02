#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=batch
#SBATCH -J HapCall
#SBATCH -o HapCall.%J.out
#SBATCH -e HapCall.%J.err
#SBATCH --time=48:00:00
#SBATCH --mem=50G

# SNP calling using GATK HaplotypeCaller

# ----------------------------------------------------------------------- #
# PROJECT_FOLDER is the path to the project folder
# SAMPLE_LIST is a text file with the list of sample prefix, one per line
# REFERENCE is the path to the reference genome in fasta format
# MEM_THREADS is the number of threads
# MINQ is the read mapping quality cutoff to filter out aligned reads with low mapping quality
# BASEQ is the minimum base quality required to consider a base for calling
# OUTPUT_MODE is the mode for emitting reference confidence scores [NONE, GVCF, BP_RESOLUTION]

PROJECT_FOLDER="ENTER_OUTPUT_DIRECTORY_PATH"
SAMPLE_LIST="ENTER_FILE_NAME_AND_PATH"
REFERENCE="ENTER_REFERENCE_PATH_AND_FILE_NAME"
MEM_THREADS=32
MINQ=30
BASEQ=30
OUTPUT_MODE=GVCF
# ----------------------------------------------------------------------- #

# Load modules
module purge
module load gatk/4.3.0.0

# Generate sequence dictionary for the reference sequence
REFERENCE_DIR=$(dirname $REFERENCE)
if [ -f "${REFERENCE_DIR}/"*".dict" ]; then
    echo ".dict file already generated"
else
    echo "Generating dictionary for reference genome ..."
    cd ${REFERENCE_DIR}
    gatk CreateSequenceDictionary -R ${REFERENCE}
fi

# Create output directory and subdirectories, and change to snp call output directory
SNP_DIR="${PROJECT_FOLDER}/04_snpcall"
mkdir -p ${SNP_DIR}
mkdir -p ${SNP_DIR}/gVCF
mkdir -p ${SNP_DIR}/gVCF/tmp
cd ${SNP_DIR}

# Generate the array of slurms
IFS=$'\n' read -d '' -r -a lines < ${SAMPLE_LIST}
ID=${lines[${SLURM_ARRAY_TASK_ID}]}

# run HaplotypeCaller
gatk --java-options "-Djava.io.tmpdir=gVCF/tmp -Xmx45G" HaplotypeCaller \
--emit-ref-confidence ${OUTPUT_MODE} \
--min-base-quality-score ${BASEQ} \
-R ${REFERENCE} \
-I ${PROJECT_FOLDER}/03_alignment/${ID}_RG_clean_q${MINQ}_FM_markdup.bam \
-O gVCF/${ID}.g.vcf.gz
