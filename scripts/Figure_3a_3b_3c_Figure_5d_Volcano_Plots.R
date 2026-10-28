# ============================================================================
# Figure_3a_3b_3c_Figure_5d_Volcano_Plots.R
# Figure(s): 3a–3c; 5d
# Purpose: Shared basic volcano plot code; run separately for each comparison
# Package version: v1.1 (prepared 2026-10-27)
# Run setup/Install_Dependencies.R once before running this script.
# Read README.md for data columns, figure mapping, and validation limitations.
# ============================================================================

## =========================================================
## Install required packages (run once if needed)
## =========================================================
# Setup handles this: install.packages("readxl")
# Setup handles this: install.packages("ggplot2")
# Setup handles this: install.packages("dplyr")

## =========================================================
## Load libraries
## =========================================================
library(readxl)
library(ggplot2)
library(dplyr)

## =========================================================
## Load your data
## =========================================================
data <- read_excel(file.choose())

## =========================================================
## Classify genes
## =========================================================
data <- data %>%
  mutate(
    category = case_when(
      log2FoldChange >= 1 & padj <= 0.05 ~ "Upregulated",
      log2FoldChange <= -1 & padj <= 0.05 ~ "Downregulated",
      TRUE ~ "Insignificant"
    )
  )

## =========================================================
## Volcano plot
## =========================================================
p <- ggplot(data, aes(x = log2FoldChange, y = -log10(padj), color = category)) +
  geom_point(alpha = 0.7, size = 2) +
  scale_color_manual(
    values = c(
      "Upregulated"   = "#B22222",  # red
      "Downregulated" = "#3C6DB2",  # blue
      "Insignificant" = "grey70"
    )
  ) +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed", color = "black") +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "black") +
  coord_cartesian(xlim = c(-8, 8)) +
  labs(
    x = expression("Log"[2] * " (Fold Change)"),
    y = expression("-Log"[10] * " (Adjusted P-value)"),
    color = NULL,
    title = NULL
  ) +
  theme_minimal() +
  theme(
    axis.title.x = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 14, face = "bold"),
    axis.text.x  = element_text(size = 12, face = "bold"),
    axis.text.y  = element_text(size = 12, face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 1),
    legend.position = "right",
    legend.text = element_text(size = 12, family = "Arial", face = "bold")
  )

## =========================================================
## Display plot
## =========================================================
print(p)
