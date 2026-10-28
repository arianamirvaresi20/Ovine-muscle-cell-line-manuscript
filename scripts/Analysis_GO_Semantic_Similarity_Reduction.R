# ============================================================================
# Analysis_GO_Semantic_Similarity_Reduction.R
# Figure(s): Supporting analysis; no unique panel assigned
# Purpose: GO semantic similarity and redundancy reduction
# Package version: v1.1 (prepared 2026-10-27)
# Run setup/Install_Dependencies.R once before running this script.
# Read README.md for data columns, figure mapping, and validation limitations.
# ============================================================================

# Install if needed:
# BiocManager::install(c("rrvgo", "org.Bt.eg.db"))
# The organism package for sheep is org.Oa.eg.db if available,
# otherwise use org.Bt.eg.db (bovine) as closest available
# 1. Install BiocManager if you don't have it
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

# Setup handles this: BiocManager::install("org.Bt.eg.db", ask = FALSE)
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

# 2. Install rrvgo from Bioconductor
# Setup handles this: BiocManager::install("rrvgo")

# 3. Install the bovine annotation package used in your code
# Setup handles this: BiocManager::install("org.Bt.eg.db")
library(readxl)
library(rrvgo)
library(dplyr)
library(ggplot2)

# ── FUNCTION: process one GO enrichment file ──────────────────
process_go_file <- function(filepath, comparison_name, ont = "BP") {
  
  df <- read_excel(filepath)
  
  # Keep only the ontology of interest and significant terms
  df_filtered <- df %>%
    filter(Category == ont, padj <= 0.05) %>%
    select(GOID, Description, padj) %>%
    filter(!is.na(GOID))
  
  cat("\n", comparison_name, "-", ont, ": Raw terms =", nrow(df_filtered), "\n")
  
  if (nrow(df_filtered) < 2) {
    cat("Not enough terms for reduction\n")
    return(NULL)
  }
  
  # Calculate semantic similarity matrix
  simMatrix <- calculateSimMatrix(
    df_filtered$GOID,
    orgdb   = "org.Bt.eg.db",   # replace with org.Oa.eg.db if sheep db available
    ont     = ont,
    method  = "Rel"
  )
  
  # Score by -log10(padj)
  scores <- setNames(-log10(df_filtered$padj), df_filtered$GOID)
  scores <- scores[rownames(simMatrix)]
  
  # Reduce at threshold 0.7
  reducedTerms <- reduceSimMatrix(
    simMatrix,
    scores    = scores,
    threshold = 0.7,
    orgdb     = "org.Bt.eg.db"
  )
  
  n_independent <- length(unique(reducedTerms$cluster))
  cat("  Independent (non-redundant) terms =", n_independent, "\n")
  
  # Treemap plot
  png(paste0("treemap_", comparison_name, "_", ont, ".png"),
      width = 1200, height = 900, res = 150)
  treemapPlot(reducedTerms,
              title = paste(comparison_name, "-", ont))
  dev.off()
  
  return(list(
    comparison      = comparison_name,
    ontology        = ont,
    raw_terms       = nrow(df_filtered),
    independent_terms = n_independent,
    reduced         = reducedTerms
  ))
}

# ── LOAD YOUR THREE FILES ─────────────────────────────────────
# Replace file paths with your actual file locations
message("Select GO table: EPILM versus PLM")
file_plm_epilm <- file.choose()
message("Select GO table: LPILM versus EPILM")
file_epilm_lpilm <- file.choose()
message("Select GO table: LPILM versus PLM")
file_plm_lpilm <- file.choose()

# ── RUN FOR ALL THREE COMPARISONS AND ALL ONTOLOGIES ─────────
ontologies <- c("BP", "CC", "MF")

results <- list()

for (ont in ontologies) {
  results[[paste0("PLM_EPILM_", ont)]] <- process_go_file(
    file_plm_epilm,   "PLM_vs_EPILM",   ont)
  
  results[[paste0("EPILM_LPILM_", ont)]] <- process_go_file(
    file_epilm_lpilm, "EPILM_vs_LPILM", ont)
  
  results[[paste0("PLM_LPILM_", ont)]] <- process_go_file(
    file_plm_lpilm,   "PLM_vs_LPILM",   ont)
}

# ── SUMMARY TABLE ─────────────────────────────────────────────
summary_df <- bind_rows(lapply(results, function(x) {
  if (!is.null(x)) {
    data.frame(
      Comparison        = x$comparison,
      Ontology          = x$ontology,
      Raw_Terms         = x$raw_terms,
      Independent_Terms = x$independent_terms
    )
  }
}))

print(summary_df)
write.csv(summary_df, "GO_semantic_reduction_summary.csv", row.names = FALSE)

# ── BAR PLOT COMPARING RAW VS INDEPENDENT ─────────────────────
summary_long <- summary_df %>%
  tidyr::pivot_longer(cols = c(Raw_Terms, Independent_Terms),
                      names_to  = "Type",
                      values_to = "Count")

p <- ggplot(summary_long,
            aes(x = Comparison, y = Count, fill = Type)) +
  # or, explicitly:
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~Ontology) +
  scale_fill_manual(values = c("Raw_Terms"         = "#F4A9A0",
                               "Independent_Terms" = "#77C77A")) +
  labs(title = "Raw vs. Semantically Reduced GO Terms",
       x     = "Comparison",
       y     = "Number of GO Terms",
       fill  = "") +
  theme_classic(base_size = 13) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, face = "bold"))

ggsave("GO_raw_vs_reduced.png", p, width = 12, height = 6, dpi = 600)
