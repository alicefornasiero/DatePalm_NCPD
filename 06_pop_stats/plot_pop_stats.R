#!/usr/bin/env Rscript
#------------------------------------------------------------#
#             Plot population genetics statistics            #
#------------------------------------------------------------#

# Input files and variables
# ---------------------------------------------- #
# indir - Path to the input directory containing pop gene statstics obtained with clam
# plot_title - Title text for the output plot

indir = "/path/to/folder/containing/clam/pop_gen_stats"
het_in="heterozygosity_sorted.tsv"
pi_in="pi_sorted.tsv"
dxy_in="dxy_sorted.tsv"
fst_in="fst_sorted.tsv"
plot_title="Plot Title"
# ---------------------------------------------- #

# Install required packages
# install.packages(c("ggplot2", "tidyverse", "forcats", "RColorBrewer"))

# Load modules
library(tidyverse)
library(ggplot2)
library(forcats)
library(RColorBrewer)

# Set working directory
setwd(indir)

# Read input files
pi <- read_table(pi_in, col_names = c("chrom", "start", "end", "population", "pi", "comparisons", "differences"))
fst <- read_table(fst_in, col_names = c("chrom", "start", "end", "population1", "population2", "fst"))

# Remove lines with NA values
pi_clean <- pi[complete.cases(pi), ]
fst[fst=='NaN'] <- NA
fst_clean <- fst[complete.cases(fst), ]
# Make the fst value as numeric
fst_clean$fst<-as.numeric(fst_clean$fst)

# Define output file names
pi_out_chr <- paste0(indir, "/", sub(".tsv", "_chromosomes.pdf", pi_in))
pi_out_box <- paste0(indir, "/", sub(".tsv", "_boxplot.pdf", pi_in))
fst_out_box <- paste0(indir, "/", sub(".tsv", "_boxplot.pdf", fst_in))

# Calculate midpoint for each window
pi$mid <- pi$start + (pi$end - pi$start)/2

# Plot pi along the chromosomes by population
plot_pi <- ggplot(pi_clean, aes(x = mid / 1000000, y = pi, color = population)) +
    geom_line(linewidth = 0.4) +
    facet_grid(chrom ~ . , scales = "fixed") +
    scale_x_continuous(expand = c(0, 0),
      breaks = round(seq(min(pi_clean$start/1000000, na.rm = TRUE), max(pi_clean$start/1000000, na.rm = TRUE), 5),0)
                      ) +
    scale_y_continuous(expand = c(0, NA)
                      ) +
    scale_color_brewer(palette = "Set2") +
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
      legend.key.size= unit(1.5, 'cm')
         )

ggsave(pi_out_chr, plot_pi, width = 8, height = 12)

# Plot pi by population as a boxplot
plot_pi_box <- pi_clean %>%
    mutate(population = fct_reorder(population, pi, .fun = 'median')
          ) %>%
    ggplot( aes(x = as.factor(population), y = pi, fill = population)) +
    geom_boxplot(width = 0.3, alpha = 0.5) +
    scale_y_continuous(breaks = round(seq(min(pi_clean$pi, na.rm = TRUE), max(pi_clean$pi, na.rm = TRUE), 0.002),3)
                      ) +
    scale_color_brewer(palette = "Set2") +
    labs(title = plot_title, x = "", y = expression(pi)) +
    theme_minimal() +
    theme(axis.text = element_text(size = 12),
      axis.title = element_text(size = 14),
      legend.position = "none"
         )

ggsave(pi_out_box, plot_pi_box, width = 5, height = 7)

# Plot fst by population as a boxplot
fst_clean$pop_pair <- paste0(fst_clean$population1, "-", fst_clean$population2)

fst_boxplot <- fst_clean %>%
    mutate(pop_pair = fct_reorder(pop_pair, fst, .fun = 'median')) %>%
    ggplot(aes(x = as.factor(pop_pair), y = fst)) +
    geom_boxplot(width = 0.3, alpha = 0.5, fill = "darkcyan") +
    scale_y_continuous(breaks = round(seq(min(fst_clean$fst, na.rm = TRUE), max(fst_clean$fst, na.rm = TRUE), 0.2),1)
                        ) +
    scale_color_brewer(palette = "Set2") +
    labs(title = plot_title, x = "", y = expression(italic(F)[ST])) +
    theme_minimal() +
    theme(
      axis.text = element_text(size = 12),
      axis.text.x = element_text(angle = 45, hjust = 1),
      axis.title = element_text(size = 14),
      legend.position = "none"
    )

ggsave(fst_out_box, fst_boxplot, width = 5, height = 7)
