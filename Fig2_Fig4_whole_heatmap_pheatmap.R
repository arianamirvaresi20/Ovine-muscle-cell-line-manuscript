# Install packages (run once; you can skip if already installed)
install.packages("readxl")
install.packages("pheatmap")
install.packages("paletteer")
install.packages("stringr")

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
my_palette <- colorRampPalette(c("#3C6DB2", "#F7F7F7", "#B22222"))(30)  # [web:3][web:9]

# Define breaks (adjust range if needed)
min_val <- floor(min(mat_scaled, na.rm = TRUE))
max_val <- ceiling(max(mat_scaled, na.rm = TRUE))
breaks <- seq(min_val, max_val, length.out = 31)  # [web:5][web:7]

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