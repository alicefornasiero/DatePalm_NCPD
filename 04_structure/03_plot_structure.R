#!/usr/bin/env Rscript
#--------------------------------------------------------------------------------------#
#                                                                                      #
#         Plot the cross-entropy criterion to infer the best estimate of K.            #
# The lower the cross-entropy, the better the model accounts for population structure. #
#                                                                                      #
#--------------------------------------------------------------------------------------#

# Install required packages
# install.packages(c("RColorBrewer"))

# Load required libraries
library(RColorBrewer)

#-----------------------------------#
# 1. K-plot of Cross Entropy values #
#-----------------------------------#

# Input files and variables
infile = "K_vs_CrossEntropy.txt"
num_k = 10

# Read input files
mydata <- read.table(infile, header = TRUE, stringsAsFactors = FALSE)
# Order data by increasing K number
mydata <- mydata[order(mydata$K), ]
# Only plot num_k Ks
datatoplot <- mydata[1 : num_k,]
# Define output file name
outfile <- paste(dirname(infile), gsub(".txt", ".pdf", basename(infile)), sep="/")
# Open pdf file for plotting
pdf(outfile, width = 7, height = 7)

# Plot!
# Plot line
plot(datatoplot$K, datatoplot$Cross_Entropy, 
     type = "lines", lwd = 2, col = "blue", axes = FALSE, ann = FALSE
    )
# Plot data points
points(datatoplot$K, datatoplot$Cross_Entropy,
       pch = 20, cex = 1.5, col = "blue"
      )
# Add x and y labels
title(xlab = "K, number of ancestral populations", ylab = "Min Cross-Entropy", cex.lab = 1.5
     )
# Plot x-axis
axis(side = 1, at = seq(1, num_k, by = 1), labels = TRUE, cex.axis = 1.2
    )
# Plot y-axis
axis(side = 2, cex.axis = 1.2,
     at = seq(round(min(datatoplot$Cross_Entropy)-0.1, 2), round(max(datatoplot$Cross_Entropy)+0.1, 2), by = 0.01)
    )
# Close device
dev.off()


#------------------------------------#
# 2. Barplot of population structure #
#------------------------------------#

# Input files and variables
indir = "/path/to/input/directory/with/Q/matrices"
prefix = "output_file_prefix"
namefile = "original_sample_order_in_sNMF_analysis"
orderfile = "new_sample_order_to_plot"
num_run = 0 # The run number to be plotted
min_k = 2 # The minimum K to plot
num_k = 4 # The maximum K to plot

# Read input files
samplenames <- read.table(namefile, header = FALSE, stringsAsFactors = FALSE)
sampleorder <- read.table(orderfile, col.names = c("ind", "pop"), stringsAsFactors = FALSE)
outbarplot <- paste0(indir, "/", prefix, "_run", num_run, "_I.", num_k, "_barplot.pdf")

# 1. Open input files from structure analysis, given the number of Ks
KdataFiles <- lapply(min_k : num_k,  function(x) read.table(paste0(indir, "/", prefix, "_run", num_run, "_I.", x, ".Q")))

# 2. Add sample names (original ordering from structure analysis)
Kdata <- lapply(KdataFiles, function(x) { x$samples <- unlist(samplenames); return(x) } )

# 3. Order according to user's sample ordering
Kdata_ord <- lapply(1 : length(Kdata), function(x) { Kdata[[x]] [match(unlist(sampleorder$ind), Kdata[[x]]$samples) , ] })
# transpose Kdata_ord
Kdata_t <- lapply(Kdata_ord, t)

# 4. Prepare the plot
# set colors
cols <- brewer.pal(8, "Set2")
cols <- cols[seq(2,(num_k + 1), 1)]
# prepare spaces to separate the populations/species in the plot
rep <- sampleorder %>% count(pop)
spaces <- 0
for(i in 1 : length(rep$n)){spaces = c(spaces, rep(0, rep$n[i]-1), 0.5)}
spaces <- spaces[-length(spaces)]

# 5. Plot!
pdf(outbarplot, height = (num_k * 2), width = 18)
if (num_k == min_k) par(mar = c(7,2,2,2))
if (num_k > min_k) par(mfcol = c((num_k - 1),1), mar = c(0.2,3,0.2,2), oma = c(2,0,15,0))

for (aaa in 2 : num_k)
{
    if (aaa == 2) Kcolor <- cols[1 : aaa] else Kcolor <- append(Kcolor, cols[aaa])
    
    bp <- barplot(Kdata_t[[aaa-1]][1 : aaa,], names.arg = Kdata_t[[aaa-1]][nrow(Kdata_t[[aaa-1]]),], 
                  axisnames = FALSE, col = Kcolor, border = NA, space = spaces, axes = FALSE, ylim = c(0, 1)
                 )
    # draw a black line between bars
    # abline(v = seq(1, length(sampleorder)), lwd = 0.5)
    mtext(paste0("K = ", aaa), side = 4, line = -2, adj = 0.5, cex = 2, col = "#505050", outer = FALSE, padj = 0)
    # y-axis tick marks
    axis(2, at = c(0, 0.2, 0.4, 0.6, 0.8, 1.0), line = -4, cex.axis = 2, las = 2)
    
    if (aaa == min_k) {
    # sample name labels on top of the plot
    mtext(text = Kdata_t[[aaa-1]][nrow(Kdata_t[[aaa-1]]),], at = bp, 
    side = 3, cex = 0.6, las = 2, col = "#505050", line = 1)
    }
}
dev.off()
