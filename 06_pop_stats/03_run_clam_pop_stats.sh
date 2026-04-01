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
# PROJECT_FOLDER - Path to project folder where per-sample g.vcf files were generated
# OUTFOLDER - Path to output folder where to write heterozigosity, pi, dxy and Fst stats
# MIN_MEAN_DP - Minimum mean depth across samples (it is not a cumulative value)
# MAX_MEAN_DP - Maximum mean depth across samples (it is not a cumulative value)
# MIN_GQ - Minimum genotype quality to count depth (for GVCF input only)
# CHR_TO_EXCLUDE - Path to text file with comma-seaparated list of chromosomes to exclude
# WIN_SIZE - Size of the window in bp
# POP_FILE - Path to a TSV file containing the list of sample names and the corresponding populations (header required: sample_name, population)
  # Samples are listed one per line, fields are tab separated: sample name, a string defining the population (e.g. pop1)
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
POP_FILE="ENTER_PATH_AND_FILE_NAME_OF_POP_TSV_FILE"
VCF_FILE="ENTER_PATH_AND_FILE_NAME_OF_INPUT_VCF_FILE"
OUTPREFIX="ENTER_OUTPUT_PREFIX_NAME"
THREADS="ENTER_NUMBER_OF_THREADS"
# ----------------------------------------------------------------------- #

# Activate conda environment
conda activate clam

# Move to working directory
cd $PROJECT_FOLDER

# Create output directory
mkdir -p ${OUTFOLDER}/pops

# Run clam loci to calculate callable sites from depth zarr store (generated with the previous script) on samples divided in populations (admixed individuals were not included)
clam loci \
  --output ${OUTFOLDER}/pops/${OUTPREFIX}_callable.zarr \
  --min-mean-depth ${MIN_MEAN_DP} \
  --max-mean-depth ${MAX_MEAN_DP} \
  --min-gq ${MIN_GQ} \
  --exclude-file ${CHR_TO_EXCLUDE} \
  --threads ${THREADS} \
  ${OUTPREFIX}_depth.zarr \
  --samples ${POP_FILE}

# Calculate population genetic statistics from the samples divided in populations (admixed individuals were not included)
clam stat \
  --callable ${OUTFOLDER}/pops/${OUTPREFIX}_callable.zarr \
  --window-size ${WIN_SIZE} \
  --exclude-file ${CHR_TO_EXCLUDE} \
  --force-samples \
  --threads ${THREADS} \
  --outdir ${OUTFOLDER}/pops \
  ${VCF_FILE}

# Sort pi.tsv output file
cd ${OUTFOLDER}/pops
tail -n+2 pi.tsv | sort -V > pi_sorted.tsv
