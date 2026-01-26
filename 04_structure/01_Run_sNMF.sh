#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=batch
#SBATCH --job-name sNMF
#SBATCH -o sNMF.%J.out
#SBATCH -e sNMF.%J.err
#SBATCH --mem=100G

# Population structure analysis using sNMF

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: #
# VCF - is the vcf input file. It can be gzipped.
# PROJECT_FOLDER is the path to the project folder
# RUNFILE - is the path and file name with the list of runs (numeric sequence, one number per line)
# NUMK - is the maximum number of Ks
# OUTPUT_PREFIX - is the prefix for the output files

VCF="ENTER_INPUT_VCF_PATH_AND_FILE_NAME"
PROJECT_FOLDER="ENTER_OUTPUT_DIRECTORY_PATH"
RUNFILE="ENTER_PATH_AND_FILE_NAME_OF_RUN_LIST"
OUTPUT_PREFIX="ENTER_OUTPUT_PREFIX_NAME"
NUMK="ENTER_MAX_K"
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: #

# Activate conda environment for snmf
conda activate snmf

# Load required modules (Plink 2.0)
module load plink/2.0

# Create output directory and change directory to output directory
cd ${PROJECT_FOLDER}/06_structure
mkdir -p pop_structure
cd pop_structure

# Job array: each job corresponds to a run
IFS=$'\n' read -d '' -r -a lines < ${RUNFILE}
RUN=${lines[${SLURM_ARRAY_TASK_ID}]}
# Define seed within the run
SEED=$(echo $RANDOM)

# 1. Convert input vcf file into sNMF geno file.
# The geno format file of sNMF has one row for each SNP. Each row contains 1 character per individual: 
# 0 means zero copies of the reference allele. 
# 1 means one copy of the reference allele. 
# 2 means two copies of the reference allele.
# 9 means missing data.

# Generate .traw file with the recode command in Plink
plink2 --vcf ${VCF} \
--recode A-transpose \
--out ${OUTPUT_PREFIX}_run${RUN}

# Select all but the first 6 columns of the .traw file, replace NA with 9 and tab with no character
grep -v "CHR" ${OUTPUT_PREFIX}_run${RUN}.traw | cut -f7- | sed -e s'/NA/9/g' -e s'/\t//g' > ${OUTPUT_PREFIX}_run${RUN}.geno

# 2. Run sNMF program
# -K number_of_ancestral_populations
# -c perc is the percentage of masked genotypes (default percentage is 5%)
# If this option is set, the cross-entropy criterion is calculated.
# -i iteration_number
# -s seed random init (default: random)
# -a alpha is the value of the regularization parameter (by default: 10)
# -p is the number of CPUs

# Output files are: createDataSet.log (log file) and *_I.geno (output geno file with masked data)
createDataSet -x ${OUTPUT_PREFIX}_run${RUN}.geno -o ${OUTPUT_PREFIX}_run${RUN}_I.geno > createDataSet_run${RUN}_I.log;

# sNMF command needs as input the masked_geno file (*_snmf_run_I.geno). Output files are sNMF_run_K.log (log file), *run_I.K.Q and *run_I.K.G
# command crossEntropy needs as inputs: original genotype file, *_I.K.Q and *_I.K.G. Output file is crossEntropy_run_K.log
echo "seed: "${SEED} "run:"${RUN} "k="${k} >> seed

for k in $(seq 1 ${NUMK});
do
    sNMF -x ${OUTPUT_PREFIX}_run${RUN}_I.geno -K ${k} -i 1000 -s ${SEED} -a 100 -p 32 > sNMF_run${RUN}_K${k}.log;
    crossEntropy -x ${OUTPUT_PREFIX}_run${RUN}.geno \
    -q ${OUTPUT_PREFIX}_run${RUN}_I.${k}.Q \
    -g ${OUTPUT_PREFIX}_run${RUN}_I.${k}.G \
    -i ${OUTPUT_PREFIX}_run${RUN}_I.geno \
    -K ${k} > crossEntropy_run${RUN}_K${k}.log
done

conda deactivate
