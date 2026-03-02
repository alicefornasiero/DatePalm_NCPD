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
infile - path and file name of vcf.gz input file (including extension)
outdir - path to output folder
snpduopath - path to the folder where you installed SNPDuo program

infile=/path/to/vcf_input_file.vcf.gz
outdir=/path/to/output/dir
snpduopath=/path/to/snpduo
# ----------------------------------------------------------------------- #

# Clone git repositiory for SNPDuo
# cd $snpduopath
# git clone https://github.com/RobersonLab/snpduo.git
# Install the program
# cd snpduo
# make

# Load modules
module load vcftools/0.1.17

# Change to working directory
cd $outdir

# Define output prefix
outprefix=$(basename $infile .vcf.gz)

# Run vcftools to generate .tped and .tfam files as input for SNPduo
vcftools --gzvcf $infile \
--plink-tped \
--out ${outprefix}

# If chromosome names contain characters (e.g. chr01), the vcftools command will convert them into 0 in the first column of the .tped file
# The second column of the .tped file contains chr:pos info (e.g. chr01:100).
# Modify the .tped file to get chromosome names in the first column by splitting the second column into the originary chr and position columns
sed 's/:/\t/g' ${outprefix}.tped | awk '{FS=OFS="\t"} {$1=""; sub(FS, ""); print}' >  ${outprefix}_tmp.tped

mv ${outprefix}_tmp.tped ${outprefix}.tped

# Chromosome names have to be numbers only. Remove any character (e.g. "chr", "Chr", ...)
sed -i 's/Chr0//g' ${outprefix}.tped
sed -i 's/Chr//g' ${outprefix}.tped

# Get IBS counts and summary information. Inputs are data.tfam and data.tped. Output files are .count and .summary
${snpduopath}/snpduo --tfile ${outprefix} \
--counts \
--summary \
--out ${outprefix}_IBS
