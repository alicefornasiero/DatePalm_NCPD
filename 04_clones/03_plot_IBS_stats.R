#!/usr/bin/env Rscript
#------------------------------------------------#
#            Generate IBS2het plot               # 
#            from SNPDuo analysis                #
#------------------------------------------------#

# Input files and variables
# -------------------------------------------------------------------------------------------------- #
# INDIR - Path to input directory containing the .summary output file of SNPDuo
# INPREFIX - Prefix name of the .summary input file from SNPDuo
# OUTPREFIX - Prefix name of output file (IBS2het plot)

INDIR = "/path/to/input/directory"
INPREFIX = "prefix_of_input_file"
OUTPREFIX = "prefix_of_output_file"
# -------------------------------------------------------------------------------------------------- #

# Install required packages
# install.packages(c("ggplot2", "readr"))

# Load libraries
library(ggplot2)
library(readr)

# Set output folder
setwd(INDIR)

# Input is .summary file generated with SNPDuo
sum_data <- read_csv(paste0(INPREFIX, ".summary"), col_names = TRUE)
colnames(sum_data) <- c("FID1", "IID1", "FID2", "IID2", "IBS0", "IBS1", "IBS2", "IBS2het", "Mean_IBS", "SD_IBS", "IBS2het_perc", "Informative_perc", "IBS2het_perc_Informative")

# IBS2het plot: Percent Informative SNPs (y-axis) vs IBS2het ratio (x-axis)

# Create two layers to plot to emphasize pairs of clones with respect to the other pairs
sum_data$relation <- "unknown"
sum_data$relation[sum_data$IBS2het_perc_Informative >= 0.95] <- "clone"
df_layer_1 <- sum_data[sum_data$relation == "unknown" ,]
df_layer_2 <- subset(sum_data, subset = relation %in% c("clone"))

outIBS2het <- paste0(OUTPREFIX, "_infosnps_ibs2hetratio.pdf")

p_IBS2het <- ggplot() +
    geom_point(
        data = df_layer_1,
        aes(x = IBS2het_perc_Informative, y = Informative_perc),
        shape = 21, color = "black",
        fill = "azure2", alpha = 0.5, size = 1.5) +
    geom_point(
        data = df_layer_2, 
        aes(x = IBS2het_perc_Informative, y = Informative_perc), 
        shape = 21, color = "black", 
        fill = "red", alpha = 0.5, size = 1.5) +
    scale_x_continuous(
        breaks = seq(0, 1, 0.1),
        name = "IBS2* ratio") +
    scale_y_continuous(
        breaks = round(seq(min(sum_data$Informative_perc), max(sum_data$Informative_perc), 0.02), 2),
        name = "Fraction of Informative SNPs") +
    geom_vline(xintercept = 0.70, color = "navyblue", linetype = "dashed", linewidth = 0.5) +
    theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14),
        panel.grid = element_line(color = "lightgrey"),
        panel.background = element_rect(fill = "white"),
        axis.line = element_line(linewidth = 0.5),
        legend.position = "none")

ggsave(outIBS2het, p_IBS2het)
