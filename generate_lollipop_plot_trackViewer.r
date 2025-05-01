# Set a CRAN mirror
# options(repos = c(CRAN = "https://cran.rstudio.com/"))

# Install BiocManager if not already installed
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
if (!require("xfun", quietly = TRUE))
  install.packages("xfun")
if (!require("dplyr", quietly = TRUE))
  install.packages("dplyr")
if (!require("RColorBrewer", quietly = TRUE))
  install.packages("RColorBrewer")
# Set Bioconductor version (run once per R session/environment)
BiocManager::install(version = "3.18")
# Install trackViewer if not already installed
if (!require("trackViewer", quietly = TRUE))
  BiocManager::install("trackViewer")

# Load the library
library(trackViewer)
library(dplyr)
library(RColorBrewer)


# This script takes two arguments:
# 1. gene_symbol: the HGNC symbol of the gene (e.g., "TP53")
# 2. participant_id: the participant identifier (e.g., "PT_1234")

# Get arguments from command line
args <- commandArgs(trailingOnly = TRUE)

# Assign arguments to variables
gene_symbol <- args[1]      # e.g., "IGSF3"
participant_id <- args[2]   # e.g., "PT_8ECE2D92"

# Read SNP information
snp_file <- paste0(gene_symbol,"_",participant_id,"_merged_germ_somatic_vars.tsv")
merged_germ_somatic_vars_df <- read.table(snp_file, header = TRUE, sep = "\t")  %>%
  arrange(codon_pos) %>%
  mutate(snp_side = ifelse(source == "somatic", "top", "bottom")) %>%
  mutate(snp_color = ifelse(source == "germline", "red", "blue"))
SNP <- merged_germ_somatic_vars_df$codon_pos
snp_names <- merged_germ_somatic_vars_df$name
snp_side_id <- merged_germ_somatic_vars_df$snp_side

# Read protein domain information
protein_domain_file <- paste0(gene_symbol,"_protein_domain.tsv")
protein_domain_df <- read.table(protein_domain_file, header = TRUE, sep = "\t") %>%
  mutate(domain_len = as.integer(end - start + 1))
protein_range <- as.integer(protein_domain_df[["protein_length"]][1])
domain_start_list <- protein_domain_df$start
domain_len_list <- protein_domain_df$domain_len
domain_name <- protein_domain_df[[1]]

# setting
sample.gr <- GRanges("chr1", IRanges(SNP, width=1, names=snp_names))
# sample.gr$color <- sample.int(6, length(SNP), replace=TRUE) # set variant color ramdonly
sample.gr$color <- merged_germ_somatic_vars_df$snp_color
sample.gr$SNPsideID <- snp_side_id
variants <- sample.gr
variants$label.parameter.rot <- 45
features <- GRanges("chr1", IRanges(domain_start_list, 
                                    width=protein_domain_df$domain_len,
                                    names=domain_name))
# Repeat the palette to match the number of domains
unique_domains <- unique(domain_name)
domain_colors <- setNames(RColorBrewer::brewer.pal(length(unique_domains), "Set2"), unique_domains)
# Map color to each domain based on its name
features_colors <- domain_colors[match(domain_name, names(domain_colors))]
features$fill <- features_colors

# Set output SVG file path
svg_filename <- paste0(gene_symbol, "_", participant_id, "_lollipop.svg")

# Open SVG device
svg(svg_filename, width = 12, height = 6)# Adjust width and height as needed

# Plot
lolliplot(variants, features,
          ranges = GRanges("chr1", IRanges(0, protein_range)))
title_text <- paste("Somatic (Top) and Germline (Bottom) Variants in \nGene", 
                    gene_symbol, "for Participant", participant_id)
grid.text(title_text, x=.5, y=.85, just="top", 
          gp=gpar(cex=1, fontface="bold"))

# Close the device to save the file
dev.off()
