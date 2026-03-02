#!/usr/bin/env Rscript
#--------------------------------------------------------------------------------#
#         Plot the cross-entropy criterion to infer the best estimate of K.      #
# Generate barplots of population structure representing the estimted individual #
#                         admixture coefficients.                                #
#--------------------------------------------------------------------------------#

# Input files and variables
# ---------------------------------------------------------------------------------------------- #
# indir - Path to the input directory containing the Q matrices obtained with sNMF analysis
# outprefix - Prefix name of the output files
# labelfile - File containing the sample names used in sNMF (one per line), in the same order
# tot_run -  The total number of runs to be plotted
# tot_k - The total number of Ks to be plotted

indir = "/path/to/input/directory/with/Q/matrices"
outprefix = "output_file_prefix"
labelfile = "original_sample_order_in_sNMF_analysis"
tot_run = 10
tot_k = 4
# ---------------------------------------------------------------------------------------------- #

# Install required packages
# install.packages(c("pophelper", "gridExtra"))

# Load required libraries
library(pophelper)
library(gridExtra)

#-----------------------------------#
# 1. K-plot of Cross Entropy values #
#-----------------------------------#

# Read cross-entropy txt file and order lines numerically
crossentr <- read.table("K_vs_CrossEntropy.txt", header = TRUE, stringsAsFactors = FALSE)
crossentr <- crossentr[order(crossentr$K), ]

# Generate output file name and open pdf device
outfile <- paste(getwd(), "K_vs_CrossEntropy.pdf", sep="/")
pdf(outfile, width = 7, height = 7)

# Define color-blind friendy color palette
clist <- c("#CC6677", "#332288", "#DDCC77", "#117733", "#88CCEE", "#882255", "#44AA99", "#999933", "#00A0B0", "#6A4A3C", "#CC333F", "#EB6841", "#EDC951")

# Plot
# Plot lines
plot(crossentr$K, crossentr$Cross_Entropy, 
     type = "lines", 
     lwd = 2,
     col = "blue", 
     axes = FALSE, 
     ann = FALSE)
# Plot data points
points(crossentr$K, crossentr$Cross_Entropy,
       pch = 20, 
       cex = 1.5, 
       col = "blue")
# Plot title, x- and y-axis labels
title(xlab = "K, number of ancestral populations", 
      ylab = "Min Cross-Entropy", 
      cex.lab = 1.5)
# Define x-axis parameters
axis(side = 1, 
     at = seq(1, tot_k, by = 1), 
     labels = TRUE, cex.axis = 1.2)
# Define y-axis parameters
axis(side = 2, 
     at = round(seq(min(crossentr$Cross_Entropy), max(crossentr$Cross_Entropy), by = 0.01), 2), 
     cex.axis = 1.2)

dev.off()

#------------------------------------#
# 2. Barplot of population structure #
#------------------------------------#

# Check input directory
setwd(indir)
if (!dir.exists(indir)) stop("Input directory does not exist!")

# Create the list of input files (Q files)
sfiles <- list.files(path = indir, pattern = ".Q", full.names = TRUE)

# Read input files
slist <- readQ(files = sfiles, filetype = "basic")

# Individual labels
inds <- read.delim(file = labelfile, header = FALSE, stringsAsFactors = FALSE)
# add individual labels to all runs
slist <- lapply(slist, "rownames<-", inds$V1)

#######
# 2.1 # Plot barplots for the same k (across runs)
#######
# Sort individuals
# Individuals are by default plotted in the order as in the input data. 
# The individuals can be sorted based on the value of any one of the clusters (‘Cluster1’), ‘all’ or ‘label’. 
# When using sortind="label", individuals are sorted by individual labels. 
# Individuals are labelled numerically padded with zeros when useindlab=F. 
# Labels are taken from the qlist when useindlab=T.

# Define function "plot_k" to plot the same K result across all runs
plot_k <- function(k_id = 2 : tot_k, slist, outprefix) {

  # Indices for this run (e.g. 3 13 23 33 43 53 63 73 83 93)
  idx <- grep(paste0("_I\\.", k_id, "\\.Q$"), sfiles)
  # Select data for the current k across runs
  slist_run <- alignK(slist[idx])
  
  plotQ(
    slist_run,
    imgoutput = "join",
    sortind = "all", sharedindlab = FALSE,
    returnplot = FALSE, exportplot = TRUE,
    basesize = 11,
    clustercol = clist,

    # Two-line strip panel label
    splab = paste0("run", seq_len(tot_run), "\n", "K = ", k_id),

    # Individual labels
    showindlab = TRUE, useindlab = TRUE,
    showyaxis = TRUE, showticks = TRUE,
    indlabangle = 90, indlabsize = 6,

    # Legend
    showlegend = TRUE,
    legendkeysize = 8,
    legendtextsize = 10,
    legendlab = paste0("group ", 1 : k_id),

    # Export
    outputfilename = paste0(outprefix, "_K", k_id, "_allruns"),
    imgtype = "pdf",
    height = 5, width = 30,
    exportpath = getwd()
  )
}

plot_each_k <- lapply(1 : tot_run, 
                   plot_k,
                   slist = slist,
                   outprefix = outprefix)

#######
# 2.2 # Plot barplots for the same run (across Ks)
#######

# Open Q matrix files from k=2 to tot_k
runlist <- readQ(
  files = unlist(lapply(2 : tot_k, function(k)
    list.files(path = indir, pattern = paste0(k, "\\.Q"), full.names = TRUE)
  )),
  filetype = "basic"
)

# Individual labels
runlist <- lapply(runlist, "rownames<-", inds$V1)

# Define function "plot_run" to plot all ks for each run
plot_run <- function(run_id, runlist, tot_k, outprefix) {

  # Extract all the files of the current run
  idx <- grep(paste0("_run", run_id, "_I\\."), rownames(summary(runlist)))
  runlist <- alignK(runlist[idx])
  
  plotQ(
    runlist,
    imgoutput = "join",
    sortind = "all", sharedindlab = FALSE,
    returnplot = FALSE, exportplot = TRUE,
    basesize = 11,
    clustercol = clist,

    # Two-line strip panel label
    splab = paste0("run", run_id, "\nK = ", 2 : tot_k),

    # Individual labels
    showindlab = TRUE, useindlab = TRUE,
    showyaxis = TRUE, showticks = TRUE,
    indlabangle = 90, indlabsize = 6,

    # Legend
    showlegend = TRUE,
    legendkeysize = 8,
    legendtextsize = 10,
    legendlab = paste0("group ", 1 : tot_k),

    # Export
    outputfilename = paste0(outprefix, "_allKs_run", run_id),
    imgtype = "pdf",
    height = 5, width = 30,
    exportpath = getwd()
  )
}

plot_each_run <- lapply(0 : (tot_run-1), 
                   plot_run,
                   runlist = runlist,
                   tot_k = tot_k,
                   outprefix = outprefix)

#######
# 2.3 # Barplot by K for all runs
#######

allkruns <- plotQ(alignK(runlist),
        imgoutput = "join",
        # sharedindlab must be set to FALSE when sorting individuals
        sortind = "all", sharedindlab = FALSE,
        returnplot = FALSE, exportplot = TRUE, 
        basesize = 11,
        clustercol = clist,

        # Two-line strip panel label
        splab = paste0("K = ", rep(c(2 : tot_k), each = tot_run), "\nrun", seq(1, tot_run)),

        # Individual labels
        showindlab = TRUE, useindlab = TRUE, 
        showyaxis = TRUE, showticks = TRUE,
        indlabangle = 90, indlabsize = 6,

        # Show legend
        showlegend = TRUE, 
        legendkeysize = 8, 
        legendtextsize = 10,
        legendlab = paste0("group ", 1 : tot_k),

        # Export file
        outputfilename = paste0(outprefix, "_allKs_allruns"),
        imgtype = "pdf", 
        height = 5, 
        width = 30, 
        exportpath = getwd()
        )
