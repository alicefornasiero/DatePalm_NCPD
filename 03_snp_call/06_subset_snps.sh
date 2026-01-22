#!/bin/bash
#SBATCH --time=04:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=batch
#SBATCH --job-name snp_subset
#SBATCH -o snp_subset.%J.out
#SBATCH -e snp_subset.%J.err
#SBATCH --mem=50G

# Subset a fraction of the genotyped loci randomly

# ----------------------------------------------------------------------- #
# Make sure you update input and output folder path
# PROJECT_FOLDER is the path to the project folder
# VCF_PREFIX is the prefix name of the GVCF output file
# FRACTION is the proportion (between 0 and 1) of genotyped loci to be randomly subset

PROJECT_FOLDER="ENTER_OUTPUT_DIRECTORY_PATH"
VCF_PREFIX="ENTER_VCF_PREFIX_NAME"
FRACTION="ENTER_SNP_FRACTION_TO_RECOVER"
# ----------------------------------------------------------------------- #

# Load modules
module purge
module load plink #PLINK 2.0
module load gatk/4.3.0.0
module load tabix/1.16
module load bcftools/1.16

# Change directory to snp filtering directory
cd ${PROJECT_FOLDER}/05_filtering

# GATK SelectVariants to random sample genotypes (--select-random-fraction: number between 0 and 1 specifying the fraction of total variants to be randomly selected from the input callset.)
gatk --java-options "-Djava.io.tmpdir=tmp -Xmx90G" SelectVariants \
-V ${VCF_PREFIX}_filt_noSDR_noclones_privall.vcf.gz \
--select-random-fraction ${FRACTION} \
--output ${VCF_PREFIX}_filt_noSDR_noclones_privall_snpsubset.vcf.gz

# Generate Plink pgen files from the vcf file
plink2 --vcf ${VCF_PREFIX}_filt_noSDR_noclones_privall_snpsubset.vcf.gz \
--allow-extra-chr \
--make-pgen \
--out ${VCF_PREFIX}_filt_noSDR_noclones_privall_snpsubset

# Generate vcf statistics
bcftools stats -s - ${VCF_PREFIX}_filt_noSDR_noclones_privall_snpsubset.vcf.gz > ${VCF_PREFIX}_filt_noSDR_noclones_privall_snpsubset.stats
