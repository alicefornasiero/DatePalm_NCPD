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
# Make sure you update input and output folder path
# VCF_FULL_PATH_NAME is the full path and file name of the vcf file to be filtered, including extension

VCF_FULL_PATH_NAME="ENTER_VCF_FULL_PATH_AND_FILE_NAME"
# ----------------------------------------------------------------------- #

# Load modules
module purge
module load gatk/4.3.0.0
module load tabix/1.16
module load bcftools/1.16

# Filter out loci with singletons (1 HET) or doubletons (1 HOMO ALT) 
bcftools view -i 'COUNT(GT="het") > 1 || COUNT(GT="AA") > 1' ${VCF_FULL_PATH_NAME} \
--output ${dirname $VCF_FULL_PATH_NAME}/${basename $VCF_FULL_PATH_NAME .vcf.gz}_noprivall.vcf.gz \
--output-type z

# Index file
gatk --java-options "-Djava.io.tmpdir=tmp -Xmx90G" IndexFeatureFile \
   -I ${dirname $VCF_FULL_PATH_NAME}/${basename $VCF_FULL_PATH_NAME .vcf.gz}_noprivall.vcf.gz

# Generate vcf statistics
bcftools stats -s - \
${dirname $VCF_FULL_PATH_NAME}/${basename $VCF_FULL_PATH_NAME .vcf.gz}_noprivall.vcf.gz > ${dirname $VCF_FULL_PATH_NAME}/${basename $VCF_FULL_PATH_NAME .vcf.gz}_noprivall.stats
