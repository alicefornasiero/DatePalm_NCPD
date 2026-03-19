#!/usr/bin/env Rscript
#------------------------------------------------------------#
#         Plot the scree plot of the eigenvalues and         #
#       the eigenvectors of the first three PCs.             #
#------------------------------------------------------------#

# Input files and variables
# -------------------------------------------------------------------------------------------------- #
# indir - Path to the input directory containing the eigenvalues and eigenvectors obtained with Plink
# inprefix - Prefix name of the .eigenval and .eigenvec input files from Plink
# groupfile - Tab separated file with two columns: sample name, population (header required)
# max_overlaps - Numeric value. Exclude text labels when they overlap more than max_overlap text 
#                labels or data points. Default: 10. No label printed: 0

indir = "/path/to/input/directory/with/eigenvalues/and/eigenvectors"
inprefix = "input_file_prefix"
groupfile = "/path/to/text_file"
max_overlaps = 0
# -------------------------------------------------------------------------------------------------- #

# Install required packages
# install.packages(c("tidyverse", "ggplot2", "ggrepel"))

# Load required libraries
library(tidyverse)
library(ggplot2)
library(ggrepel)

# Change directory to working directory
setwd(indir)
if (!dir.exists(indir)) stop("Input directory does not exist!")

# Read input files
# Read eigenvector input file
pca <- read_table(paste0(inprefix, ".eigenvec"), col_names = TRUE)
names(pca)[1] <- "sample"
# Read eigenvalues input file
eigenval <- scan(paste0(inprefix, ".eigenval"))
# Read file with information of population
group <- read_table(groupfile, col_names = TRUE)
colnames(group) <- c("sample", "pop")

# Convert eigenvalues into percentage of variance explained
pve <- data.frame(PC = 1:10, pve = eigenval/sum(eigenval)*100)

# Add population info to the pca
pca <- left_join(pca, group, by = "sample")

# Define color palette accordingly to results of population structure analysis
# Females
clist <- c("pop1" = "#CC6677", "pop2" = "#332288", "pop3" = "#DDCC77", "pop4" = "#117733", "admix" = "#BBBBBB")
# Males
# clist <- c("pop1" = "#EE7733", "pop2" = "#0077BB", "pop3" = "#EE3377", "admix" = "#BBBBBB")

# Plot scree plot
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

# Plot PC1 and PC2 and color samples according to population
outpca12 <- paste0(indir, "/", inprefix, ".PC1-PC2_pops.pdf")
pca_plot12 <- ggplot(pca, aes(PC1, PC2, fill = pop)) +
              geom_point(size = 3, alpha = 0.8, shape = 21, colour = "black") +
              geom_text_repel(label = pca$"sample",
                min.segment.length = 0.2,
                seed = 42, box.padding = 0.2,
                xlim = c(-Inf, Inf), ylim = c(-Inf, Inf),
                max.overlaps = max_overlaps, size = 1) +
              geom_vline(aes(xintercept = 0), linetype = "dashed", linewidth = 0.5) +
              geom_hline(aes(yintercept = 0), linetype = "dashed", linewidth = 0.5) +
              scale_x_continuous(name = paste0("PC1 (", signif(pve$pve[1], 3), "%)"),
                limits = c(min(pca$PC1)*1, max(pca$PC1)*1)) +
              scale_y_continuous(name = paste0("PC2 (", signif(pve$pve[2], 3), "%)"),
                limits = c(min(pca$PC2)*1, max(pca$PC2)*1)) +
              scale_fill_manual(values = clist,
                name = "Populations") +
              theme(axis.text = element_text(size = 12),
                axis.title = element_text(size = 14),
                panel.grid.minor = element_blank(),
                legend.text = element_text(size = 12),
                legend.title = element_text(size = 14))
ggsave(outpca12, pca_plot12, width = 7, height = 7, units = "in")

# Plot PC1 and PC3 and color samples according to population
outpca13 <- paste0(indir, "/", inprefix, ".PC1-PC3_pops.pdf")
pca_plot13 <- ggplot(pca, aes(PC1, PC3, fill = pop)) +
              geom_point(size = 3, alpha = 0.8, shape = 21, colour = "black") +
              geom_text_repel(label = pca$"sample",
                min.segment.length = 0.2,
                seed = 42, box.padding = 0.2,
                xlim = c(-Inf, Inf), ylim = c(-Inf, Inf),
                max.overlaps = max_overlaps, size = 1) +
              geom_vline(aes(xintercept = 0), linetype = "dashed", linewidth = 0.5) +
              geom_hline(aes(yintercept = 0), linetype = "dashed", linewidth = 0.5) +
              scale_x_continuous(name = paste0("PC1 (", signif(pve$pve[1], 3), "%)"),
                limits = c(min(pca$PC1)*1, max(pca$PC1)*1)) +
              scale_y_continuous(name = paste0("PC3 (", signif(pve$pve[3], 3), "%)"),
                limits = c(min(pca$PC3)*1, max(pca$PC3)*1)) +
              scale_fill_manual(values = clist,
                name = "Populations") +
              theme(axis.text = element_text(size = 12),
                axis.title = element_text(size = 14),
                panel.grid.minor = element_blank(),
                legend.text = element_text(size = 12),
                legend.title = element_text(size = 14))
ggsave(outpca13, pca_plot13, width = 7, height = 7, units = "in")

# Plot PC2 and PC3 and color samples according to population
outpca23 <- paste0(indir, "/", inprefix, ".PC2-PC3_pops.pdf")
pca_plot23 <- ggplot(pca, aes(PC2, PC3, fill = pop)) +
              geom_point(size = 3, alpha = 0.8, shape = 21, colour = "black") +
              geom_text_repel(label = pca$"sample",
                min.segment.length = 0.2,
                seed = 42, box.padding = 0.2,
                xlim = c(-Inf, Inf), ylim = c(-Inf, Inf),
                max.overlaps = max_overlaps, size = 1) +
              geom_vline(aes(xintercept = 0), linetype = "dashed", linewidth = 0.5) +
              geom_hline(aes(yintercept = 0), linetype = "dashed", linewidth = 0.5) +
              scale_x_continuous(name = paste0("PC2 (", signif(pve$pve[2], 3), "%)"),
                limits = c(min(pca$PC2)*1, max(pca$PC2)*1)) +
              scale_y_continuous(name = paste0("PC3 (", signif(pve$pve[3], 3), "%)"),
                limits = c(min(pca$PC3)*1, max(pca$PC3)*1)) +
              scale_fill_manual(values = clist,
                name = "Populations") +
              theme(axis.text = element_text(size = 12),
                axis.title = element_text(size = 14),
                panel.grid.minor = element_blank(),
                legend.text = element_text(size = 12),
                legend.title = element_text(size = 14))
ggsave(outpca23, pca_plot23, width = 7, height = 7, units = "in")
