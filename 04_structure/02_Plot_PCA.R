#!/usr/bin/env Rscript
#------------------------------------------------------------#
#         Plot the scree plot of the eigenvalues and         #
#       the eigenvectors of the first three PCs.             #
#------------------------------------------------------------#

# Input files and variables
# -------------------------------------------------------------------------------------------------- #
# indir - Path to the input directory containing the eigenvalues and eigenvectors obtained with Plink
# inprefix - Prefix name of the .eigenval and .eigenvec input files from Plink
# max_overlaps - Numeric value. Exclude text labels when they overlap more than max_overlap text 
#                labels or data points. Default: 10. No label printed: 0

indir = "/path/to/input/directory/with/eigenvalues/and/eigenvectors"
inprefix = "input_file_prefix"
max_overlaps = 0
# -------------------------------------------------------------------------------------------------- #

# Install required packages
# install.packages(c("tidyverse", "ggplot2", "ggrepel", "RColorBrewer"))

# Load required libraries
library(tidyverse)
library(ggplot2)
library(ggrepel)
library(RColorBrewer)

# Change directory to working directory
setwd(indir)
if (!dir.exists(indir)) stop("Input directory does not exist!")

# Read input files
pca <- read_table(paste0(inprefix, ".eigenvec"), col_names = TRUE)
names(pca)[1] <- "sample"
eigenval <- scan(paste0(inprefix, ".eigenval"))

# Sort out the individual species and pops
pca <- pca %>%
  mutate(spp = case_when(
    str_detect(sample, "Male-") ~ "Male",
    str_detect(sample, "F1-")   ~ "F1",
    TRUE                       ~ "Female"
  ))

# Define colors for each sample category
cols <- c("Male" = "blue", "F1" = "purple", "Female" = "darkorange1")

# Convert eigenvalues into percentage of variance explained
pve <- data.frame(PC = 1:10, pve = eigenval/sum(eigenval)*100)

# Plot scree plot
# Define output file name
outscree <- paste0(indir, "/", inprefix, "_screeplot.pdf")

scree_plot <- ggplot(pve, aes(PC, pve)) + geom_bar(stat = "identity") +
                scale_x_continuous(expand = c(0, 0), 
                  name = "Principal Components", 
                  breaks = seq(0, 20, 1)) +
                scale_y_continuous(expand = c(0, 0), 
                  name = "Percentage variance explained", 
                  breaks = seq(0, ceiling(max(pve$pve)), 3), 
                  limits = c(0, ceiling(max(pve$pve)) + 2)) +
                theme(axis.text = element_text(size = 12),
                  axis.title = element_text(size = 14),
                  panel.grid.minor = element_blank())
ggsave(outscree, scree_plot)

# Plot eigenvectors of PC1 and PC2
# Define output file name
outpca12 <- ifelse(max_overlaps == 0, 
                   paste0(indir, "/", inprefix, ".PC1-PC2_nolabs.pdf"), 
                   paste0(indir, "/", inprefix, ".PC1-PC2.pdf"))

pca_plot12 <- ggplot(pca, aes(PC1, PC2, col = spp)) + 
              geom_point(size = 1.5, alpha = 0.5) +
              geom_text_repel(label = pca$"sample", 
                min.segment.length = 0.2, 
                seed = 42, box.padding = 0.2, 
                xlim = c(-Inf, Inf), ylim = c(-Inf, Inf), 
                max.overlaps = max_overlaps, size = 2) + 
              scale_colour_manual(values = cols, name = NULL) +
              geom_vline(aes(xintercept = 0), linetype = "dashed", linewidth = 0.5) +
              geom_hline(aes(yintercept = 0), linetype = "dashed", linewidth = 0.5) +
              scale_x_continuous(name = paste0("PC1 (", signif(pve$pve[1], 3), "%)"),
                limits = c(min(pca$PC1)*1, max(pca$PC1)*1)) +
              scale_y_continuous(name = paste0("PC2 (", signif(pve$pve[2], 3), "%)"),
                limits = c(min(pca$PC2)*1, max(pca$PC2)*1)) +
              theme(axis.text = element_text(size = 12),
                axis.title = element_text(size = 14),
                panel.grid.minor = element_blank(),
                legend.text = element_text(size = 14))
ggsave(outpca12, pca_plot12, width = 7, height = 7, units = "in")

# Plot  eigenvectors of PC1 and PC3 
# Define output file name
outpca13 <- ifelse(max_overlaps == 0, 
                   paste0(indir, "/", inprefix, ".PC1-PC3_nolabs.pdf"), 
                   paste0(indir, "/", inprefix, ".PC1-PC3.pdf"))

pca_plot13 <- ggplot(pca, aes(PC1, PC3, col = spp)) + 
              geom_point(size = 1.5, alpha = 0.5) +
              geom_text_repel(label = pca$"sample", 
                min.segment.length = 0.2, 
                seed = 42, box.padding = 0.2, 
                xlim = c(-Inf, Inf), ylim = c(-Inf, Inf), 
                max.overlaps = max_overlaps, size = 2) +
              scale_colour_manual(values = cols, name = NULL) +
              geom_vline(aes(xintercept = 0), linetype = "dashed", linewidth = 0.5) +
              geom_hline(aes(yintercept = 0), linetype = "dashed", linewidth = 0.5) +
              scale_x_continuous(name = paste0("PC1 (", signif(pve$pve[1], 3), "%)"),
                limits = c(min(pca$PC1)*1, max(pca$PC1)*1)) +
              scale_y_continuous(name = paste0("PC3 (", signif(pve$pve[3], 3), "%)"),
                limits = c(min(pca$PC3)*1, max(pca$PC3)*1)) +
              theme(axis.text = element_text(size = 12),
                axis.title = element_text(size = 14),
                panel.grid.minor = element_blank(),
                legend.text = element_text(size = 14))
ggsave(outpca13, pca_plot13, width = 7, height = 7, units = "in")

# Plot eigenvectors of PC2 and PC3 
# Define output file name
outpca23 <- ifelse(max_overlaps == 0, 
                   paste0(indir, "/", inprefix, ".PC2-PC3_nolabs.pdf"), 
                   paste0(indir, "/", inprefix, ".PC2-PC3.pdf"))

pca_plot23 <- ggplot(pca, aes(PC2, PC3, col = spp)) + 
              geom_point(size = 1.5, alpha = 0.5) +
              geom_text_repel(label = pca$"sample", 
                min.segment.length = 0.2, 
                seed = 42, box.padding = 0.2, 
                xlim = c(-Inf, Inf), ylim = c(-Inf, Inf), 
                max.overlaps = max_overlaps, size = 2) +
              scale_colour_manual(values = cols, name = NULL) +
              geom_vline(aes(xintercept = 0), linetype = "dashed", linewidth = 0.5) +
              geom_hline(aes(yintercept = 0), linetype = "dashed", linewidth = 0.5) +
              scale_x_continuous(name = paste0("PC2 (", signif(pve$pve[2], 3), "%)"),
                limits = c(min(pca$PC2)*1, max(pca$PC2)*1)) +
              scale_y_continuous(name = paste0("PC3 (", signif(pve$pve[3], 3), "%)"),
                limits = c(min(pca$PC3)*1, max(pca$PC3)*1)) +
              theme(axis.text = element_text(size = 12),
                axis.title = element_text(size = 14),
                panel.grid.minor = element_blank(),
                legend.text = element_text(size = 14))
ggsave(outpca23, pca_plot23, width = 7, height = 7, units = "in")
