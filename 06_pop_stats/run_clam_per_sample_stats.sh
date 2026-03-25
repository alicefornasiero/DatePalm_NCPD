#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --partition=batch
#SBATCH -J clam
#SBATCH -o clam.%J.out
#SBATCH -e clam.%J.err
#SBATCH --time=08:00:00
#SBATCH --mem=100G

# Run clam software to calculate heterozigosity and pi in each sample using gVCF files as input

# ----------------------------------------------------------------------- #
# PROJECT_FOLDER - Path to project folder where per-sample g.vcf files were generated (/path/to/04_snpcall/gVCF)
# OUTFOLDER - Path to output folder where to write heterozigosity and pi stats
# MIN_MEAN_DP - Minimum mean depth across samples (it is not a cumulative value)
# MAX_MEAN_DP - Maximum mean depth across samples (it is not a cumulative value)
# MIN_GQ - Minimum genotype quality to count depth (for GVCF input only)
# CHR_TO_EXCLUDE - Path to text file with comma-seaparated list of chromosomes to be excluded
# WIN_SIZE - Size of the window in bp
# VCF_FILE - Path to to input multi-sample vcf file with filtered snps used in the calculation of pop stats
# OUTPREFIX - prefix for the output .zarr archive containing the callable sites
# THREADS - Number of threads

PROJECT_FOLDER="ENTER_INPUT_DIRECTORY_PATH"
OUTFOLDER="ENTER_OUTPUT_DIRECTORY_PATH"
MIN_MEAN_DP="ENTER_MIN_MEAN_READ_DEPTH"
MAX_MEAN_DP="ENTER_MAX_MEAN_READ_DEPTH"
MIN_GQ="ENTER_MIN_GENOTYPE_QUALITY"
CHR_TO_EXCLUDE="ENTER_FILE_PATH"
WIN_SIZE="ENTER_WINDOW_SIZE"
VCF_FILE="ENTER_PATH_AND_FILE_NAME_OF_INPUT_VCF_FILE"
OUTPREFIX="ENTER_OUTPUT_PREFIX_NAME"
THREADS="ENTER_NUMBER_OF_THREADS"
# ----------------------------------------------------------------------- #

# Activate conda environment
conda activate clam

# Change to working directory
cd $PROJECT_FOLDER

# Create output directory
mkdir -p ${OUTFOLDER}/per_sample

# Generate the list of gVCF files to build the Zarr store with individual depth values
for per_sample_gvcf in *.g.vcf.gz; do GVCF_LIST+="${per_sample_gvcf} "; done

# Run clam collect to collect depth from single-sample gVCF files and store it into a Zarr store
clam collect \
--min-gq ${MIN_GQ} \
--exclude-file ${CHR_TO_EXCLUDE} \
--threads ${THREADS} \
--output ${OUTPREFIX}_depth.zarr \
GVCF_LIST

# Run clam loci to calculate callable sites from depth statistics on individual samples (admixed individuals included)
clam loci \
--min-mean-depth ${MIN_MEAN_DP} \
--max-mean-depth ${MAX_MEAN_DP} \
--min-gq ${MIN_GQ} \
--exclude-file ${CHR_TO_EXCLUDE} \
--threads ${THREADS} \
--output ${OUTFOLDER}/per_sample/${OUTPREFIX}_callable.zarr \
--per-sample \
${OUTPREFIX}_depth.zarr

# Calculate population genetic statistics from the filtered VCF for each sample separately
clam stat \
--outdir ${OUTFOLDER}/per_sample \
--callable ${OUTFOLDER}/per_sample/${OUTPREFIX}_callable.zarr \
--window-size ${WIN_SIZE} \
--exclude-file ${CHR_TO_EXCLUDE} \
--threads ${THREADS} \
${VCF_FILE}

# Sort and adjust columns of output file heterozygosity.tsv
cd ${OUTFOLDER}/per_sample
tail -n+2 heterozygosity.tsv | sort -V | cut -f 1,2,3,4,6,7,8 > heterozygosity_sorted.tsv
