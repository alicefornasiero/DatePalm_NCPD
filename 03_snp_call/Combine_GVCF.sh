#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=batch
#SBATCH -J CombGVCF
#SBATCH -o CombGVCF.%J.out
#SBATCH -e CombGVCF.%J.err
#SBATCH --time=05-00:00:00
#SBATCH --mem=150G

# Combine per-sample gVCF files produced by HaplotypeCaller into a multi-sample gVCF file

# ----------------------------------------------------------------------- #
# PROJECT_FOLDER is the path to the project folder
# REFERENCE is the path to the reference genome in fasta format
# VCF_PREFIX is the name of the GVCF output file

PROJECT_FOLDER="ENTER_OUTPUT_DIRECTORY_PATH"
REFERENCE="ENTER_REFERENCE_PATH_AND_FILE_NAME"
VCF_PREFIX="ENTER_VCF_PREFIX_NAME"
# ----------------------------------------------------------------------- #

# Load modules
module purge
module load gatk/4.3.0.0

# Change to snp call output directory
cd ${PROJECT_FOLDER}/04_snpcall

# Generate the list of samples to be included when running CombineGVCF
for file in $(ls gVCF/*.g.vcf.gz); do SAMPLE_LIST+="--variant ${file} "; done

# run CombineGVCFs
gatk --java-options "-Djava.io.tmpdir=tmp -Xmx120G" CombineGVCFs \
-R ${REFERENCE} \
-O ${VCF_PREFIX}.g.vcf.gz \
${SAMPLE_LIST}
