#!/usr/bin/env Rscript
#--------------------------------------------------------------------#
#         Plot nucleotide diversity (pi) per population              #
#--------------------------------------------------------------------#

# Input files and variables
# ----------------------------------------------------------------------------------------------------- #
# indir - Path to directory containing population-level pi_sorted.tsv file from clam analysis
# plot_title - Title text for the output plot
# win_size - Window size in bp used in clam analysis

indir = "path/to/clam/population/output/directory"
plot_title = "Plot title"
win_size = 100000
# ---------------------------------------------------------------------------------------------------- #

# Install required packages
# install.packages(c("tidyverse", "ggplot2", "forcats"))

# Load modules
library(tidyverse)
library(ggplot2)
library(forcats)

# Set working directory
setwd(indir)

# Read input files
pi <- read_table("pi_sorted.tsv", col_names = c("chrom","start","end","population","pi","comparisons","differences"))

# Remove lines with NA values
pi_clean <- pi[complete.cases(pi), ]

# Define output file names
pi_out_box <- paste0(indir, "/", sub(".tsv", "_boxplot.pdf", "pi_sorted.tsv"))
pi_out_chr_box <- paste0(indir, "/", sub(".tsv", "_chr_boxplot.pdf", "pi_sorted.tsv"))

# Define color palette accordingly to results of population structure analysis
# Females
clist <- c("pop1" = "#CC6677", "pop2" = "#332288", "pop3" = "#DDCC77", "pop4" = "#117733")
# Males
# clist <- c("pop1" = "#EE7733", "pop2" = "#0077BB", "pop3" = "#EE3377")

# Plot whole genome pi per population as a boxplot
plot_pi_box <- pi_clean %>%
        # Drop the admix group
        filter(population != "admix") %>%
        # fct_relevel for manual ordering
        mutate(population = fct_relevel(population, "pop1", "pop2", "pop3", "pop4") %>% 
          fct_drop()) %>%
        ggplot( aes(x = as.factor(population), y = pi, fill = population)) +
          geom_boxplot(width = 0.5, alpha = 0.8, position = position_dodge(width = 0.9)) +
          scale_y_continuous(breaks = round(seq(min(pi_clean$pi, na.rm = TRUE),
                                                max(pi_clean$pi, na.rm = TRUE), 0.002),3)) +
          scale_fill_manual(values = clist) +
          labs(title = plot_title, x = "", y = expression(pi ~ "in 100 kb windows")) +
          theme_minimal() +
          theme(axis.text = element_text(size = 12),
            axis.title = element_text(size = 14),
            legend.position = "none",
            panel.grid.major.x = element_blank()
            )
ggsave(pi_out_box, plot_pi_box, width = 5, height = 7)

# Plot pi distribution per population per chromosome as a boxplot
plot_pi_chr_box <- pi_clean %>%
        # Drop the admix group
        filter(population != "admix") %>%
        # fct_relevel for manual ordering
        mutate(population = fct_relevel(population, "pop1", "pop2", "pop3", "pop4") %>% 
          fct_drop()) %>%
        ggplot( aes(x = as.factor(population), y = pi, fill = population)) +
          geom_boxplot(width = 0.5, alpha = 0.8, position = position_dodge(width = 0.7)) +
          facet_wrap(~ chrom, ncol = 5, scales = "free_x") +
          scale_y_continuous(breaks = round(seq(min(pi_clean$pi, na.rm = TRUE),
                                                max(pi_clean$pi, na.rm = TRUE), 0.003),3)) +
          scale_fill_manual(values = clist) +
          labs(title = plot_title, x = "", y = expression(pi ~ "in 100 kb windows")) +
          theme_minimal() +
          theme(# Styling the population labels under the boxes
            axis.text.x = element_text(size = 10, angle = 45),
            axis.text.y = element_text(size = 10),
            axis.title = element_text(size = 14),
            legend.position = "none",
            # Styling the chromosome labels on top
            strip.text = element_text(size = 12, face = "bold"),
            strip.background = element_rect(fill = "gray95", color = NA),
            panel.spacing = unit(1, "lines"),
            panel.grid.major.x = element_blank()
            )
ggsave(pi_out_chr_box, plot_pi_chr_box, width = 8, height = 10)
