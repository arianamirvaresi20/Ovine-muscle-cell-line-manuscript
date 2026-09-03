## =========================================================
## Install packages once, if needed
## =========================================================

# install.packages("readxl")
# install.packages("ggplot2")
# install.packages("stringr")
# install.packages("showtext")
# install.packages("sysfonts")
# install.packages("ragg")
# install.packages("Cairo")

## =========================================================
## Load libraries
## =========================================================

library(readxl)
library(ggplot2)
library(stringr)
library(showtext)
library(sysfonts)
library(ragg)
library(Cairo)
library(grid)

## =========================================================
## FONT SETTINGS
## =========================================================

base_font_family <- "Calibri"

# Keep TRUE to make all figure text bold
use_bold <- TRUE

base_font_size <- 16
x_font_size <- 16
y_font_size <- 16
value_text_size <- 7
legend_title_size <- 16
legend_text_size <- 16

font_face_main <- ifelse(use_bold, "bold", "plain")

showtext_auto()

## =========================================================
## FILE / COLUMN SETTINGS
## =========================================================

# Your Excel file must contain these columns
gene_col <- "Gene"
log2fc_col <- "Log2FC"

## =========================================================
## COLOR SETTINGS
## =========================================================

heat_low_color <- "#3C6DB2"   # Blue: negative Log2FC
heat_mid_color <- "#F7F7F7"   # White: Log2FC = 0
heat_high_color <- "#B22222"  # Red: positive Log2FC

## =========================================================
## 1. LOAD EXCEL DATA
## =========================================================

raw_data <- read_excel(file.choose())

cat("Available columns:\n")
print(colnames(raw_data))

required_cols <- c(gene_col, log2fc_col)
missing_cols <- setdiff(required_cols, colnames(raw_data))

if (length(missing_cols) > 0) {
  stop(
    "Missing required column(s): ",
    paste(missing_cols, collapse = ", ")
  )
}

## =========================================================
## 2. PREPARE LOG2FC DATA
## =========================================================

gene_names <- make.unique(as.character(raw_data[[gene_col]]))
log2fc_values <- as.numeric(raw_data[[log2fc_col]])

df_fc <- data.frame(
  Gene = str_to_upper(gene_names),
  Log2FC = log2fc_values,
  stringsAsFactors = FALSE
)

## Remove missing, NaN, Inf, and -Inf values
df_fc <- df_fc[is.finite(df_fc$Log2FC), , drop = FALSE]

if (nrow(df_fc) == 0) {
  stop(
    "No valid numeric values were found in the '",
    log2fc_col,
    "' column."
  )
}

## Sort genes from largest positive to largest negative Log2FC
df_fc <- df_fc[order(df_fc$Log2FC, decreasing = TRUE), , drop = FALSE]

## Maintain the same ordering on the y-axis
df_fc$Gene <- factor(
  df_fc$Gene,
  levels = rev(as.character(df_fc$Gene))
)

## Symmetric color range around zero
max_abs_fc <- max(abs(df_fc$Log2FC), na.rm = TRUE)

if (!is.finite(max_abs_fc) || max_abs_fc == 0) {
  max_abs_fc <- 1
}

legend_breaks <- c(-max_abs_fc, 0, max_abs_fc)
legend_labels <- c(
  sprintf("%.0f", -max_abs_fc),
  "0",
  sprintf("%.0f", max_abs_fc)
)

## =========================================================
## 3. BUILD BOLD SINGLE-COLUMN LOG2FC HEATMAP
## =========================================================

p_fc <- ggplot(
  df_fc,
  aes(x = "Log2FC", y = Gene, fill = Log2FC)
) +
  geom_tile(
    width = 0.995,
    height = 0.995,
    color = "white",
    linewidth = 0.18
  ) +
  geom_text(
    aes(label = sprintf("%.1f", Log2FC)),
    size = value_text_size,
    family = base_font_family,
    fontface = "bold",
    color = "black"
  ) +
  scale_fill_gradient2(
    low = heat_low_color,
    mid = heat_mid_color,
    high = heat_high_color,
    midpoint = 0,
    limits = c(-max_abs_fc, max_abs_fc),
    breaks = legend_breaks,
    labels = legend_labels,
    name = "Log2FC"
  ) +
  coord_fixed(ratio = 0.50) +
  labs(
    x = NULL,
    y = NULL
  ) +
  theme_minimal(
    base_family = base_font_family,
    base_size = base_font_size
  ) +
  theme(
    plot.title = element_blank(),
    
    # Bottom label: LOG2FC
    axis.text.x = element_text(
      angle = 0,
      hjust = 0.5,
      vjust = 0.5,
      size = x_font_size,
      face = "bold",
      color = "black",
      margin = margin(t = 2)
    ),
    
    # Gene names
    axis.text.y = element_text(
      size = y_font_size,
      face = "bold",
      color = "black",
      margin = margin(r = 5)
    ),
    
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    
    plot.background = element_rect(
      fill = "white",
      color = NA
    ),
    
    panel.background = element_rect(
      fill = "white",
      color = NA
    ),
    
    legend.position = "right",
    
    # Legend title: LOG2FC
    legend.title = element_text(
      size = legend_title_size,
      face = "bold",
      color = "black"
    ),
    
    # Legend numbers
    legend.text = element_text(
      size = legend_text_size,
      face = "bold",
      color = "black"
    ),
    
    legend.key.height = unit(0.70, "cm"),
    legend.key.width = unit(0.35, "cm"),
    
    plot.margin = margin(5, 5, 5, 5)
  )

## =========================================================
## 4. DISPLAY PLOT
## =========================================================

print(p_fc)

## =========================================================
## 5. EXPORT FILES
## =========================================================

ggsave(
  filename = "heatmap_log2fc_single_column_bold.pdf",
  plot = p_fc,
  device = cairo_pdf,
  width = 2.4,
  height = 7.2,
  units = "in",
  bg = "white"
)

ggsave(
  filename = "heatmap_log2fc_single_column_bold.png",
  plot = p_fc,
  device = ragg::agg_png,
  width = 2.4,
  height = 7.2,
  units = "in",
  res = 600,
  bg = "white"
)

ggsave(
  filename = "heatmap_log2fc_single_column_bold.tiff",
  plot = p_fc,
  device = ragg::agg_tiff,
  width = 2.4,
  height = 7.2,
  units = "in",
  res = 600,
  compression = "lzw",
  bg = "white"
)

cat("\nFiles saved as:\n")
cat("- heatmap_log2fc_single_column_bold.pdf\n")
cat("- heatmap_log2fc_single_column_bold.png\n")
cat("- heatmap_log2fc_single_column_bold.tiff\n")