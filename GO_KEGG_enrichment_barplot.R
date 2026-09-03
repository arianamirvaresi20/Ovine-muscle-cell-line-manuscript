
library(readxl)
library(ggplot2)
library(dplyr)
library(showtext)
library(sysfonts)
library(ragg)
library(Cairo)
library(grid)

## ============================================================================
## FONT SETTINGS
## ============================================================================
base_font_family <- "Calibri"
use_bold <- TRUE
font_face_main <- ifelse(use_bold, "bold", "plain")

showtext_auto()

## ============================================================================
## 1. LOAD DATA
## ============================================================================
data <- read_excel(file.choose())

cat("=== COLUMN NAMES ===\n")
print(colnames(data))

## ============================================================================
## 2. DATA PREPARATION
## ============================================================================
plot_data <- data %>%
  mutate(
    GeneRatio = as.numeric(sapply(strsplit(GeneRatio, "/"),
                                  function(x) as.numeric(x[1]) / as.numeric(x[2]))),
    Count = as.numeric(Count),
    padj = as.numeric(padj),
    pvalue = as.numeric(pvalue),
    Up = as.numeric(Up),
    Down = as.numeric(Down),
    RichFactor = round(GeneRatio, 3),
    Total_Regulated = Up + Down,
    UpDownRatio = if_else(Total_Regulated > 0, Up / Total_Regulated, 0.5),
    PercentUp = if_else(Total_Regulated > 0, round((Up / Total_Regulated) * 100, 1), 50),
    Significance = if_else(padj <= 0.05, "Significant", "Not Significant")
  ) %>%
  arrange(desc(GeneRatio))

cat("\n=== SIGNIFICANCE SUMMARY ===\n")
cat("Significant (padj ≤ 0.05):", sum(plot_data$padj <= 0.05, na.rm = TRUE), "\n")
cat("Not Significant (padj > 0.05):", sum(plot_data$padj > 0.05, na.rm = TRUE), "\n")

## ============================================================================
## 3. FACETED VIEW
## ============================================================================
if ("Category" %in% colnames(plot_data)) {
  
  category_counts <- plot_data %>%
    group_by(Category) %>%
    summarise(n_items = n(), .groups = "drop")
  
  cat("\n=== ITEMS PER CATEGORY ===\n")
  print(category_counts)
  
  plot_faceted <- ggplot(
    plot_data,
    aes(x = GeneRatio, y = Description, size = Count, fill = UpDownRatio)
  ) +
    
    ## Base points
    geom_point(
      aes(color = Significance),
      shape = 21,
      alpha = 0.9,
      stroke = 0.7
    ) +
    
    ## Bold border for SIGNIFICANT
    geom_point(
      data = plot_data %>% filter(Significance == "Significant"),
      aes(color = Significance),
      shape = 21,
      stroke = 1.8,
      alpha = 0.9,
      show.legend = FALSE
    ) +
    
    ## Thin border for NOT significant
    geom_point(
      data = plot_data %>% filter(Significance == "Not Significant"),
      aes(color = Significance),
      shape = 21,
      stroke = 0.5,
      alpha = 0.9,
      show.legend = FALSE
    ) +
    
    ## Same heatmap-style blue-white-red fill
    scale_fill_gradient2(
      low = "#3C6DB2",
      mid = "#F7F7F7",
      high = "#B22222",
      midpoint = 0.5,
      name = "Regulation\n(circle fill)",
      breaks = c(0, 0.5, 1.0),
      labels = c("Down", "Balanced", "Up"),
      limits = c(0, 1.0)
    ) +
    
    ## Border color shows significance
    scale_color_manual(
      values = c(
        "Significant" = "black",
        "Not Significant" = "#666666"
      ),
      name = "Significance\n(outline)"
    ) +
    
    scale_size_continuous(
      name = "Gene Count",
      range = c(2.5, 6.5),
      breaks = seq(10, max(plot_data$Count, na.rm = TRUE), by = 10),
      limits = c(0, max(plot_data$Count, na.rm = TRUE))
    ) +
    
    facet_wrap(~Category, scales = "free_y", ncol = 1, strip.position = "top") +
    
    scale_x_continuous(
      expand = c(0.05, 0),
      limits = c(0, max(plot_data$GeneRatio, na.rm = TRUE) * 1.2)
    ) +
    
    theme_minimal(base_family = base_font_family) +
    theme(
      text = element_text(family = base_font_family, face = font_face_main),
      panel.border = element_rect(color = "#333333", fill = NA, linewidth = 0.6),
      strip.text = element_text(size = 12, face = "bold", color = "#1B3A5E", hjust = 0.5),
      axis.text.y = element_text(size = 12, color = "#333333", face = font_face_main),
      axis.text.x = element_text(size = 12, color = "#333333", face = "bold"),
      axis.title.x = element_text(size = 11, face = "bold", color = "#1B3A5E"),
      axis.title.y = element_text(size = 11, face = "bold", color = "#1B3A5E"),
      axis.line = element_line(color = "#333333", linewidth = 0.5),
      legend.position = "right",
      legend.title = element_text(size = 9, face = "bold", color = "#1B3A5E"),
      legend.text = element_text(size = 8, color = "#333333", face = font_face_main),
      legend.background = element_blank(),
      legend.box.background = element_blank(),
      legend.key = element_blank(),
      panel.spacing.y = unit(0.5, "lines"),
      panel.grid.major.y = element_line(color = "#E8E8E8", linewidth = 0.2),
      panel.grid.major.x = element_line(color = "#E8E8E8", linewidth = 0.2),
      panel.grid.minor = element_blank(),
      plot.title = element_text(size = 13, face = "bold", hjust = 0.5, color = "#1B3A5E"),
      plot.background = element_rect(color = "#333333", fill = "white", linewidth = 1.5),
      plot.margin = margin(15, 15, 15, 15, unit = "pt")
    ) +
    labs(
      x = "Gene Ratio (Rich Factor)",
      y = "GO Term Description"
    )
  
  print(plot_faceted)
  
  total_terms <- nrow(plot_data)
  dynamic_height <- 3 + (total_terms * 0.25)
  
  ggsave(
    "2_bubble_plot_faceted_compact.png",
    plot_faceted,
    device = ragg::agg_png,
    width = 14,
    height = dynamic_height,
    units = "in",
    res = 600,
    bg = "white"
  )
  
  ggsave(
    "2_bubble_plot_faceted_compact.pdf",
    plot_faceted,
    device = cairo_pdf,
    width = 14,
    height = dynamic_height,
    units = "in",
    bg = "white"
  )
  
  cat(sprintf("\n✓ Saved: 2_bubble_plot_faceted_compact.png (%.1f x %.1f inches)\n", 14, dynamic_height))
  cat(sprintf("✓ Saved: 2_bubble_plot_faceted_compact.pdf (%.1f x %.1f inches)\n", 14, dynamic_height))
  
} else {
  cat("\n⚠ Warning: No 'Category' column found - skipping faceted plot\n")
}

## ============================================================================
## 4. MAIN PLOT
## ============================================================================
plot_main <- ggplot(
  plot_data,
  aes(x = GeneRatio, y = Description, size = Count, fill = UpDownRatio)
) +
  
  ## Base points
  geom_point(
    aes(color = Significance),
    shape = 21,
    alpha = 0.9,
    stroke = 0.7
  ) +
  
  ## Bold border for SIGNIFICANT
  geom_point(
    data = plot_data %>% filter(Significance == "Significant"),
    aes(color = Significance),
    shape = 21,
    stroke = 1.8,
    alpha = 0.9,
    show.legend = FALSE
  ) +
  
  ## Thin border for NOT significant
  geom_point(
    data = plot_data %>% filter(Significance == "Not Significant"),
    aes(color = Significance),
    shape = 21,
    stroke = 0.5,
    alpha = 0.9,
    show.legend = FALSE
  ) +
  
  scale_fill_gradient2(
    low = "#3C6DB2",
    mid = "#F7F7F7",
    high = "#B22222",
    midpoint = 0.5,
    name = "Regulation\n(circle fill)",
    breaks = c(0, 0.5, 1.0),
    labels = c("Down", "Balanced", "Up"),
    limits = c(0, 1.0)
  ) +
  
  scale_color_manual(
    values = c(
      "Significant" = "black",
      "Not Significant" = "#666666"
    ),
    name = "Significance\n(outline)"
  ) +
  
  scale_size_continuous(
    name = "Gene Count",
    range = c(2.5, 6.5),
    breaks = seq(10, max(plot_data$Count, na.rm = TRUE), by = 10),
    limits = c(0, max(plot_data$Count, na.rm = TRUE))
  ) +
  
  scale_x_continuous(
    expand = c(0.05, 0),
    limits = c(0, max(plot_data$GeneRatio, na.rm = TRUE) * 1.2)
  ) +
  
  theme_minimal(base_family = base_font_family) +
  theme(
    text = element_text(family = base_font_family, face = font_face_main),
    panel.border = element_rect(color = "#333333", fill = NA, linewidth = 0.6),
    axis.text.y = element_text(size = 12, color = "#333333", face = font_face_main),
    axis.text.x = element_text(size = 12, color = "#333333", face = "bold"),
    axis.title.y = element_text(size = 11, face = "bold", color = "#1B3A5E"),
    axis.title.x = element_text(size = 11, face = "bold", color = "#1B3A5E"),
    axis.line = element_line(color = "#333333", linewidth = 0.5),
    legend.position = "right",
    legend.title = element_text(size = 9, face = "bold", color = "#1B3A5E"),
    legend.text = element_text(size = 8, color = "#333333", face = font_face_main),
    legend.background = element_blank(),
    legend.box.background = element_blank(),
    legend.key = element_blank(),
    panel.grid.major.y = element_line(color = "#E8E8E8", linewidth = 0.2),
    panel.grid.major.x = element_line(color = "#E8E8E8", linewidth = 0.2),
    panel.grid.minor = element_blank(),
    plot.title = element_text(size = 13, face = "bold", hjust = 0.5, color = "#1B3A5E"),
    plot.background = element_rect(color = "#333333", fill = "white", linewidth = 1.5),
    plot.margin = margin(15, 15, 15, 15, unit = "pt")
  ) +
  labs(
    title = "Gene Ontology Enrichment Analysis",
    x = "Gene Ratio (Rich Factor)",
    y = "GO Term Description"
  )

print(plot_main)

main_height <- 2 + (nrow(plot_data) * 0.15)

ggsave(
  "1_bubble_plot_main_compact.png",
  plot_main,
  device = ragg::agg_png,
  width = 14,
  height = main_height,
  units = "in",
  res = 600,
  bg = "white"
)

ggsave(
  "1_bubble_plot_main_compact.pdf",
  plot_main,
  device = cairo_pdf,
  width = 14,
  height = main_height,
  units = "in",
  bg = "white"
)

cat(sprintf("\n✓ Saved: 1_bubble_plot_main_compact.png (%.1f x %.1f inches)\n", 14, main_height))
cat(sprintf("✓ Saved: 1_bubble_plot_main_compact.pdf (%.1f x %.1f inches)\n", 14, main_height))

## ============================================================================
## 5. SUMMARY STATISTICS
## ============================================================================
cat("\n=== TOP 10 MOST ENRICHED TERMS ===\n")

if ("Category" %in% colnames(plot_data)) {
  top10 <- plot_data %>%
    select(Description, Category, GeneRatio, Count, padj,
           Up, Down, PercentUp, UpDownRatio, Significance) %>%
    slice_head(n = 10)
} else {
  top10 <- plot_data %>%
    select(Description, GeneRatio, Count, padj,
           Up, Down, PercentUp, UpDownRatio, Significance) %>%
    slice_head(n = 10)
}

print(top10)

cat("\n=== SUMMARY STATISTICS ===\n")
cat("Total GO terms:", nrow(plot_data), "\n")

if ("Category" %in% colnames(plot_data)) {
  cat("\nTerms by category:\n")
  print(table(plot_data$Category))
}

cat("\nGene Ratio range:", round(min(plot_data$GeneRatio, na.rm = TRUE), 4), "-",
    round(max(plot_data$GeneRatio, na.rm = TRUE), 4), "\n")
cat("Gene Count range:", min(plot_data$Count, na.rm = TRUE), "-", max(plot_data$Count, na.rm = TRUE), "\n")
cat("padj range:", round(min(plot_data$padj, na.rm = TRUE), 4), "-",
    round(max(plot_data$padj, na.rm = TRUE), 4), "\n")

cat("\n*** SIGNIFICANCE THRESHOLD (padj = 0.05) ***\n")
cat("Significant terms (padj ≤ 0.05):", sum(plot_data$padj <= 0.05, na.rm = TRUE), "✅\n")
cat("Not significant terms (padj > 0.05):", sum(plot_data$padj > 0.05, na.rm = TRUE), "⚫\n")

cat("\nTotal Up-regulated genes:", sum(plot_data$Up, na.rm = TRUE), "\n")
cat("Total Down-regulated genes:", sum(plot_data$Down, na.rm = TRUE), "\n")
cat("Mean Up %:", round(mean(plot_data$PercentUp, na.rm = TRUE), 1), "%\n")

write.csv(top10, "TOP10_ENRICHED_TERMS.csv", row.names = FALSE)
cat("\n✓ Saved: TOP10_ENRICHED_TERMS.csv\n")

cat("\n=== COMPLETE ===\n")