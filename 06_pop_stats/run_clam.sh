#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --partition=batch
#SBATCH -J clam
#SBATCH -o clam.%J.out
#SBATCH -e clam.%J.err
#SBATCH --time=08:00:00
#SBATCH --mem=100G

# Run clam software to calculate heterozugosity, pi, dxy and Fst in each population using gVCF files as input

# ----------------------------------------------------------------------- #
# INDIR - Path to the project folder
# MIN_MEAN_DP - Minimum mean depth across samples (it is not a cumulative value)
# MAX_MEAN_DP - Maximum mean depth across samples (it is not a cumulative value)
# MIN_GQ - Minimum genotype quality to count depth (for GVCF input only)
# CHR_TO_EXCLUDE - Comma-seaparated list of chromosomes to be excluded
# WIN_SIZE - Size of the window in bp
# SAMPLE_FILE - Path to TSV file containing the list of samples and gVCF files (header is required)
  # Samples are listed one per line, columns are tab separated: sample name, respective gVCF file path and file name, and a string defining the population
  # Header line (tab seaparated): sample_name, file_path, population
# POP_FILE - Path to TSV file containing the list of samples and the respective population (no header)
  # Samples are listed one per line, columns are tab separated: sample name, a string defining the population
# VCF_FILE - Path to to input multi-sample vcf file with filtered snps used in the calculation of pop stats
# OUTPREFIX - prefix for the output .zarr archive containing the callable sites
# THREADS - Number of threads

INDIR="ENTER_INPUT_DIRECTORY_PATH"
MIN_MEAN_DP="ENTER_MIN_MEAN_READ_DEPTH"
MAX_MEAN_DP="ENTER_MAX_MEAN_READ_DEPTH"
MIN_GQ="ENTER_MIN_GENOTYPE_QUALITY"
CHR_TO_EXCLUDE="ENTER_CHR_NAMES_TO_EXCLUDE"
WIN_SIZE="ENTER_WINDOW_SIZE"
SAMPLE_FILE="ENTER_PATH_AND_FILE_NAME_OF_SAMPLE_TSV_FILE"
POP_FILE="ENTER_PATH_AND_FILE_NAME_OF_POP_TSV_FILE"
VCF_FILE="ENTER_PATH_AND_FILE_NAME_OF_INPUT_VCF_FILE"
OUTPREFIX="ENTER_OUTPUT_PREFIX_NAME"
THREADS="ENTER_NUMBER_OF_THREADS"
# ----------------------------------------------------------------------- #

# Activate conda environment
source ~/miniconda3/bin/activate
conda activate clam

# Move to working directory
cd $INDIR

# Create output directory
mkdir -p ${INDIR}/pops

# Run clam loci to calculate callable sites from depth statistics on samples divided in populations (admixed individuals were not included)
clam loci \
  --output ${OUTPREFIX}.zarr \
  --min-mean-depth ${MIN_MEAN_DP} \
  --max-mean-depth ${MAX_MEAN_DP} \
  --min-gq ${MIN_GQ} \
  --exclude ${CHR_TO_EXCLUDE} \
  --threads ${THREADS} \
  --samples ${SAMPLE_FILE}

# Calculate population genetic statistics from the samples divided in populations (admixed individuals were not included)
clam stat \
  --callable ${OUTPREFIX}.zarr \
  --window-size ${WIN_SIZE} \
  --exclude ${CHR_TO_EXCLUDE} \
  -p ${POP_FILE} \
  --force-samples \
  --threads ${THREADS} \
  --outdir pops \
  ${VCF_FILE}

# sort output files
sort -V pops/heterozygosity.tsv > pops/heterozygosity_sorted.tsv
sort -V pops/pi.tsv > pops/pi_sorted.tsv
sort -V pops/fst.tsv > pops/fst_sorted.tsv
sort -V pops/dxy.tsv > pops/dxy_sorted.tsv
