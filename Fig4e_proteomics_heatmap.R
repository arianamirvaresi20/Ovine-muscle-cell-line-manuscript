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
## FILE SETTINGS
## =========================================================
raw_data <- read_excel(file.choose())

cat("Available columns:\n")
print(colnames(raw_data))

gene_col <- "Gene"
plm_col <- "PLM"
ilm_col <- "LPILM"
regulation_col <- "Regulation"  # Optional
pseudocount <- 0.015

required_cols <- c(gene_col, plm_col, ilm_col)
missing_cols <- setdiff(required_cols, colnames(raw_data))

if (length(missing_cols) > 0) {
  stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
}

## =========================================================
## COLOR SETTINGS
## =========================================================
heat_low_color <- "#3C6DB2"
heat_mid_color <- "#F7F7F7"
heat_high_color <- "#B22222"

## =========================================================
## 1. COMPUTE LOG2 FOLD CHANGE
## =========================================================
gene_names <- make.unique(as.character(raw_data[[gene_col]]))

plm_avg <- as.numeric(raw_data[[plm_col]])
ilm_avg <- as.numeric(raw_data[[ilm_col]])

log2fc <- log2((ilm_avg + pseudocount) / (plm_avg + pseudocount))

df_fc <- data.frame(
  Gene = str_to_upper(gene_names),  # Converts all gene names to uppercase
  PLM = plm_avg,
  LPILM = ilm_avg,
  Log2FC = log2fc,
  stringsAsFactors = FALSE
)

if (regulation_col %in% colnames(raw_data)) {
  df_fc$Regulation <- raw_data[[regulation_col]]
}

## Order genes by log2 fold change
df_fc <- df_fc[order(df_fc$Log2FC, decreasing = TRUE), ]

## Preserve the sorted order in the y-axis
df_fc$Gene <- factor(df_fc$Gene, levels = rev(df_fc$Gene))

## Symmetric color scale centered at zero
max_abs_fc <- max(abs(df_fc$Log2FC), na.rm = TRUE)

if (!is.finite(max_abs_fc) || max_abs_fc == 0) {
  max_abs_fc <- 1
}

## =========================================================
## 2. BUILD LOG2FC HEATMAP
## =========================================================
p_fc <- ggplot(df_fc, aes(x = "LOG2FC", y = Gene, fill = Log2FC)) +
  geom_tile(
    width = 0.995,
    height = 0.995,
    color = "white",
    linewidth = 0.18
  ) +
  geom_text(
    aes(label = sprintf("%.2f", Log2FC)),
    size = value_text_size,
    family = base_font_family,
    fontface = font_face_main,
    color = "black"
  ) +
  scale_fill_gradient2(
    low = heat_low_color,
    mid = heat_mid_color,
    high = heat_high_color,
    midpoint = 0,
    limits = c(-max_abs_fc, max_abs_fc),
    name = "LOG2FC\n(LPILM/PLM)"
  ) +
  coord_fixed(ratio = 0.5) +
  labs(x = NULL, y = NULL) +
  theme_minimal(
    base_family = base_font_family,
    base_size = base_font_size
  ) +
  theme(
    plot.title = element_blank(),
    
    axis.text.x = element_text(
      angle = 45,
      hjust = 1,
      vjust = 1,
      size = x_font_size,
      face = font_face_main,
      color = "black",
      margin = margin(t = 2)
    ),
    
    axis.text.y = element_text(
      size = y_font_size,
      face = font_face_main,
      color = "black",
      margin = margin(r = 3)
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
    
    legend.title = element_text(
      size = legend_title_size,
      face = font_face_main
    ),
    
    legend.text = element_text(
      size = legend_text_size,
      face = font_face_main
    ),
    
    legend.key.height = unit(0.7, "cm"),
    legend.key.width = unit(0.35, "cm"),
    
    plot.margin = margin(3, 3, 3, 3)
  )

## =========================================================
## 3. DISPLAY PLOT
## =========================================================
print(p_fc)

## =========================================================
## 4. EXPORT FILES
## =========================================================
ggsave(
  filename = "heatmap_log2fc_nature_style.pdf",
  plot = p_fc,
  device = cairo_pdf,
  width = 2.4,
  height = 7.2,
  units = "in",
  bg = "white"
)

ggsave(
  filename = "heatmap_log2fc_nature_style.png",
  plot = p_fc,
  device = ragg::agg_png,
  width = 2.4,
  height = 7.2,
  units = "in",
  res = 600,
  bg = "white"
)

ggsave(
  filename = "heatmap_log2fc_nature_style.tiff",
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
cat("- heatmap_log2fc_nature_style.pdf\n")
cat("- heatmap_log2fc_nature_style.png\n")
cat("- heatmap_log2fc_nature_style.tiff\n")