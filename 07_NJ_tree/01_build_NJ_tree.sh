#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=batch
#SBATCH -J VCF2DIS
#SBATCH -o VCF2DIS.%J.out
#SBATCH -e VCF2DIS.%J.err
#SBATCH --time=10:00:00
#SBATCH --mem=30G

# Calculate pairwise genetic distance from VCF files with VCF2Dis and build NJ tree using EMBOSS tool Phylipnew 

# ----------------------------------------------------------------------- #
# VCF - Path and file name of the input multi-sample vcf file
# OUTDIR - Path to otput folder
# VCF2DIS - Path to VCF2Dis program executable
# LABELFILE - Path and file name of sample name labels
# OUTPREFIX - Prefix of the output files
# RAND - Fraction (0-1] of sites to be randomly included in the calculation of genetic distance

VCF="ENTER_INPUT_VCF_FILE"
OUTDIR="ENTER_OUTPUT_FOLDER_PATH"
VCF2DIS="ENTER_PATH_TO_VCF2DIS_EXE"
LABELFILE="ENTER_PATH_AND_FILE_NAME_OF_SAMPLE_LABELS"
OUTPREFIX="ENTER_OUTPUT_PRPEFIX"
RAND="ENTER_FRACTION"
# ----------------------------------------------------------------------- #

# Activate conda env for phylipnew software from EMBOSS
conda activate phylip

# Generate an array to launch the SNP filtering on the chromosomes simultaneously
IFS=$'\n' read -d '' -r -a lines < ${OUTDIR}/run.list
X=${lines[${SLURM_ARRAY_TASK_ID}]}
# Generate an odd seed with shuf. Start at 1, end at 32767, pick 1 number, increment by 2
SEED=$(( (RANDOM % 32767) | 1 ))

# Write the file with seeds
echo "run "$X": seed "$SEED > ${OUTDIR}/run_${X}_seed

# Run NN times by using a method of sampling with replacement [-Rand]
${VCF2DIS} -InPut ${VCF} -OutPut ${OUTDIR}/${OUTPREFIX}_p_dis_${X}.mat -Rand ${RAND}

# Build NJ trees with fneighbor from embassy
fneighbor \
  -datafile ${OUTDIR}/${OUTPREFIX}_p_dis_${X}.mat \
  -outfile ${OUTDIR}/${OUTPREFIX}_tree.${X}.fneighbor \
  -matrixtype s \
  -seed ${SEED} \
  -treetype n \
  -trout \
  -outtreefile ${OUTDIR}/${OUTPREFIX}_p_dis_${X}.treefile \
  -progress Y

# Merge the nj-trees and construct and display a boostrap nj-tree
cat ${OUTDIR}/${OUTPREFIX}_p_dis_*.treefile > ${OUTDIR}/${OUTPREFIX}_alltree_merged.treefile

# The lengths on the tree in the output tree file are not branch lengths but the number of times that each group appeared in the input trees. 
# This number is the sum of the weights of the trees in which it appeared. 
fconsense \
  -intreefile ${OUTDIR}/${OUTPREFIX}_alltree_merged.treefile \
  -outfile ${OUTDIR}/${OUTPREFIX}_alltree_merged.fconsense \
  -method mre \
  -treeprint Y
