#!/bin/bash
#SBATCH --time=00:30:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=batch
#SBATCH --job-name run_pca
#SBATCH -o run_pca.%J.out
#SBATCH -e run_pca.%J.err
#SBATCH --mem=10G

# Run PCA analysis using plink

# ----------------------------------------------------------------------------- #
# PROJECT_FOLDER is the path to the project folder
# VCF - is the full path and file name of the vcf input file. It can be gzipped.

PROJECT_FOLDER="ENTER_OUTPUT_DIRECTORY_PATH"
VCF="ENTER_INPUT_VCF_PATH_AND_FILE_NAME"
# ----------------------------------------------------------------------------- #

# Load modules
module purge
module load plink

# Create output directory and change directory to output directory
STRUCT_DIR="${PROJECT_FOLDER}/06_structure"
mkdir -p ${STRUCT_DIR}
mkdir -p ${STRUCT_DIR}/PCA
cd ${STRUCT_DIR}/PCA

# Use function --pca tu run the PCA on a genetic relationship matrix (GRM).
plink2 --vcf ${VCF} \
--make-pgen \
--allow-extra-chr \
--freq counts \
--keep-founders \
--pca biallelic-var-wts \
--out $(basename $vcf .vcf.gz)
