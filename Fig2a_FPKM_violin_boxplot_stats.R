options(timeout = 300)

# ── Libraries ─────────────────────────────────────────────────
library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)
library(ggpubr)
library(rstatix)

# ── 1. Load data ──────────────────────────────────────────────
## NOTE: Replace the path below with the location of your gene_fpkm.xls.xlsx
## file, or use file.choose() to select it interactively.
file_path <- file.choose()

data <- read_excel(file_path)

# ── 2. Select six samples and reshape to long format ──────────
sample_cols <- c(
  "PrimaryMusc", "PrimaryMusc2",
  "ImmorMuscEP", "ImmorMuscEP2",
  "ImmorMuscLP", "ImmorMuscLP2"
)

fpkm_long <- data %>%
  select(gene_id, all_of(sample_cols)) %>%
  pivot_longer(
    cols = all_of(sample_cols),
    names_to = "sample",
    values_to = "FPKM"
  ) %>%
  mutate(
    FPKM = as.numeric(FPKM),
    log2_fpkm = log2(FPKM + 1),
    
    # Combine the two replicates into each experimental group
    group = case_when(
      sample %in% c("PrimaryMusc", "PrimaryMusc2") ~ "Control",
      sample %in% c("ImmorMuscEP", "ImmorMuscEP2") ~ "TRT1",
      sample %in% c("ImmorMuscLP", "ImmorMuscLP2") ~ "TRT2",
      TRUE ~ NA_character_
    ),
    
    sample = factor(sample, levels = sample_cols),
    group = factor(group, levels = c("Control", "TRT1", "TRT2"))
  ) %>%
  filter(!is.na(log2_fpkm), !is.na(group))

# ── 3. Verify sample/group mapping and data counts ────────────
cat("\nSample-to-group mapping:\n")
print(fpkm_long %>% distinct(sample, group))

cat("\nNumber of values per group:\n")
print(fpkm_long %>% count(group))

cat("\nNumber of values per sample:\n")
print(fpkm_long %>% count(sample))

# ── 4. Kruskal-Wallis test: three pooled groups ───────────────
kruskal_group <- fpkm_long %>%
  kruskal_test(log2_fpkm ~ group)

cat("\nKruskal-Wallis test by pooled group:\n")
print(kruskal_group)

# Export Kruskal-Wallis result
write.csv(
  as.data.frame(kruskal_group),
  "kruskal_group.csv",
  row.names = FALSE
)

# ── 5. Pairwise Wilcoxon tests: BH adjustment ─────────────────
# Keep this object clean: statistical output only.
pairwise_group <- fpkm_long %>%
  pairwise_wilcox_test(
    log2_fpkm ~ group,
    p.adjust.method = "BH"
  ) %>%
  add_significance()

cat("\nPairwise Wilcoxon tests by pooled group (BH-adjusted):\n")
print(
  pairwise_group %>%
    select(group1, group2, n1, n2, statistic, p, p.adj, p.adj.signif)
)

# Select only normal atomic columns before CSV export.
# This prevents: "unimplemented type 'list' in 'EncodeElement'"
pairwise_group_export <- pairwise_group %>%
  ungroup() %>%
  select(
    .y.,
    group1,
    group2,
    n1,
    n2,
    statistic,
    p,
    p.adj,
    p.adj.signif
  ) %>%
  as.data.frame()

write.csv(
  pairwise_group_export,
  "pairwise_group_wilcox_BH.csv",
  row.names = FALSE
)

# Separate object for graph bracket coordinates only.
pairwise_group_plot <- pairwise_group %>%
  add_xy_position(x = "group")

# ── 6. Three-group violin + boxplot ───────────────────────────
p_group <- ggplot(
  fpkm_long,
  aes(
    x = group,
    y = log2_fpkm,
    fill = group,
    color = group
  )
) +
  geom_violin(
    trim = FALSE,
    scale = "width",
    adjust = 1.2,
    width = 0.9,
    alpha = 0.20,
    linewidth = 1
  ) +
  geom_boxplot(
    width = 0.12,
    outlier.shape = NA,
    alpha = 0.35,
    linewidth = 1.1
  ) +
  stat_boxplot(
    width = 0.12,
    geom = "errorbar",
    linewidth = 1
  ) +
  stat_pvalue_manual(
    pairwise_group_plot,
    label = "p.adj.signif",
    hide.ns = FALSE,
    tip.length = 0.01,
    size = 5
  ) +
  scale_fill_manual(
    values = c(
      "Control" = "#F8766D",
      "TRT1" = "#00BA38",
      "TRT2" = "#619CFF"
    )
  ) +
  scale_color_manual(
    values = c(
      "Control" = "#F8766D",
      "TRT1" = "#00BA38",
      "TRT2" = "#619CFF"
    )
  ) +
  labs(
    title = "FPKM distribution by group with statistics",
    x = NULL,
    y = "log2(FPKM + 1)",
    caption = paste0(
      "Kruskal-Wallis: p = ",
      signif(kruskal_group$p, 3),
      " | Pairwise Wilcoxon: BH-adjusted p-values\n",
      "ns = not significant; * p < 0.05; ** p < 0.01; ",
      "*** p < 0.001; **** p < 0.0001"
    )
  ) +
  theme_classic(base_size = 16) +
  theme(
    plot.title = element_text(hjust = 0.5),
    legend.position = "none",
    plot.caption = element_text(
      size = 9,
      hjust = 0.5,
      color = "grey40"
    )
  )

print(p_group)

ggsave(
  filename = "violin_boxplot_3groups_stats_BH.png",
  plot = p_group,
  width = 9,
  height = 8,
  dpi = 600
)

# ── 7. Optional: test individual six samples separately ───────
kruskal_sample <- fpkm_long %>%
  kruskal_test(log2_fpkm ~ sample)

pairwise_sample <- fpkm_long %>%
  pairwise_wilcox_test(
    log2_fpkm ~ sample,
    p.adjust.method = "BH"
  ) %>%
  add_significance()

cat("\nKruskal-Wallis test by individual sample:\n")
print(kruskal_sample)

cat("\nPairwise Wilcoxon tests by individual sample (BH-adjusted):\n")
print(
  pairwise_sample %>%
    select(group1, group2, n1, n2, statistic, p, p.adj, p.adj.signif)
)

# Export six-sample results, using only CSV-compatible columns
kruskal_sample_export <- as.data.frame(kruskal_sample)

pairwise_sample_export <- pairwise_sample %>%
  ungroup() %>%
  select(
    .y.,
    group1,
    group2,
    n1,
    n2,
    statistic,
    p,
    p.adj,
    p.adj.signif
  ) %>%
  as.data.frame()

write.csv(
  kruskal_sample_export,
  "kruskal_sample.csv",
  row.names = FALSE
)

write.csv(
  pairwise_sample_export,
  "pairwise_sample_wilcox_BH.csv",
  row.names = FALSE
)

cat("\nAnalysis complete.\n")