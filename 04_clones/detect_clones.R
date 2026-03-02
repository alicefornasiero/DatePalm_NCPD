#!/usr/bin/env Rscript
#------------------------------------------------------------#
#        Define genetically identical individuals            #
#         (clones) using Identity-by-State (IBS)             #
#------------------------------------------------------------#

# https://bioconductor.org/packages/release/bioc/vignettes/SNPRelate/inst/doc/SNPRelate.html

# Input files and variables
# ---------------------------------------------- #
# indir - Path to the input directory containing input PLINK text/binary files (either PED or BED)
# infile - Prefix name of the PLINK text/binary files (either PED or BED)
# sampleAnnot - File name and path of a .txt file with two columns: original_sample_order, sample_label. Useful if you want to print prettier labels
# outfolder - Path to output directory
# zscore - Z threshold 
# num_threads - number of threads for parallel processing

indir = "/path/to/input/directory/with/bed/or/ped/files"
infile = "input_file_name_without_extension"
sampleAnnot = "/path/to/text/file/with/sample/labels/sample_order_label.txt"
outfolder = "/path/to/output/directory"
zscore = 25
num_threads = 2
# ---------------------------------------------- #

# Install required packages
# install.packages(c("tidyverse", "gdsfmt", "SNPRelate", "ggplot2", "RColorBrewer")

# Load libraries
library(tidyverse)
library(gdsfmt)
library(SNPRelate)
library(ggplot2)
library(RColorBrewer)

# Move to working directory
setwd(indir)

# Format conversion from PLINK text/binary files
# The SNPRelate package provides a function snpgdsPED2GDS() and snpgdsBED2GDS() for converting a PLINK text/binary file to a GDS file:
bed.fn <- paste0(infile, ".bed") 
fam.fn <- paste0(infile, ".fam")
bim.fn <- paste0(infile, ".bim")

# Define gds file path
gds_file <- paste0(infile, ".gds")

# Convert bed file into SNP GDS file (only once)
if (!file.exists(gds_file)) {
    gds_file <- snpgdsBED2GDS(bed.fn, fam.fn, bim.fn, gds_file, cvt.chr = "char")
    }

# Open GDS file
geno <- snpgdsOpen(gds_file)

# Read sample name list
label_df <- read.table(sampleAnnot, header = TRUE)
colnames(label_df) <- c("orig_name", "labels")

# Create a copy of gds_file that can be overwritten (geno is read-only)
genotoplot <- snpgdsOpen(gds_file, readonly = FALSE, allow.duplicate = TRUE)
# Replace sample ids with final sample labels from the sampleAnnot file
add.gdsn(genotoplot, name = "sample.id", val = label_df$labels, replace = TRUE)

# Create color-blind friendly color palette
clist <- c("#CC6677", "#332288", "#DDCC77", "#117733", "#88CCEE", "#882255", "#44AA99", "#999933", "#00A0B0", "#6A4A3C", "#CC333F", "#EB6841", "#EDC951")

# Identity-By-State(IBS) proportion (function snpgdsIBS): Calculate the fraction of identity by state for each pair of samples
# The values of the IBS matrix range from 0 to 1 (1: an individual against itself), and it is defined as the average of:
# 1 - | g_{1,i} - g_{2,i} | / 2 
# across the genome for individuals 1 and 2 at SNP i.
IBSMatrix <- snpgdsIBS(genotoplot, sample.id = NULL, snp.id = NULL, autosome.only = FALSE,
    remove.monosnp = TRUE, maf = NaN, missing.rate = NaN, num.thread = num_threads,
    useMatrix = TRUE, verbose = TRUE)

# Save the dissimilarity matrix
write.table(as.matrix(IBSMatrix$ibs), 
    paste0(outfolder, "/", infile, "_SNPRel_IBS_Matrix.txt"), 
    sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE)

# Perform cluster analysis on the n×n matrix of genome-wide IBS pairwise distances:
snpHCluster <- snpgdsHCluster(IBSMatrix, sample.id = NULL, need.mat = TRUE, hang = 0.02)

# Determine groups by permutations:
cutTree <- snpgdsCutTree(snpHCluster, z.threshold = zscore, outlier.n = 0, n.perm = 5000, samp.group = NULL, 
             col.list = clist, pch.list = NULL, label.H = FALSE, label.Z = FALSE, verbose = TRUE)

# Plot tree
pdf(paste0(outfolder, "/", infile, "_Z", zscore, ".pdf"), width = 14, height = 7)
par(cex.axis = 1.2, cex = 0.7, oma = c(2, 1, 2, 1))
snpgdsDrawTree(cutTree, main = "", 
    edgePar = list(col = rgb(0.5,0.5,0.5,0.75), t.col = "black"),
    shadow.col = c(rgb(0.5, 0.5, 0.5, 0.05), rgb(0.5, 0.5, 0.5, 0.25)),
    yaxis.height = TRUE,
    yaxis.kinship = FALSE,
    y.label.kinship = FALSE, 
    outlier.n = NULL, 
    leaflab = "perpendicular"
    )
dev.off()

# Close gds file
snpgdsClose(geno)
