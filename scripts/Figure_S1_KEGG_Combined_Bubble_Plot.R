# ============================================================================
# Figure_S1_KEGG_Combined_Bubble_Plot.R
# Figure(s): S1
# Purpose: Combined KEGG enrichment bubble plots across three comparisons
# Package version: v1.1 (prepared 2026-10-27)
# Run setup/Install_Dependencies.R once before running this script.
# Read README.md for data columns, figure mapping, and validation limitations.
# ============================================================================

# ================================================================
# KEGG enrichment: three comparisons in ONE combined bubble figure
# Verified against EPvsPLM(3).xlsx (KEGGID, Description, GeneRatio,
# padj, Count, Up, Down).
#
# X = GeneRatio; bubble area = Count; fill = Up/(Up+Down);
# thick black outline = padj <= 0.05; thin gray = padj > 0.05.
# All panels share the same pathway rows and x-axis scale.
# ================================================================

packages <- c("readxl", "dplyr", "ggplot2", "ragg", "svglite")
missing_packages <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages)) stop(
  "Install these packages first: install.packages(c(",
  paste(sprintf('"%s"', missing_packages), collapse = ", "), "))"
)
library(readxl)
library(dplyr)
library(ggplot2)

message("Choose KEGG file 1: EPILM vs PLM")
f1 <- file.choose()
message("Choose KEGG file 2: LPILM vs PLM")
f2 <- file.choose()
message("Choose KEGG file 3: LPILM vs EPILM")
f3 <- file.choose()

input_files <- c("EPILM / PLM" = f1, "LPILM / PLM" = f2, "LPILM / EPILM" = f3)

parse_ratio <- function(v) {
  vapply(as.character(v), function(s) {
    if (is.na(s) || !nzchar(trimws(s))) return(NA_real_)
    parts <- strsplit(trimws(s), "/", fixed = TRUE)[[1]]
    if (length(parts) == 2L) {
      num <- suppressWarnings(as.numeric(parts[1]))
      den <- suppressWarnings(as.numeric(parts[2]))
      if (is.na(num) || is.na(den) || den == 0) return(NA_real_)
      return(num / den)
    }
    suppressWarnings(as.numeric(s))
  }, numeric(1))
}

read_kegg <- function(path, comparison) {
  x <- readxl::read_excel(path)
  names(x) <- trimws(names(x))
  id_candidates <- c("KEGGID", "keggID", "ID", "PathwayID", "pathway_id")
  id_column <- id_candidates[id_candidates %in% names(x)]
  if (length(id_column) == 0L) {
    stop("No KEGG pathway ID column found in ", comparison,
         ". Available columns: ", paste(names(x), collapse = ", "))
  }
  required <- c("Description", "GeneRatio", "padj", "Up", "Down")
  absent <- setdiff(required, names(x))
  if (length(absent)) {
    stop("Missing columns in ", comparison, ": ", paste(absent, collapse = ", "),
         ". Available: ", paste(names(x), collapse = ", "))
  }
  if (!"Count" %in% names(x)) x$Count <- as.numeric(x$Up) + as.numeric(x$Down)

  result <- data.frame(
    comparison = comparison,
    KEGGID = as.character(x[[id_column[1]]]),
    Description = as.character(x$Description),
    GeneRatio = parse_ratio(x$GeneRatio),
    padj = suppressWarnings(as.numeric(x$padj)),
    Count = suppressWarnings(as.numeric(x$Count)),
    Up = suppressWarnings(as.numeric(x$Up)),
    Down = suppressWarnings(as.numeric(x$Down)),
    stringsAsFactors = FALSE
  )
  result <- result[!is.na(result$KEGGID) & nzchar(result$KEGGID) &
                     !is.na(result$Description) & nzchar(result$Description), ]
  # Don't silently lose duplicated enrichment results
  if (anyDuplicated(result$KEGGID))
    stop("Duplicate KEGGID values in ", comparison, "; inspect spreadsheet.")
  result
}

data <- dplyr::bind_rows(lapply(names(input_files), function(nm) {
  read_kegg(input_files[[nm]], nm)
}))
if (nrow(data) == 0L) stop("No KEGG pathways found in selected files.")

# Keep the same KEGG pathways in the same order across comparisons.
# Shared pathways appear once as a row; absent pathways are blank.
terms <- data %>%
  group_by(KEGGID) %>%
  summarise(
    Description = first(Description),
    n_comparisons = n_distinct(comparison),
    best_padj = if (all(is.na(padj))) Inf else min(padj, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(n_comparisons), best_padj, Description) %>%
  mutate(Label = make.unique(Description, sep = " [duplicate]"))

# Avoid pathway IDs with different descriptions getting silently mislabeled
terms <- terms %>% mutate(Label = ifelse(duplicated(Description) |
   duplicated(Description, fromLast = TRUE),
   paste0(Description, " (", KEGGID, ")"), Description))

# An explicit factor provides a COMMON y-axis across all three facets.
levels_y <- rev(terms$Label)
plot_data <- data %>%
  left_join(terms %>% select(KEGGID, Label), by = "KEGGID") %>%
  mutate(
    comparison = factor(comparison, levels = names(input_files)),
    Pathway = factor(Label, levels = levels_y),
    Regulation = ifelse(Up + Down > 0, Up / (Up + Down), 0.5),
    Significant = !is.na(padj) & padj <= 0.05
  )

# Style: matching your volcano plot
UP_RED <- "#B12020"
DOWN_BLUE <- "#84A2CF"
GO_LABEL_PT <- 7.0
AXIS_LABEL_PT <- 7.0
PANEL_TITLE_PT <- 8.0
MAX_BUBBLE_MM <- 6.0

# Choose a common X limit so the 3 panels are comparable.
max_ratio <- max(plot_data$GeneRatio, na.rm = TRUE)
if (!is.finite(max_ratio)) stop("No valid GeneRatio values found.")
x_max <- max_ratio * 1.12

p <- ggplot(plot_data, aes(x = GeneRatio, y = Pathway, size = Count, fill = Regulation)) +
  # Thin gray circle: nonsignificant or adjusted p-value unavailable
  geom_point(data = subset(plot_data, !Significant),
             shape = 21, colour = "#777777", stroke = 0.35, alpha = 0.96,
             na.rm = TRUE) +
  # Thick black circle: FDR-adjusted p <= 0.05
  geom_point(data = subset(plot_data, Significant),
             shape = 21, colour = "black", stroke = 1.35, alpha = 0.96,
             na.rm = TRUE) +
  facet_wrap(~comparison, nrow = 1, scales = "fixed") +
  scale_size_area(max_size = MAX_BUBBLE_MM,
                  name = "Gene count", guide = guide_legend(order = 2)) +
  scale_fill_gradient2(low = DOWN_BLUE, mid = "#F7F7F7", high = UP_RED,
                       midpoint = 0.5, limits = c(0, 1),
                       breaks = c(0, 0.5, 1),
                       labels = c("Down", "Balanced", "Up"),
                       name = "Regulation (circle fill)",
                       guide = guide_colourbar(direction = "horizontal",
                          title.position = "top", label.position = "bottom",
                          barwidth = grid::unit(37, "mm"),
                          barheight = grid::unit(4, "mm"), order = 1)) +
  scale_x_continuous(breaks = scales::pretty_breaks(n = 4),
                     limits = c(0, x_max),
                     expand = expansion(mult = c(0.015, 0.02))) +
  labs(x = "GeneRatio", y = NULL,
       caption = paste0("Bold black outline: adjusted p <= 0.05; ",
                        "thin gray outline: adjusted p > 0.05 or unavailable. ",
                        "Blank panel rows: pathway absent from selected spreadsheet.")) +
  theme_minimal(base_family = "sans") +
  theme(
    panel.grid.major.y = element_line(colour = "#E7E7E7", linewidth = 0.23),
    panel.grid.major.x = element_line(colour = "#E7E7E7", linewidth = 0.23),
    panel.grid.minor = element_blank(),
    panel.border = element_rect(fill = NA, colour = "#616D79", linewidth = 0.4),
    axis.text.y = element_text(size = GO_LABEL_PT, colour = "#17263B"),
    axis.text.x = element_text(size = AXIS_LABEL_PT, colour = "#17263B"),
    axis.title.x = element_text(size = 8, colour = "#163B63", face = "bold"),
    strip.text.x = element_text(size = PANEL_TITLE_PT, colour = "#163B63", face = "bold"),
    strip.background = element_rect(fill = "#EAF1F8", colour = "#B8C8D8"),
    legend.position = "bottom", legend.box = "horizontal",
    legend.direction = "horizontal",
    legend.title = element_text(size = 7.5, face = "bold"),
    legend.text = element_text(size = 7),
    plot.caption = element_text(size = 6.2, hjust = 0, colour = "#4B5563"),
    plot.margin = margin(8, 10, 8, 8, "pt")
  )

# Increasing height as needed makes the labels more readable, but
# may exceed Nature's maximum main-figure height with many KEGG terms.
HEIGHT_IN <- max(6.2, nrow(terms) * 0.22 + 2.2)
WIDTH_IN <- 12.8
output <- file.path(getwd(), "Figure_S1_KEGG_Combined_Bubble_Plot")

ggsave(paste0(output, ".pdf"), p, width = WIDTH_IN, height = HEIGHT_IN,
       units = "in", device = grDevices::cairo_pdf, bg = "white")
ggsave(paste0(output, ".svg"), p, width = WIDTH_IN, height = HEIGHT_IN,
       units = "in", device = svglite::svglite, bg = "white")
ggsave(paste0(output, ".png"), p, width = WIDTH_IN, height = HEIGHT_IN,
       units = "in", dpi = 600, device = ragg::agg_png, bg = "white")

print(p)
message("Exported files at: ", output, ".{pdf,svg,png}")
message("Unique KEGG pathways: ", nrow(terms))
message("Reported comparison/pathway entries: ", nrow(plot_data))
