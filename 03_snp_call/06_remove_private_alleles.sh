#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=batch
#SBATCH -J excl_clones
#SBATCH -o excl_clones.%J.out
#SBATCH -e excl_clones.%J.err
#SBATCH --time=48:00:00
#SBATCH --mem=50G

# Remove private alleles by excluding loci genotyped in one individual (i.e. singletons (1 HET) or doubletons (1 HOMO ALT))

# ----------------------------------------------------------------------- #
# PROJECT_FOLDER is the path to the project folder
# VCF_PREFIX is the prefix name of the GVCF file
# File must have .vcf.gz extension

PROJECT_FOLDER="ENTER_OUTPUT_DIRECTORY_PATH"
VCF_PREFIX="ENTER_VCF_PREFIX_NAME"
# ----------------------------------------------------------------------- #

# Load modules
module purge
module load gatk/4.3.0.0
module load tabix/1.16
module load bcftools/1.16

# Change directory to snp call output directory
cd ${PROJECT_FOLDER}/05_filtering

# Filter out loci with singletons (1 HET) or doubletons (1 HOMO ALT) 
bcftools view -i 'COUNT(GT="het") > 1 || COUNT(GT="AA") > 1' ${VCF_PREFIX}.vcf.gz \
--output ${VCF_PREFIX}_noprivall.vcf.gz \
--output-type z

# Index file
gatk --java-options "-Djava.io.tmpdir=tmp -Xmx45G" IndexFeatureFile \
   -I ${VCF_PREFIX}_noprivall.vcf.gz

# Generate vcf statistics
bcftools stats -s - ${VCF_PREFIX}_noprivall.vcf.gz > ${VCF_PREFIX}_noprivall.stats
