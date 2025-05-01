# Set a CRAN mirror
options(repos = c(CRAN = "https://cran.rstudio.com/"))

if (!require("BiocManager"))
    install.packages("BiocManager")
BiocManager::install("maftools")
if (!require("R.utils"))
    install.packages("R.utils")
if (!require("RColorBrewer"))
    install.packages("RColorBrewer")

library(maftools)

# This script takes two arguments:
# 1. gene_symbol: the HGNC symbol of the gene (e.g., "TP53")
# 2. participant_id: the participant identifier (e.g., "PT_1234")

# Get arguments from command line
args <- commandArgs(trailingOnly = TRUE)

# Assign arguments to variables
gene_symbol <- args[1]      # e.g., "IGSF3"
participant_id <- args[2]   # e.g., "PT_8ECE2D92"

somatic.maf <- paste0(gene_symbol, "_", participant_id, "_somatic_maf.tsv")
somatic.laml <- read.maf(maf = somatic.maf)
germline.maf <- paste0(gene_symbol, "_", participant_id, "_germline_maf.tsv")
germline.laml <- read.maf(maf = germline.maf)

svg_filename <- paste0(gene_symbol, "_", participant_id, "_lollipop.svg")

# Open SVG device
svg(svg_filename, width = 12, height = 6)# Adjust width and height as needed

lollipopPlot2(m1 = somatic.laml, m2 = germline.laml, 
              gene = gene_symbol, AACol1 = "hgvsp", AACol2 = "name",
              m1_name = "Somatic", m2_name = "Germline")
title_text <- paste("Somatic (Top) and Germline (Bottom) Variants in \nGene", 
                    gene_symbol, "for Participant", participant_id)
# title(main = title_text, col.main = "black", font.main = 2)
mtext(title_text, side = 3, line = 2, cex = 1.2, font = 1.5)

# Close the device to save the file
dev.off()
