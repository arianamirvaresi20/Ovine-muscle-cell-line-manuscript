# ============================================================================
# Figure_5c_Kmeans_Cluster_Profiles.R
# Figure(s): 5c
# Purpose: Profiles of pre-assigned clusters; does not perform k-means fitting
# Package version: v1.1 (prepared 2026-10-27)
# Run setup/Install_Dependencies.R once before running this script.
# Read README.md for data columns, figure mapping, and validation limitations.
# ============================================================================

#
# ============================================================================
# K-MEANS ALL CLUSTERS PROFILE PLOT (FOR GENE DATA)
# ============================================================================

# Install required packages (run once)
# Setup handles this: install.packages("readxl")
# Setup handles this: install.packages("ggplot2")
# Setup handles this: install.packages("dplyr")
# Setup handles this: install.packages("tidyr")

# Load libraries
library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

# ============================================================================
# 1. LOAD DATA
# ============================================================================
data <- read_excel(file.choose())

cat("=== COLUMN NAMES ===\n")
print(colnames(data))

# ============================================================================
# 2. DATA PREPARATION
# ============================================================================

# Rename columns for clarity
colnames(data)[1] <- "Gene"
colnames(data)[2] <- "Sub_class"

# Identify sample columns
sample_cols <- colnames(data)[3:ncol(data)]

cat("\nSample columns:", paste(sample_cols, collapse = ", "), "\n")

# Convert to proper format
data_clean <- data %>%
  mutate(Sub_class = as.character(Sub_class)) %>%
  mutate(across(all_of(sample_cols), as.numeric))

cat("\n=== AVAILABLE CLUSTERS ===\n")
available_clusters <- sort(unique(data_clean$Sub_class))
print(available_clusters)

# ============================================================================
# 3. CALCULATE STATISTICS FOR ALL CLUSTERS
# ============================================================================

cat("\n⏳ Calculating statistics for all clusters...\n")

# Transform to long format
data_long <- data_clean %>%
  select(Gene, Sub_class, all_of(sample_cols)) %>%
  pivot_longer(
    cols = all_of(sample_cols),
    names_to = "Sample",
    values_to = "Value"
  )

# Calculate summary statistics for each cluster and sample
summary_stats <- data_long %>%
  group_by(Sub_class, Sample) %>%
  summarise(
    Mean = mean(Value, na.rm = TRUE),
    SD = sd(Value, na.rm = TRUE),
    N = n(),
    SE = SD / sqrt(N),
    CI_lower = Mean - 1.96 * SE,
    CI_upper = Mean + 1.96 * SE,
    .groups = 'drop'
  )

# Get cluster counts
cluster_counts <- data_clean %>%
  group_by(Sub_class) %>%
  summarise(Total = n(), .groups = 'drop')

summary_stats <- summary_stats %>%
  left_join(cluster_counts, by = "Sub_class") %>%
  mutate(Cluster_label = paste0("Sub class ", Sub_class, ", total: ", Total))

# Order samples
summary_stats$Sample <- factor(summary_stats$Sample, levels = sample_cols)

cat("✅ Statistics calculated!\n")

# ============================================================================
# 4. DEFINE COLORS
# ============================================================================

cluster_colors <- c(
  "1" = "#DC143C",   # Red
  "2" = "#FF8C00",   # Orange
  "3" = "#FFD700",   # Gold
  "4" = "#32CD32",   # Green
  "5" = "#90EE90",   # Light green
  "6" = "#4169E1",   # Blue
  "7" = "#9370DB"    # Purple
)

# ============================================================================
# 5. CREATE PLOT WITH ALL CLUSTERS
# ============================================================================

cat("\n⏳ Creating plot...\n")

p <- ggplot(summary_stats, aes(x = Sample, y = Mean, group = Sub_class)) +
  
  # Confidence interval ribbon
  geom_ribbon(
    aes(ymin = CI_lower, ymax = CI_upper, fill = Sub_class),
    alpha = 0.35,
    color = NA
  ) +
  
  # Mean line
  geom_line(
    aes(color = Sub_class),
    linewidth = 1.2,
    lineend = "round"
  ) +
  
  # Points
  geom_point(
    aes(color = Sub_class),
    size = 3.5,
    shape = 21,
    fill = "white",
    stroke = 1.3
  ) +
  
  # Colors
  scale_color_manual(values = cluster_colors, guide = "none") +
  scale_fill_manual(values = cluster_colors, guide = "none") +
  
  # Facet by cluster
  facet_wrap(~Cluster_label, ncol = 4, scales = "free_y") +
  
  # Themes
  theme_minimal() +
  theme(
    panel.border = element_rect(color = "#333333", fill = NA, linewidth = 0.6),
    panel.grid.major = element_line(color = "#E8E8E8", linewidth = 0.25),
    panel.grid.minor = element_blank(),
    panel.spacing = unit(0.5, "cm"),
    axis.text.x = element_text(size = 10, color = "#333333", angle = 0, hjust = 0.5),
    axis.text.y = element_text(size = 10, color = "#333333"),
    axis.title.x = element_blank(),
    axis.title.y = element_text(size = 11, face = "bold", color = "#333333"),
    strip.text = element_text(size = 11, face = "bold", color = "#1B3A5E"),
    plot.margin = margin(15, 15, 15, 15)
  ) +
  
  labs(
    y = "Standardised value",
    x = NULL
  )

cat("✅ Plot created!\n")

# ============================================================================
# 6. SAVE PLOT
# ============================================================================

cat("⏳ Saving high-resolution images...\n")

# Calculate dimensions
n_clusters <- length(available_clusters)
n_cols <- 4
n_rows <- ceiling(n_clusters / n_cols)
plot_height <- 3 + (n_rows - 1) * 2.8

ggsave(
  filename = "Figure_5c_Kmeans_Cluster_Profiles.png",
  plot = p,
  width = 14,
  height = plot_height,
  dpi = 600,
  units = "in",
  limitsize = FALSE
)

ggsave(
  filename = "Figure_5c_Kmeans_Cluster_Profiles.pdf",
  plot = p,
  width = 14,
  height = plot_height,
  dpi = 600,
  units = "in",
  limitsize = FALSE
)

cat(sprintf("✓ Saved: Figure_5c_Kmeans_Cluster_Profiles.png (14 x %.1f inches)\n", plot_height))
cat("✓ Saved: Figure_5c_Kmeans_Cluster_Profiles.pdf\n")

# Display
print(p)

# ============================================================================
# 7. SUMMARY STATISTICS
# ============================================================================

cat("\n=== CLUSTER SUMMARIES ===\n")

cluster_summary <- data_clean %>%
  group_by(Sub_class) %>%
  summarise(
    Total_Genes = n(),
    .groups = 'drop'
  ) %>%
  arrange(Sub_class)

print(cluster_summary)

write.csv(cluster_summary, "Figure_5c_Kmeans_Cluster_Summary.csv", row.names = FALSE)
cat("\n✓ Saved: Figure_5c_Kmeans_Cluster_Summary.csv\n")

# Save detailed statistics
write.csv(summary_stats, "Figure_5c_Kmeans_Cluster_Detailed_Statistics.csv", row.names = FALSE)
cat("✓ Saved: Figure_5c_Kmeans_Cluster_Detailed_Statistics.csv\n")

cat("\n=== COMPLETE ===\n")
cat(sprintf("Total clusters plotted: %d\n", n_clusters))
cat(sprintf("Layout: %d columns x %d rows\n", n_cols, n_rows))
