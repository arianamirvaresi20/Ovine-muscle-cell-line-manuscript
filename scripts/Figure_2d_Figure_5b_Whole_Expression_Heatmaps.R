# ============================================================================
# Figure_2d_Figure_5b_Whole_Expression_Heatmaps.R
# Figure(s): 2d; 5b
# Purpose: Whole transcriptomic/proteomic expression heatmaps; run separately
# Package version: v1.1 (prepared 2026-10-27)
# Run setup/Install_Dependencies.R once before running this script.
# Read README.md for data columns, figure mapping, and validation limitations.
# ============================================================================

# Install packages (run once; you can skip if already installed)
# Setup handles this: install.packages("readxl")
# Setup handles this: install.packages("pheatmap")
# Setup handles this: install.packages("paletteer")
# Setup handles this: install.packages("stringr")

# Load libraries
library(readxl)
library(pheatmap)
library(paletteer)
library(stringr)

# Load data (choose your Excel file in the dialog)
raw_data <- read_excel(file.choose())

# Make row names unique
row_names <- make.unique(as.character(raw_data[[1]]))

# Convert to data frame and set unique row names
data <- as.data.frame(raw_data[, -1])
rownames(data) <- row_names

# Clean data
data[] <- lapply(data, as.numeric)
data[is.na(data)] <- 0
data[is.infinite(as.matrix(data))] <- 0

# Matrix and scaling
mat <- as.matrix(data)
mat_scaled <- t(scale(t(mat)))

# Convert row names to sentence case
rownames(mat_scaled) <- str_to_sentence(rownames(mat_scaled))

# Define color palette: white (low) -> light blue -> dark blue (high)
my_palette <- colorRampPalette(c("#3C6DB2", "#F7F7F7", "#B22222"))(30)

# Define breaks (adjust range if needed)
min_val <- floor(min(mat_scaled, na.rm = TRUE))
max_val <- ceiling(max(mat_scaled, na.rm = TRUE))
breaks <- seq(min_val, max_val, length.out = 31)

# Generate heatmap
pheatmap(
  mat_scaled,
  color = my_palette,
  breaks = breaks,
  border_color = "white",
  fontsize_row = 6.5,
  fontsize_col = 10,
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  show_rownames = FALSE,
  show_colnames = TRUE,
  angle_col = 45,
  fontface_row = "bold",
  legend = TRUE
)
