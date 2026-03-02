#!/usr/bin/env Rscript
#------------------------------------------------------------#
#             Plot pi distribution in populations            #
#------------------------------------------------------------#

# Input files and variables
# ---------------------------------------------- #
# indir - Path to the input directory containing pi statistics obtained with clam
# pi_in - File name of pi statistics computed with clam
# plot_title - Title text for the output plot

indir = "/path/to/folder/containing/clam/pop_gen_stats"
pi_in = "pi_sorted.tsv"
plot_title = "Plot Title"
# ---------------------------------------------- #

# Install required packages
# install.packages(c("ggplot2", "tidyverse", "forcats"))

# Load modules
library(tidyverse)
library(ggplot2)
library(forcats)

# Set working directory
setwd(indir)

# Read input files
pi <- read_table(pi_in, col_names = c("chrom","start","end","population","pi","comparisons","differences"))

# Remove lines with NA values
pi_clean <- pi[complete.cases(pi), ]

# Define output file names
pi_out_chr <- paste0(indir, "/", sub(".tsv", "_chromosomes.pdf", pi_in))
pi_out_box <- paste0(indir, "/", sub(".tsv", "_boxplot.pdf", pi_in))

# Calculate midpoint for each window
pi_clean$mid <- pi_clean$start + (pi_clean$end - pi_clean$start)/2

# Create color-blind palette colors for Females and Males using colors from the khroma package
# Females (muted and oceanfive)
clist <- c("#CC6677", "#332288", "#DDCC77", "#117733", "#88CCEE", "#882255", "#44AA99", "#999933", "#00A0B0", "#6A4A3C", "#CC333F", "#EB6841", "#EDC951")
# Males (vibrant and highcontrast)
# clist <- c("#EE7733", "#0077BB", "#EE3377", "#CC3311", "#009988", "#33BBEE", "#004488", "#DDAA33", "#BB5566", "#BBBBBB")

# Plot pi by population along the chromosomes
plot_pi <- ggplot(pi_clean, aes(x = mid / 1000000, y = pi, color = population)) +
             geom_line(linewidth = 0.4, alpha = 0.8) +
             facet_grid( chrom ~ ., scales = "fixed") +
             scale_x_continuous(expand = c(0, 0),
               breaks = round(seq(min(pi_clean$start/1000000, na.rm = TRUE), 
                                  max(pi_clean$start/1000000, na.rm = TRUE), 5),0)) +
             scale_y_continuous(expand = c(0, NA)) +
             scale_color_manual(values = clist) +
             labs(x = "Position (Mbp)", y = expression(pi), color = "Population") +
             theme_minimal() +
             theme(axis.text = element_text(size = 7),
               axis.title = element_text(size = 12),
               strip.background = element_blank(), 
               strip.placement = "outside",
               legend.position = "bottom",
               legend.text = element_text(size = 12),
               legend.title = element_blank(),
               panel.spacing = unit(1, "lines"),
               panel.grid.major = element_line(linewidth = 0.2),
               panel.grid.minor = element_blank(),
               legend.key.size= unit(1.5, 'cm'))

ggsave(pi_out_chr, plot_pi, width = 8, height = 12)

# Plot pi by population as a boxplot
plot_pi_box <- pi_clean %>%
        mutate(population = fct_reorder(population, pi, .fun = 'median')) %>%
        ggplot( aes(x = as.factor(population), y = pi, fill = population)) +
          geom_boxplot(width = 0.3, alpha = 0.5) +
          scale_y_continuous(breaks = round(seq(min(pi_clean$pi, na.rm = TRUE), 
                                                max(pi_clean$pi, na.rm = TRUE), 0.002),3)) +
          scale_fill_manual(values = clist) +
          labs(title = plot_title, x = "", y = expression(pi)) +
          theme_minimal() +
          theme(axis.text = element_text(size = 12),
            axis.title = element_text(size = 14),
            legend.position = "none"
               )

ggsave(pi_out_box, plot_pi_box, width = 5, height = 7)
