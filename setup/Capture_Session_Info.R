# Run AFTER installing packages and executing the relevant analysis.
# This records the current environment; it cannot recover historical versions.
packages <- c("readxl", "ggplot2", "dplyr", "tidyr", "stringr", "scales",
              "svglite", "showtext", "sysfonts", "ragg", "Cairo", "ggpubr",
              "rstatix", "broom", "multcompView", "pheatmap", "paletteer",
              "rrvgo", "org.Bt.eg.db")
installed <- packages[vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
versions <- data.frame(package = installed,
                       version = vapply(installed, function(x) as.character(utils::packageVersion(x)), character(1)))
utils::write.csv(versions, "Package_Versions.csv", row.names = FALSE)
capture.output(utils::sessionInfo(), file = "Session_Info_Current.txt")
message("Saved current R session info and installed package versions.")
