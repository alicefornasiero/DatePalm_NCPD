#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=batch
#SBATCH -J filter_snps
#SBATCH -o filter_snps.%J.out
#SBATCH -e filter_snps.%J.err
#SBATCH --time=48:00:00
#SBATCH --mem=100G

# Apply baseline SNP filtering

# ----------------------------------------------------------------------- #
# PROJECT_FOLDER is the path to the project folder
# REFERENCE is the path to the reference genome in fasta format
# VCF_PREFIX is the name of the GVCF file
# MINDP is the minimum depth (DP) value over all samples at the site level (INFO)
# MAXDP is the maximum depth (DP) value over all samples at the site level (INFO)

PROJECT_FOLDER="ENTER_OUTPUT_DIRECTORY_PATH"
REFERENCE="ENTER_REFERENCE_PATH_AND_FILE_NAME"
VCF_PREFIX="ENTER_VCF_PREFIX_NAME"
MINDP="ENTER_MINIMUM_INFO_DP"
MAXDP="ENTER_MAXIMUM_INFO_DP"
# ----------------------------------------------------------------------- #

# Load modules
module purge
module load gatk/4.3.0.0
module load tabix/1.16
module load bcftools/1.16

# Create output directory and subdirectories and change to filtered snps output direc
FILT_DIR=${PROJECT_FOLDER}/05_filtering
mkdir -p ${FILT_DIR}
mkdir -p ${FILT_DIR}/tmp
cd ${FILT_DIR}

# Select biallelic SNPs only (exclude indels and non-biallelic SNPs)
##https://gatk.broadinstitute.org/hc/en-us/articles/360035531112--How-to-Filter-variants-either-with-VQSR-or-by-hard-filtering
##https://gatk.broadinstitute.org/hc/en-us/articles/360035890471
gatk --java-options "-Djava.io.tmpdir=tmp -Xmx90G" SelectVariants \
-R ${REFERENCE} \
-V ${VCF_PREFIX}_variants.vcf.gz \
--select-type-to-include SNP \
--restrict-alleles-to BIALLELIC \
--output ${VCF_PREFIX}_SNPtemp.vcf.gz

# Filter SNPs using Hard-Filtering best practice from GATK, and minimum/maximum read depth per locus
##https://gatk.broadinstitute.org/hc/en-us/articles/360035531112--How-to-Filter-variants-either-with-VQSR-or-by-hard-filtering
##https://gatk.broadinstitute.org/hc/en-us/articles/360035890471
gatk --java-options "-Djava.io.tmpdir=tmp -Xmx90G" VariantFiltration \
-R ${REFERENCE} \
-V ${VCF_PREFIX}_SNPtemp.vcf.gz \
--filter-name "FILT_DPMIN" \
--filter-expression "DP < $MINDP" \
--filter-name "FILT_DPMAX" \
--filter-expression "DP > $MAXDP" \
--filter-name "FILT_QD" \
--filter-expression "QD < 2.0" \
--filter-name "FILT_MQ" \
--filter-expression "MQ < 40.0" \
--filter-name "FILT_FS" \
--filter-expression "FS > 60.0" \
--filter-name "FILT_SOR" \
--filter-expression "SOR > 3.0" \
--filter-name "FILT_MQRankSum" \
--filter-expression "MQRankSum < -12.5" \
--filter-name "FILT_ReadPosRankSum" \
--filter-expression "ReadPosRankSum < -8.0" \
--cluster-size 3 \
--cluster-window-size 10 \
--output ${VCF_PREFIX}_SNP_HF.vcf.gz

# Generate the list of chromosomes to be included when running GATK SelectVariants
for chrnum in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18; do CHR_LIST+="-L Chr${chrnum} "; done

# Exclude SNPs from the Sex-Determining-Region (SDR)
gatk --java-options "-Djava.io.tmpdir=tmp -Xmx90G" SelectVariants \
-R ${REFERENCE} \
-V ${VCF_PREFIX}_SNP_HF.vcf.gz \
${CHR_LIST} \
--output ${VCF_PREFIX}_filt_noSDR.vcf.gz \
--exclude-filt

# Select SNPs from the SDR only
# Run this step only if needed (i.e. if you are interested in analysing polymorphisms on the male SDR)
gatk --java-options "-Djava.io.tmpdir=tmp -Xmx90G" SelectVariants \
-R ${REFERENCE} \
-V ${VCF_PREFIX}_SNP_HF.vcf.gz \
-L Chr14_male.SDR \
--output ${VCF_PREFIX}_filt_SDRonly.vcf.gz \
--exclude-filt

# Generate statistics on the final output file
bcftools stats -s - ${VCF_PREFIX}_filt_noSDR_noprivall.vcf.gz > ${VCF_PREFIX}_filt_noSDR_noprivall.stats
