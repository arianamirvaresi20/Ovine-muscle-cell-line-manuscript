############################################################
## FIGURE 8: Cell viability on pea scaffold
## Boxplots with all individual raw data points overlaid
##
## Expected Excel worksheet format:
##
## - The first row contains column labels.
## - Rows below contain replicate-level numeric data.
## - The first 12 non-empty measurement columns are ordered:
##
## Column 1:  4h PLM
## Column 2:  4h EPILM
## Column 3:  4h LPILM
## Column 4:  24h PLM
## Column 5:  24h EPILM
## Column 6:  24h LPILM
## Column 7:  48h PLM
## Column 8:  48h EPILM
## Column 9:  48h LPILM
## Column 10: 72h PLM
## Column 11: 72h EPILM
## Column 12: 72h LPILM
##
## The script DOES NOT display n = 3 labels in the figure.
############################################################


############################################################
## 0. Install packages ONCE
## Comment these lines out after installation succeeds.
############################################################

if (!requireNamespace("readxl", quietly = TRUE)) {
  install.packages("readxl")
}

if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}

if (!requireNamespace("tidyr", quietly = TRUE)) {
  install.packages("tidyr")
}

if (!requireNamespace("broom", quietly = TRUE)) {
  install.packages("broom")
}

if (!requireNamespace("ggplot2", quietly = TRUE)) {
  install.packages("ggplot2")
}

if (!requireNamespace("multcompView", quietly = TRUE)) {
  install.packages("multcompView")
}


############################################################
## 1. Load libraries
############################################################

library(readxl)
library(dplyr)
library(tidyr)
library(broom)
library(ggplot2)
library(multcompView)


############################################################
## 2. Import the Excel worksheet
##
## col_names = FALSE reads the first worksheet row as data.
## That row will be assigned as column names below.
############################################################

cat("Please select your Excel file...\n")

data_raw <- read_excel(
  file.choose(),
  col_names = FALSE,
  .name_repair = "minimal"
)


############################################################
## 3. Clean completely empty columns and Excel header names
##
## This prevents:
## "Can't transform a data frame with `NA` or `\"\"` names."
############################################################

## Remove Excel columns that contain no non-missing cells.
data_raw <- data_raw[
  ,
  colSums(!is.na(data_raw)) > 0,
  drop = FALSE
]

## Stop if no header row plus data rows are available.
if (nrow(data_raw) < 2) {
  stop(
    "The selected worksheet needs at least two rows: ",
    "one header row and at least one data row."
  )
}

## Read the first row as the intended Excel column-name row.
new_names <- as.character(unlist(data_raw[1, ]))

## Identify missing, blank, or whitespace-only header names.
bad_name_index <- is.na(new_names) | trimws(new_names) == ""

## Give blank names safe temporary labels.
new_names[bad_name_index] <- paste0(
  "Unnamed_",
  which(bad_name_index)
)

## Ensure all internal R column names are unique.
new_names <- make.unique(new_names)

## Remove the first/header row, then assign cleaned names.
data <- data_raw[-1, , drop = FALSE]
names(data) <- new_names

## Remove columns that contain a header but no numeric/data value.
data <- data[
  ,
  colSums(!is.na(data)) > 0,
  drop = FALSE
]

cat("\nDetected non-empty columns:\n")
print(names(data))


############################################################
## 4. Select the 12 Figure 8 measurement columns
##
## If an ID, sample-name, or notes column appears before your
## 12 measurement columns, remove it in Excel OR change
## 1:12 below to the positions of the correct 12 columns.
############################################################

if (ncol(data) < 12) {
  stop(
    "\nFewer than 12 non-empty measurement columns were found.\n",
    "The Figure 8 script requires 12 columns:\n",
    "4 time points × 3 cell lines.\n",
    "Check the selected worksheet and column arrangement."
  )
}

if (ncol(data) > 12) {
  warning(
    "\nMore than 12 non-empty columns were found.\n",
    "The script will analyze only the first 12 non-empty columns.\n",
    "Confirm that those 12 are your Figure 8 measurement columns."
  )
}

data <- data[, 1:12, drop = FALSE]

cat("\nColumns used for Figure 8:\n")
print(names(data))


############################################################
## 5. Map each of the 12 measurement columns to its group
##
## Change this section only if your Excel measurement columns
## are not in the specified order.
############################################################

col_map <- tibble(
  colname = names(data),
  time = rep(
    c("4h", "24h", "48h", "72h"),
    each = 3
  ),
  cell = rep(
    c("PLM", "EPILM", "LPILM"),
    times = 4
  )
)

cat("\nColumn mapping:\n")
print(col_map)


############################################################
## 6. Convert data from wide to long/tidy format
##
## Each row in data_long is one raw replicate-level observation.
############################################################

data_long <- data %>%
  mutate(
    row_id = row_number()
  ) %>%
  pivot_longer(
    cols = -row_id,
    names_to = "colname",
    values_to = "value"
  ) %>%
  left_join(
    col_map,
    by = "colname"
  ) %>%
  mutate(
    value = suppressWarnings(as.numeric(value)),
    time = factor(
      time,
      levels = c("4h", "24h", "48h", "72h")
    ),
    cell = factor(
      cell,
      levels = c("PLM", "EPILM", "LPILM")
    )
  ) %>%
  select(
    time,
    cell,
    row_id,
    value
  ) %>%
  filter(
    !is.na(value)
  )

if (nrow(data_long) == 0) {
  stop(
    "\nNo numeric observations were found.\n",
    "Check that the selected worksheet contains numeric values ",
    "and that your measurement columns are in the first 12 positions."
  )
}

cat("\nFirst rows of tidy data:\n")
print(head(data_long))


############################################################
## 7. Check sample sizes
##
## These values are printed in the Console only.
## They are NOT added to the plot.
############################################################

sample_sizes <- data_long %>%
  group_by(time, cell) %>%
  summarise(
    n = n(),
    .groups = "drop"
  )

cat("\nSample sizes by time and cell line:\n")
print(sample_sizes)


############################################################
## 8. One-way ANOVA for each time point
##
## Compares PLM, EPILM, and LPILM at each time point.
############################################################

anova_results <- data_long %>%
  group_by(time) %>%
  group_modify(~ {
    fit <- aov(value ~ cell, data = .x)
    tidy(fit)
  }) %>%
  ungroup()

cat("\nANOVA results:\n")
print(anova_results)


############################################################
## 9. Tukey HSD post-hoc comparisons for each time point
############################################################

tukey_results <- data_long %>%
  group_by(time) %>%
  group_modify(~ {
    fit <- aov(value ~ cell, data = .x)
    
    tk <- TukeyHSD(
      fit,
      which = "cell"
    )
    
    tk_df <- as.data.frame(tk$cell)
    
    tk_df$comparison <- rownames(tk_df)
    
    rownames(tk_df) <- NULL
    
    as_tibble(tk_df)
  }) %>%
  ungroup()

cat("\nTukey HSD results:\n")
print(tukey_results)


############################################################
## 10. Create Tukey compact-letter display
##
## Groups sharing a letter are not significantly different.
## Different letters indicate adjusted P < 0.05.
############################################################

letters_df <- tukey_results %>%
  group_by(time) %>%
  group_modify(~ {
    pvals <- .x$`p adj`
    
    names(pvals) <- .x$comparison
    
    tukey_letters <- multcompLetters(pvals)$Letters
    
    tibble(
      cell = names(tukey_letters),
      letters = unname(tukey_letters)
    )
  }) %>%
  ungroup() %>%
  mutate(
    time = factor(
      time,
      levels = c("4h", "24h", "48h", "72h")
    ),
    cell = factor(
      cell,
      levels = c("PLM", "EPILM", "LPILM")
    )
  )

cat("\nTukey letter labels:\n")
print(letters_df)


############################################################
## 11. Calculate values used for Tukey-letter placement
##
## Raw data points—not these summaries—are used to draw
## the boxes and individual points.
############################################################

plot_data <- data_long %>%
  group_by(time, cell) %>%
  summarise(
    maximum = max(value, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  left_join(
    letters_df,
    by = c("time", "cell")
  )


############################################################
## 12. Set colors
############################################################

cols <- c(
  "PLM" = "#9FD7F2",
  "EPILM" = "#5BA9E1",
  "LPILM" = "#255E87"
)


############################################################
## 13. Set y-axis and letter-label positions
##
## Increase y_upper if letters overlap with the raw points.
############################################################

y_lower <- 0
y_upper <- 65000

annotation_data <- plot_data %>%
  group_by(time) %>%
  mutate(
    letter_y = pmin(
      maximum + 0.06 * y_upper,
      y_upper - 1500
    )
  ) %>%
  ungroup()


############################################################
## 14. Create Figure 8 boxplot with raw data overlay
##
## Boxplot definitions for the figure legend:
## - Box lower/upper limits: Q1 and Q3
## - Horizontal center line: median
## - Whiskers: most extreme observations within 1.5 × IQR
## - Jittered dots: individual raw observations
##
## outlier.shape = NA avoids displaying outliers twice because
## geom_jitter() already shows every original observation.
############################################################

fig8_plot <- ggplot(
  data_long,
  aes(
    x = cell,
    y = value,
    fill = cell
  )
) +
  geom_boxplot(
    width = 0.62,
    colour = "black",
    linewidth = 0.65,
    alpha = 0.85,
    outlier.shape = NA
  ) +
  geom_jitter(
    aes(colour = cell),
    width = 0.12,
    height = 0,
    size = 2.8,
    alpha = 0.85,
    show.legend = FALSE
  ) +
  geom_text(
    data = annotation_data,
    aes(
      x = cell,
      y = letter_y,
      label = letters
    ),
    inherit.aes = FALSE,
    vjust = 0,
    size = 5,
    fontface = "bold"
  ) +
  scale_fill_manual(
    values = cols,
    name = "Cell line"
  ) +
  scale_colour_manual(
    values = cols
  ) +
  facet_wrap(
    ~ time,
    nrow = 1
  ) +
  labs(
    x = "Cells on soy scaffold",
    y = "Cell viability"
  ) +
  coord_cartesian(
    ylim = c(y_lower, y_upper),
    clip = "off"
  ) +
  theme_bw() +
  theme(
    text = element_text(
      size = 14,
      face = "bold"
    ),
    axis.title = element_text(
      face = "bold"
    ),
    axis.text = element_text(
      face = "bold"
    ),
    strip.text = element_text(
      face = "bold"
    ),
    legend.title = element_text(
      face = "bold"
    ),
    legend.text = element_text(
      face = "bold"
    ),
    panel.grid.major = element_line(
      colour = "grey90",
      linewidth = 0.4
    ),
    panel.grid.minor = element_blank(),
    plot.margin = margin(
      t = 12,
      r = 12,
      b = 12,
      l = 12
    )
  )

print(fig8_plot)


############################################################
## 15. Optional: Export at publication resolution
##
## Remove the # symbols when ready to save.
############################################################

# ggsave(
#   filename = "Figure_8_boxplot_raw_points.png",
#   plot = fig8_plot,
#   width = 14,
#   height = 6,
#   units = "in",
#   dpi = 600,
#   bg = "white"
# )
#
# ggsave(
#   filename = "Figure_8_boxplot_raw_points.pdf",
#   plot = fig8_plot,
#   width = 14,
#   height = 6,
#   units = "in",
#   bg = "white"
# )