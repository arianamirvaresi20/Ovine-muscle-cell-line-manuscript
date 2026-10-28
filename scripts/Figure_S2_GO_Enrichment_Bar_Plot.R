# ============================================================================
# Figure_S2_GO_Enrichment_Bar_Plot.R
# Figure(s): S2
# Purpose: GO enrichment bar plot and summary table
# Package version: v1.1 (prepared 2026-10-27)
# Run setup/Install_Dependencies.R once before running this script.
# Read README.md for data columns, figure mapping, and validation limitations.
# ============================================================================

# ============================================================================
# GO ENRICHMENT BAR PLOT - OPTION 2 (BLUE-WHITE-RED)
# 15 ITEMS, ABBREVIATIONS, UP/DOWN LABELS REMOVED
# ============================================================================

# Load libraries
library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)

# ============================================================================
# 1. LOAD DATA
# ============================================================================
data <- read_excel(file.choose())

cat("=== DATA LOADED ===\n")
print(head(data))

# ============================================================================
# 2. DATA PREPARATION
# ============================================================================

p_threshold <- 0.05
top_n <- 15

# Add abbreviations
data <- data %>%
  mutate(
    Ontology_Abbr = case_when(
      Ontology == "Biological process" ~ "BP",
      Ontology == "Molecular function" ~ "MF",
      Ontology == "Cellular component" ~ "CC",
      TRUE ~ Ontology
    )
  )

# Filter data by p-value
top_terms <- data %>%
  group_by(Ontology) %>%
  arrange(`P-value`) %>%
  slice_head(n = top_n) %>%
  filter(`P-value` < p_threshold) %>%
  ungroup() %>%
  mutate(
    Percent = (Count / 711) * 100,
    Ratio = Up / (Up + Down),
    Up_label = sprintf("↑%d", Up),
    Down_label = sprintf("↓%d", Down)
  ) %>%
  arrange(Ontology, desc(`P-value`)) %>%
  mutate(Description = factor(Description, levels = Description))

cat(sprintf("\nTotal terms after filtering: %d\n", nrow(top_terms)))

# Show summary
cat("\n=== UP/DOWN REGULATION SUMMARY ===\n")
print(top_terms %>% 
        group_by(Ontology_Abbr) %>%
        summarise(
          Terms = n(),
          Total_Up = sum(Up),
          Total_Down = sum(Down),
          .groups = 'drop'
        ))

# ============================================================================
# 3. CREATE VERTICAL PLOT (OPTION 2 COLOR - NO UP/DOWN LABELS)
# ============================================================================

p_vertical <- ggplot(top_terms, aes(x = Percent, y = Description)) +
  
  geom_bar(
    stat = "identity",
    width = 0.7,
    aes(fill = Ratio),
    color = "white",
    linewidth = 0.5
  ) +
  
  # Count and percentage at end of bar (ONLY LABEL)
  geom_text(
    aes(x = Percent, label = sprintf("%d (%.2f%%)", Count, Percent)),
    hjust = -0.1,
    size = 4,
    color = "#333333",
    fontface = "plain"
  ) +
  
  # Facet by ontology
  facet_grid(
    Ontology_Abbr ~ .,
    scales = "free_y",
    space = "free_y",
    switch = "y"
  ) +
  
  # OPTION 2: Blue-White-Red (Classic Scientific)
  scale_fill_gradient2(
    low = "#2E86AB",     # Deep Blue (Down)
    mid = "#FFFFFF",     # White (Balanced)
    high = "#A23B72",    # Deep Red/Pink (Up)
    midpoint = 0.5,
    name = "",
    limits = c(0, 1),
    breaks = c(0, 0.25, 0.5, 0.75, 1.0),
    labels = c("All\nDown", "Mostly\nDown", "Balanced", "Mostly\nUp", "All\nUp")
  ) +
  
  scale_x_continuous(
    expand = expansion(mult = c(0.01, 0.2)),
    breaks = seq(0, max(top_terms$Percent, na.rm = TRUE) + 1, by = 2)
  ) +
  
  theme_minimal() +
  theme(
    strip.text.y.left = element_text(
      angle = 0,
      size = 12,
      face = "bold",
      hjust = 1,
      color = "#1B3A5E",
      margin = margin(r = 10)
    ),
    strip.placement = "outside",
    strip.background = element_blank(),
    axis.title.x = element_text(size = 12, face = "bold", color = "#333333", margin = margin(t = 10)),
    axis.title.y = element_blank(),
    axis.text.x = element_text(size = 11, color = "#333333"),
    axis.text.y = element_text(size = 11, color = "#333333", hjust = 1),
    panel.grid.major.x = element_line(color = "#E0E0E0", linewidth = 0.3),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    panel.spacing.y = unit(0.5, "cm"),
    panel.border = element_blank(),
    legend.position = "right",
    legend.title = element_text(size = 10, face = "bold", color = "#333333"),
    legend.text = element_text(size = 10, color = "#333333"),
    legend.key.height = unit(0.8, "cm"),
    legend.key.width = unit(0.5, "cm"),
    plot.margin = margin(15, 15, 15, 15),
    plot.title = element_text(size = 13, face = "bold", hjust = 0.5, color = "#1B3A5E"),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "#666666"),
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA)
  ) +
  
  labs(
    x = "Percent (%)",
    y = NULL,
    title = "GO Enrichment Analysis (BP/MF/CC)",
    subtitle = sprintf("Top %d enriched terms per category (p < %.3f)", top_n, p_threshold)
  )

print(p_vertical)

# ============================================================================
# 4. SAVE PLOT
# ============================================================================

# Calculate heights dynamically
n_terms <- nrow(top_terms)
vertical_height <- max(12, min(22, 4 + n_terms * 0.2))

cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("Saving plot...\n")

# Save vertical PNG
ggsave(
  filename = "Figure_S2_GO_Enrichment_Bar_Plot.png",
  plot = p_vertical,
  width = 11,
  height = vertical_height,
  dpi = 600,
  units = "in",
  bg = "white",
  limitsize = FALSE
)

# Save vertical PDF
ggsave(
  filename = "Figure_S2_GO_Enrichment_Bar_Plot.pdf",
  plot = p_vertical,
  width = 11,
  height = vertical_height,
  dpi = 600,
  units = "in",
  bg = "white",
  limitsize = FALSE
)

cat(sprintf("✓ Saved: Figure_S2_GO_Enrichment_Bar_Plot.png (11 x %.1f inches)\n", vertical_height))
cat("✓ Saved: Figure_S2_GO_Enrichment_Bar_Plot.pdf\n")

# ============================================================================
# 5. SUMMARY STATISTICS
# ============================================================================

cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("=== SUMMARY BY CATEGORY ===\n")
cat(rep("=", 80), "\n", sep = "")

summary_by_category <- top_terms %>%
  group_by(Ontology_Abbr, Ontology) %>%
  summarise(
    Terms = n(),
    Total_Up = sum(Up),
    Total_Down = sum(Down),
    Total_Genes = sum(Count),
    Avg_Ratio = mean(Ratio),
    Min_PValue = min(`P-value`),
    Max_PValue = max(`P-value`),
    .groups = 'drop'
  )

print(summary_by_category)

cat("\n=== OVERALL STATISTICS ===\n")
cat(sprintf("Total terms plotted: %d\n", nrow(top_terms)))
cat(sprintf("Total Up-regulated genes: %d\n", sum(top_terms$Up)))
cat(sprintf("Total Down-regulated genes: %d\n", sum(top_terms$Down)))
cat(sprintf("Overall Up ratio: %.2f%%\n", 
            (sum(top_terms$Up) / (sum(top_terms$Up) + sum(top_terms$Down))) * 100))

# Top 5 most significant
cat("\n=== TOP 5 MOST SIGNIFICANT TERMS ===\n")
top_5_print <- top_terms %>%
  arrange(`P-value`) %>%
  head(5) %>%
  select(Ontology_Abbr, Description, `P-value`, Up, Down) %>%
  mutate(`P-value` = format(`P-value`, scientific = TRUE))

print(top_5_print)

# Top 5 most up-regulated
cat("\n=== TOP 5 MOST UP-REGULATED TERMS ===\n")
top_5_up <- top_terms %>%
  arrange(desc(Ratio)) %>%
  head(5) %>%
  select(Ontology_Abbr, Description, Up, Down, Count) %>%
  mutate(Up_Ratio = scales::percent(Up / (Up + Down), accuracy = 1))

print(top_5_up)

# Top 5 most down-regulated
cat("\n=== TOP 5 MOST DOWN-REGULATED TERMS ===\n")
top_5_down <- top_terms %>%
  arrange(Ratio) %>%
  head(5) %>%
  select(Ontology_Abbr, Description, Up, Down, Count) %>%
  mutate(Down_Ratio = scales::percent(Down / (Up + Down), accuracy = 1))

print(top_5_down)

# Save detailed summary
write.csv(
  top_terms %>% 
    select(Ontology, Ontology_Abbr, Description, `P-value`, FDR, Count, Up, Down, Percent, Ratio) %>%
    arrange(Ontology, `P-value`),
  "Figure_S2_GO_Enrichment_Summary.csv",
  row.names = FALSE
)

cat("\n✓ Saved: Figure_S2_GO_Enrichment_Summary.csv\n")

cat("\n")
cat(rep("=", 80), "\n", sep = "")
cat("=== COMPLETE ===\n")
cat(rep("=", 80), "\n", sep = "")
cat("\n")
cat("ABBREVIATIONS:\n")
cat("  BP = Biological Process\n")
cat("  MF = Molecular Function\n")
cat("  CC = Cellular Component\n")
cat("\nCOLOR GRADIENT (OPTION 2):\n")
cat("  🔵 BLUE (#2E86AB) = Down-regulated genes\n")
cat("  ⚪ WHITE (#FFFFFF) = Balanced Up/Down\n")
cat("  🔴 RED (#A23B72) = Up-regulated genes\n\n")
