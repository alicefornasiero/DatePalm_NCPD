#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=batch
#SBATCH -J SNPDuo
#SBATCH -o SNPDuo.%J.out
#SBATCH -e SNPDuo.%J.err
#SBATCH --time=08:00:00
#SBATCH --mem=50G

# Get IBS0, IBS1, IBS2 and IBS2* counts, and mean and standard deviation IBS values

# ----------------------------------------------------------------------- #
INFILE - Path and file name of vcf input file (can be gzipped)
OUTDIR - Path to output folder
SNPDUOPATH - Path to the folder where you installed SNPDuo program

INFILE="ENTER_PATH_AND_VCF_FILE_NAME"
OUTDIR="ENTER_OUTPUT_DIRECTORY_PATH"
SNPDUOPATH="ENTER_PATH_TO_SNPDUO_EXECUTABLE"
# ----------------------------------------------------------------------- #

# Clone git repositiory for SNPDuo
# cd $SNPDUOPATH
# git clone https://github.com/RobersonLab/snpduo.git
# Install the program
# cd snpduo
# make

# Load modules
module load vcftools/0.1.17

# Change to working directory
cd $OUTDIR

# Define output prefix
OUTPREFIX=$(basename $INFILE .vcf.gz)

# Run vcftools to generate .tped and .tfam files as input for SNPduo
vcftools --gzvcf $INFILE \
--plink-tped \
--out ${OUTPREFIX}

# If chromosome names contain characters (e.g. chr01), the vcftools command will convert them into 0 in the first column of the .tped file
# The second column of the .tped file contains chr:pos info (e.g. chr01:100).
# Modify the .tped file to get chromosome names in the first column by splitting the second column into the originary chr and position columns
sed 's/:/\t/g' ${OUTPREFIX}.tped | awk '{FS=OFS="\t"} {$1=""; sub(FS, ""); print}' >  ${OUTPREFIX}_tmp.tped

mv ${OUTPREFIX}_tmp.tped ${OUTPREFIX}.tped

# Chromosome names have to be numbers only. Remove any character (e.g. "chr", "Chr", ...)
sed -i 's/Chr0//g' ${OUTPREFIX}.tped
sed -i 's/Chr//g' ${OUTPREFIX}.tped

# Get IBS counts and summary information. Inputs are data.tfam and data.tped. Output files are .count and .summary
${SNPDUOPATH}/snpduo --tfile ${OUTPREFIX} \
--counts \
--summary \
--out ${OUTPREFIX}_IBS
