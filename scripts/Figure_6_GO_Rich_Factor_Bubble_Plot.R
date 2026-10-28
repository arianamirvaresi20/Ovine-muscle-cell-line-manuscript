# ============================================================================
# Figure_6_GO_Rich_Factor_Bubble_Plot.R
# Figure(s): 6
# Purpose: Top-30 GO rich-factor bubble plot; replaces former Figure 5a implementation
# Package version: v1.1 (prepared 2026-10-27)
# Run setup/Install_Dependencies.R once before running this script.
# Read README.md for data columns, figure mapping, and validation limitations.
# ============================================================================

# ============================================================================
# BUBBLE PLOT - RICH FACTOR + TOP 30 + ABBREVIATIONS
# ============================================================================

library(readxl)
library(ggplot2)
library(dplyr)
library(stringr)

# ============================================================================
# 1. LOAD DATA
# ============================================================================

cat("Please select your Excel file...\n")

data <- read_excel(file.choose())

# Clean column names
colnames(data) <- gsub(" ", "", colnames(data))
colnames(data) <- gsub("-", "", colnames(data))
colnames(data) <- gsub("\\.", "", colnames(data))

# ============================================================================
# 2. DATA PREPARATION
# ============================================================================

plot_data <- data %>%
  mutate(
    
    # --- 1. Get Count (DEGs) ---
    # If Count is absent, extract numerator from DiffRatio
    
    Count = if ("Count" %in% colnames(.)) {
      as.numeric(Count)
    } else {
      as.numeric(
        sapply(strsplit(as.character(DiffRatio), "/"), `[`, 1)
      )
    },
    
    # --- 2. Calculate Rich Factor ---
    # Rich Factor = Count / background genes in term
    
    BgTermCount = sapply(as.character(BgRatio), function(x) {
      
      clean_x <- sub(" .*", "", x)
      
      as.numeric(
        unlist(strsplit(clean_x, "/"))[1]
      )
    }),
    
    RichFactor = Count / BgTermCount,
    
    # --- 3. Other Metrics ---
    
    Pvalue = as.numeric(Pvalue),
    Up = as.numeric(Up),
    Down = as.numeric(Down),
    
    Total_Genes = Up + Down,
    
    RegRatio = if_else(
      Total_Genes > 0,
      Up / Total_Genes,
      0.5
    ),
    
    # --- 4. Abbreviations (BP, CC, MF) ---
    
    Category = case_when(
      grepl("biological", Ontology, ignore.case = TRUE) ~ "BP",
      grepl("cellular", Ontology, ignore.case = TRUE) ~ "CC",
      grepl("molecular", Ontology, ignore.case = TRUE) ~ "MF",
      TRUE ~ as.character(Ontology)
    ),
    
    # --- 5. Significance ---
    
    Significance = if_else(
      Pvalue <= 0.05,
      "Significant",
      "Not Significant"
    )
    
  ) %>%
  
  # Remove rows with invalid Rich Factor or P-value
  filter(
    !is.na(RichFactor),
    !is.na(Pvalue),
    !is.infinite(RichFactor)
  ) %>%
  
  # Top 30 by smallest P-value
  arrange(Pvalue) %>%
  slice_head(n = 30) %>%
  
  # Reorder for plotting
  arrange(Category, RichFactor) %>%
  mutate(
    Description = factor(
      Description,
      levels = unique(Description)
    )
  )

# ============================================================================
# 3. PLOT GENERATION
# ============================================================================

plot_main <- ggplot(
  plot_data,
  aes(
    x = RichFactor,
    y = Description,
    size = Count,
    fill = RegRatio
  )
) +
  
  # ==========================================================
# SIGNIFICANCE - UPDATED
# ==========================================================

# Not significant: thin gray border
geom_point(
  data = plot_data %>%
    filter(Significance == "Not Significant"),
  aes(color = Significance),
  shape = 21,
  stroke = 0.5,
  alpha = 0.9
) +
  
  # Significant: thick dark navy border
  geom_point(
    data = plot_data %>%
      filter(Significance == "Significant"),
    aes(color = Significance),
    shape = 21,
    stroke = 1.5,
    alpha = 0.9
  ) +
  
  # ==========================================================
# REGULATION COLORS - UNCHANGED
# ==========================================================

scale_fill_gradient2(
  low = "#2166AC",
  mid = "#F7F7F7",
  high = "#B2182B",
  midpoint = 0.5,
  name = "Regulation",
  breaks = c(0, 0.5, 1),
  labels = c("Down", "Mixed", "Up"),
  limits = c(0, 1)
) +
  
  # ==========================================================
# SIGNIFICANCE LEGEND - UPDATED
# ==========================================================

scale_color_manual(
  values = c(
    "Significant" = "#053061",
    "Not Significant" = "#777777"
  ),
  breaks = c(
    "Significant",
    "Not Significant"
  ),
  name = "Significance\n(circle border)",
  guide = guide_legend(
    override.aes = list(
      shape = 21,
      fill = "white",
      size = 4.8
    )
  )
) +
  
  # Gene count size
  scale_size_continuous(
    name = "Gene Count",
    range = c(3, 8)
  ) +
  
  # Facet with abbreviations
  facet_wrap(
    ~Category,
    scales = "free_y",
    ncol = 1,
    strip.position = "top"
  ) +
  
  # Original theme preserved
  theme_minimal() +
  
  theme(
    panel.border = element_rect(
      color = "black",
      fill = NA,
      linewidth = 0.5
    ),
    
    strip.text = element_text(
      face = "bold",
      size = 12,
      color = "navy"
    ),
    
    axis.text.y = element_text(
      size = 13,
      color = "black"
    ),
    
    axis.text.x = element_text(
      face = "bold",
      color = "black"
    ),
    
    axis.title = element_text(
      face = "bold",
      color = "navy"
    ),
    
    legend.position = "right",
    
    plot.title = element_text(
      face = "bold",
      hjust = 0.5
    )
  ) +
  
  labs(
    title = "",
    x = "Rich Factor",
    y = NULL
  )

# ============================================================================
# 4. DISPLAY
# ============================================================================

print(plot_main)

# ============================================================================
# 5. SAVE
# ============================================================================

ggsave(
  "Figure_6_GO_Rich_Factor_Bubble_Plot.png",
  plot_main,
  width = 12,
  height = 10,
  dpi = 600,
  bg = "white"
)

cat("\n✓ Saved: Figure_6_GO_Rich_Factor_Bubble_Plot.png\n")
