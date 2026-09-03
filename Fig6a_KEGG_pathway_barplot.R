
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
colnames(data) <- gsub(" ", "_", colnames(data))
colnames(data) <- gsub("-", "_", colnames(data))  # P-value -> P_value, etc.

# ============================================================================
# 2. DATA PREPARATION
# ============================================================================

plot_data <- data %>%
  mutate(
    # 1. Parse Percent from DiffRatio ("33/499 6.61%" -> 33/499 -> %) 
    DiffRatio_Clean = sub(" .*", "", as.character(DiffRatio)),
    GeneRatio = sapply(DiffRatio_Clean, function(x) {
      parts <- as.numeric(unlist(strsplit(x, "/")))
      if (length(parts) == 2) return((parts[1] / parts[2]) * 100) else return(NA)
    }),
    
    # 2. Ensure numeric columns
    P_value = as.numeric(P_value),
    Up      = as.numeric(Up),
    Down    = as.numeric(Down),
    Count   = as.numeric(Count),
    
    # 3. Regulation ratio (0 = all down, 1 = all up)
    Reg_Ratio = Up / (Up + Down),
    
    # 4. Label: "33 (6.61%)"
    Label_Text = paste0(Count, " (", round(GeneRatio, 2), "%)")
  ) %>%
  # Only significant pathways
  filter(P_value < 0.05, !is.na(GeneRatio), !is.na(Reg_Ratio)) %>%
  # Top 10 per KEGG_level_1 by smallest P-value
  group_by(KEGG_level_1) %>%
  arrange(P_value) %>%
  slice_head(n = 10) %>%
  ungroup() %>%
  # Order factors for plotting
  mutate(
    KEGG_level_1 = factor(KEGG_level_1),
    KEGG_Pathway = factor(
      KEGG_Pathway,
      levels = unique(KEGG_Pathway[order(KEGG_level_1, GeneRatio)])
    )
  )

cat("\nTotal pathways to plot:", nrow(plot_data), "\n")
print(table(plot_data$KEGG_level_1))

# ============================================================================
# 3. PLOT (BLUE – LIGHT BLUE‑GREY – MAGENTA)
# ============================================================================

p <- ggplot(plot_data, aes(x = GeneRatio, y = KEGG_Pathway)) +
  
  # Bars colored by regulation ratio
  geom_bar(
    aes(fill = Reg_Ratio),
    stat = "identity",
    width = 0.8,
    color = "white",
    linewidth = 0.2
  ) +
  
  # Text labels at end of bars
  geom_text(
    aes(label = Label_Text),
    hjust = -0.1,
    size = 3.5,
    color = "black"
  ) +
  
  # Facet by KEGG_level_1 with labels on the right
  facet_grid(
    KEGG_level_1 ~ .,
    scales = "free_y",
    space  = "free_y",
    switch = "y"
  ) +
  
  # ------- COLOR SCALE (OPTION 2) -------
# Down = #2E86AB (blue), Up = #A23B72 (magenta), Mixed = #BFD3E6
scale_fill_gradient2(
  low  = "#2E86AB",   # Down
  mid  = "#BFD3E6",   # Mixed (light blue‑grey; visible on white)
  high = "#A23B72",   # Up
  midpoint = 0.5,
  name = "Regulation",
  limits = c(0, 1),
  breaks = c(0, 0.5, 1),
  labels = c("Down", "Mixed", "Up")
) +
  
  # X axis (Percent)
  scale_x_continuous(
    expand = expansion(mult = c(0, 0.2)),  # extra space for labels
    name   = "Percent (%)"
  ) +
  
  theme_classic() +
  theme(
    # Legend
    legend.position = "right",
    legend.title    = element_text(face = "bold", size = 10),
    legend.text     = element_text(size = 9),
    
    # Axes
    axis.text.y  = element_text(size = 10, color = "black"),
    axis.text.x  = element_text(size = 10, color = "black"),
    axis.title.x = element_text(size = 12, face = "bold", margin = margin(t = 10)),
    axis.title.y = element_blank(),
    
    # Facet strips on the right
    strip.background = element_blank(),
    strip.text.y     = element_text(
      angle  = 0,
      size   = 11,
      hjust  = 0,
      margin = margin(l = 10)
    ),
    strip.placement  = "outside",
    
    panel.spacing = unit(0.2, "cm"),
    plot.margin   = margin(10, 50, 10, 10)
  ) +
  labs(title = NULL)

print(p)

# ============================================================================
# 4. SAVE
# ============================================================================

plot_height <- 2 + nrow(plot_data) * 0.25

ggsave(
  filename = "KEGG_Top10_Blue_LightGrey_Magenta.png",
  plot     = p,
  width    = 12,
  height   = plot_height,
  dpi      = 600
)

cat(sprintf("\n✓ Saved: KEGG_Top10_Blue_LightGrey_Magenta.png (Height: %.1f in)\n",
            plot_height))