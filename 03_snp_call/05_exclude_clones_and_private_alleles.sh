#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=batch
#SBATCH -J excl_clones
#SBATCH -o excl_clones.%J.out
#SBATCH -e excl_clones.%J.err
#SBATCH --time=48:00:00
#SBATCH --mem=50G

# Exclude clones from the filtered vcf file
# Remove private alleles by excluding loci genotyped in one individual (i.e. singletons (1 HET) or doubletons (1 HOMO ALT))

# ----------------------------------------------------------------------- #
# Make sure you update input and output folder path
# PROJECT_FOLDER is the path to the project folder
# VCF_PREFIX is the prefix name of the GVCF output file
# EXCLUDE_SAMPLES is the file name including full path of a .args file with the list of samples to exclude (one per line)

PROJECT_FOLDER="ENTER_OUTPUT_DIRECTORY_PATH"
VCF_PREFIX="ENTER_VCF_PREFIX_NAME"
EXCLUDE_SAMPLES="ENTER_.ARGS_FILE_NAME_AND_PATH" 
# ----------------------------------------------------------------------- #

# Load modules
module purge
module load gatk/4.3.0.0
module load tabix/1.16
module load plink
module load bcftools/1.16

# Change directory to snp call output directory
cd ${PROJECT_FOLDER}/05_filtering

# GATK SelectVariants to exclude clone samples (--exclude-sample-name HERE WE ARE EXCLUDING SAMPLES LISTED IN list.args)
gatk --java-options "-Djava.io.tmpdir=tmp -Xmx90G" SelectVariants \
-V ${VCF_PREFIX}_filt_noSDR.vcf.gz \
--exclude-sample-name ${EXCLUDE_SAMPLES} \
--output ${VCF_PREFIX}_filt_noSDR_noclones.vcf.gz

# Filter out loci with singletons (1 HET) or doubletons (1 HOMO ALT) 
bcftools view -i 'COUNT(GT="het") > 1 || COUNT(GT="AA") > 1' ${VCF_PREFIX}_filt_noSDR_noclones.vcf.gz \
--output ${outprefix}.vcf.gz \
--output-type z

# Index file
gatk --java-options "-Djava.io.tmpdir=tmp -Xmx90G" IndexFeatureFile \
   -I ${VCF_PREFIX}_filt_noSDR_noclones_noprivall.vcf.gz

# Generate vcf statistics
bcftools stats -s - ${VCF_PREFIX}_filt_noSDR_noclones_noprivall.vcf.gz > ${VCF_PREFIX}_filt_noSDR_noclones_noprivall.stats
