# Install once from an interactive R/RStudio session with internet access.
# Versions are not pinned: the original R/package versions were not supplied.
options(repos = c(CRAN = "https://cloud.r-project.org"))
cran_packages <- c(
  "readxl", "ggplot2", "dplyr", "tidyr", "stringr", "scales", "svglite",
  "showtext", "sysfonts", "ragg", "Cairo", "ggpubr", "rstatix", "broom",
  "multcompView", "pheatmap", "paletteer", "BiocManager"
)
missing <- cran_packages[!vapply(cran_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) install.packages(missing)
bioc_packages <- c("rrvgo", "org.Bt.eg.db")
missing_bioc <- bioc_packages[!vapply(bioc_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_bioc)) BiocManager::install(missing_bioc, ask = FALSE, update = FALSE)
message("Dependency check complete. See README.md for platform/font requirements.")
