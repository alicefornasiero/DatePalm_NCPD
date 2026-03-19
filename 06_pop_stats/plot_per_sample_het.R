#!/usr/bin/env Rscript
#--------------------------------------------------------------------#
#         Plot heterozygosity distribution for each sample           #
#     by ordering samples by population and median heterozygosity    #
#--------------------------------------------------------------------#

# Input files and variables
# ----------------------------------------------------------------------------------------------------- #
# indir - Path to directory containing the per-sample heterozygosity_sorted.tsv file from clam analysis
# pop_file - Tab separated file with two columns: sample name, population (header required)
# plot_title - Title text for the output plot
# win_size - Window size in bp used in clam analysis

indir = "path/to/clam/per_sample/output/directory"
groupfile = "/path/to/text_file"
plot_title = "Plot title"
win_size = 100000
# ---------------------------------------------------------------------------------------------------- #

# Install required packages
# install.packages(c("tidyverse", "ggplot2", "forcats"))

# Load libraries
library(tidyverse)
library(ggplot2)
library(forcats)

# Set working directory
setwd(indir)

# Read input files
het <- read_table("heterozygosity_sorted.tsv", col_names = c("chrom","start","end","sample","het_total","callable_total","heterozygosity"))
pop <- read_table(groupfile, col_names = c("sample", "final_label", "pop"))

# Define output file names
het_out_box <- paste0(indir, "/", sub(".tsv", "_boxplot.pdf", "heterozygosity_sorted.tsv"))

# Remove lines with NA values
het_clean <- het[complete.cases(het), ]

# Add population info to the samples
het_pop <- left_join(x = het_clean, y = pop, by = "sample")

# Define color palette accordingly to results of population structure analysis
# Females
clist <- c("pop1" = "#CC6677", "pop2" = "#332288", "pop3" = "#DDCC77", "pop4" = "#117733", "admix" = "#BBBBBB")
# Males
# clist <- c("pop1" = "#EE7733", "pop2" = "#0077BB", "pop3" = "#EE3377", "admix" = "#BBBBBB")

# Prepare the data to be plotted
het_pop_sorted <- het_pop %>%
  # 1. Manually set the order of the 'pop' factor
  mutate(pop = fct_relevel(pop, "pop1", "pop2", "pop3", "pop4", "admix") %>% 
                fct_drop()) %>%
  # 2. Calculate median per label for the internal sorting
  group_by(final_label) %>%
  mutate(med_het = median(heterozygosity)) %>%
  ungroup() %>%
  # 3. Arrange by the new 'pop' order, then by the median value
  arrange(pop, med_het) %>%
  # 4. Lock in the label order based on the arrangement above
  mutate(final_label = fct_inorder(final_label))

# Plot heterozigosity per sample as boxplots
plot_het_box <- ggplot(het_pop_sorted, aes(x = final_label, y = heterozygosity, fill = pop)) +
          geom_boxplot(width = 0.8, alpha = 0.7) +
          scale_y_continuous(expand = c(0, NA),
            breaks = round(seq(min(het_pop_sorted$heterozygosity, na.rm = TRUE), 
                               max(het_pop_sorted$heterozygosity, na.rm = TRUE), 0.002),3)
          ) +
          scale_fill_manual(values = clist) +
          labs(title = plot_title, x = "", y = "Heterozygosity") +
          theme_minimal() +
          theme(axis.text = element_text(size = 8),
            axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
            axis.title = element_text(size = 14),
            legend.position = "right",
            legend.text = element_text(size = 12),
            legend.title = element_blank(),
            )
ggsave(het_out_box, plot_het_box, width = 15, height = 7)
