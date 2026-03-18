# ============================================================
# 09_Figure_Model-Outputs-Balanced-vs-Raw.R
# ============================================================

# ----------------- 1. INDICATOR SETS AND LABELS -----------------
SOIL_INDICATORS <- c(
  "pH", "EC", "totalN", "NH4", "P",
  "K", "Ca", "Mg", "Cu", "Mn", "Zn",
  "SOC", "BD", "POXC"
)

YLABS <- c(
  pH         = "Soil pH",
  EC         = "Electrical Conductivity (dS/m)",
  totalN     = "Total N (%)",
  NH4        = "NH₄⁺ Mineralization (ppm)",
  P          = "MIII P (ppm)",
  K          = "MIII K (ppm)",
  Ca         = "MIII Ca (ppm)",
  Mg         = "MIII Mg (ppm)",
  Cu         = "MIII Cu (ppm)",
  Mn         = "MIII Mn (ppm)",
  Zn         = "MIII Zn (ppm)",
  SOC        = "SOC (%)",
  BD         = "Bulk Density (g/cm³)",
  POXC       = "POX-C (mg/kg)"
)

# ----------------- 2. PANEL HELPER -----------------
make_comparison_panel <- function(
    data,
    response_var,
    y_label,
    panel_title,
    point_alpha = 0.35,
    point_size  = 2,
    dodge_width = 0.4,
    y_limits    = NULL,
    y_breaks    = waiver()
) {
  
  year_levels <- c("T0", "2024")
  year_labels <- c("T0", "Year 3")
  
  # Prepare data
  data <- data %>%
    mutate(
      treatment = factor(as.character(treatment),
                         levels = as.character(1:5)),
      year      = factor(as.character(year),
                         levels = year_levels)
    )
  
  # Fit model
  fml <- as.formula(paste0(response_var, " ~ treatment * year"))
  mod <- lm(fml, data = data, na.action = na.omit)
  
  # Prediction grid
  newdat <- expand_grid(
    treatment = factor(as.character(1:5), levels = as.character(1:5)),
    year      = factor(year_levels, levels = year_levels)
  )
  
  p <- predict(mod, newdata = newdat, se.fit = TRUE)
  
  preds <- newdat %>%
    mutate(
      fit   = p$fit,
      se    = p$se.fit,
      lower = fit - 1.96 * se,
      upper = fit + 1.96 * se,
      year  = factor(year, levels = year_levels, labels = year_labels)
    )
  
  # Raw data
  raw <- data %>%
    select(treatment, year, all_of(response_var)) %>%
    rename(y = all_of(response_var)) %>%
    mutate(
      year = factor(year, levels = year_levels, labels = year_labels)
    ) %>%
    drop_na(y)
  
  # Dummy facet variable for grey header
  raw$panel   <- panel_title
  preds$panel <- panel_title
  
  # Build plot
  g <- ggplot() +
    geom_point(
      data = raw,
      aes(x = treatment, y = y, fill = year),
      shape    = 21,
      colour   = "grey40",
      alpha    = point_alpha,
      size     = point_size,
      position = position_jitterdodge(
        jitter.width = 0.08,
        dodge.width  = dodge_width
      )
    ) +
    geom_errorbar(
      data = preds,
      aes(x = treatment, ymin = lower, ymax = upper, group = year),
      width    = 0.12,
      size     = 0.7,
      position = position_dodge(width = dodge_width)
    ) +
    geom_point(
      data = preds,
      aes(x = treatment, y = fit, fill = year),
      shape    = 21,
      colour   = "black",
      size     = 3,
      stroke   = 0.7,
      position = position_dodge(width = dodge_width)
    ) +
    scale_fill_manual(
      name   = "Year",
      values = c("T0" = "grey60", "Year 3" = "black")
    ) +
    scale_x_discrete(
      labels = c("1" = "1", "2" = "2", "3" = "3",
                 "4" = "4", "5" = "5")
    ) +
    facet_wrap(~ panel) +
    labs(
      x = "Treatment",
      y = y_label
    ) +
    theme_bw(base_size = 16) +
    theme(
      strip.background   = element_rect(fill = "grey85", colour = "grey50"),
      strip.text         = element_text(face = "bold", size = 16),
      axis.text.x        = element_text(size = 16, colour = "black"),
      axis.text.y        = element_text(size = 16),
      axis.title.x       = element_text(size = 16),
      axis.title.y       = element_text(size = 16),
      panel.grid.minor   = element_blank(),
      panel.grid.major.x = element_blank(),
      legend.position    = "right",
      legend.title       = element_text(size = 16),
      legend.text        = element_text(size = 16)
    )
  
  # Apply shared y-axis limits and breaks if provided
  if (!is.null(y_limits)) {
    g <- g +
      scale_y_continuous(
        limits = y_limits,
        breaks = y_breaks,
        expand = expansion(mult = c(0.02, 0.02))
      )
  }
  
  return(g)
}

# ----------------- 3. MAIN COMPARISON FUNCTION -----------------
plot_balanced_vs_raw <- function(
    response_var,
    data_balanced = dat_2024_T0,
    data_raw      = dat_RAW,
    y_label       = NULL,
    point_alpha   = 0.35,
    point_size    = 2,
    width         = 14,
    height        = 6.5,
    out_dir       = file.path(CONFIG$outputs_dir, "Balanced Model Verification"),
    save          = TRUE
) {
  
  # Y label lookup
  if (is.null(y_label)) {
    if (exists("YLABS") && response_var %in% names(YLABS)) {
      y_label <- YLABS[[response_var]]
    } else {
      y_label <- response_var
    }
  }
  

  # SHARED Y-AXIS LIMITS ACROSS BOTH DATASETS

  all_vals <- c(
    data_balanced[[response_var]],
    data_raw[[response_var]]
  )
  all_vals <- all_vals[!is.na(all_vals)]
  
  y_min    <- floor(min(all_vals) * 0.97)
  y_max    <- ceiling(max(all_vals) * 1.03)
  y_breaks <- pretty(c(y_min, y_max), n = 6)
  
  # BUILD PANELS

  p_balanced <- make_comparison_panel(
    data         = data_balanced,
    response_var = response_var,
    y_label      = y_label,
    panel_title  = "Balanced (replicate-averaged; n = 40)",
    point_alpha  = point_alpha,
    point_size   = point_size,
    y_limits     = c(y_min, y_max),
    y_breaks     = y_breaks
  )
  
  p_raw <- make_comparison_panel(
    data         = data_raw,
    response_var = response_var,
    y_label      = NULL,        # no label on right panel
    panel_title  = "Raw (unaveraged; n = 80)",
    point_alpha  = point_alpha,
    point_size   = point_size,
    y_limits     = c(y_min, y_max),
    y_breaks     = y_breaks
  ) +
    theme(
      axis.title.y = element_blank(),
      axis.text.y  = element_text(size = 14)
    )
  
  # COMBINE
  
  combined <- (p_balanced | p_raw) +
    plot_layout(guides = "collect") &
    theme(legend.position = "right")
  
  # SAVE
  
  if (save) {
    if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
    
    outfile <- file.path(
      out_dir,
      paste0(response_var, "_balanced_vs_raw.png")
    )
    
    ggsave(
      filename = outfile,
      plot     = combined,
      width    = width,
      height   = height,
      dpi      = 300,
      units    = "in"
    )
    
    message("✓ Saved: ", basename(outfile))
  }
  
  return(invisible(combined))
}

# ----------------- 4. BATCH RUNNER -----------------

run_all_comparison_plots <- function(
    indicators    = SOIL_INDICATORS,
    data_balanced = dat_2024_T0,
    data_raw      = dat_RAW,
    out_dir       = file.path(CONFIG$figs_dir, "Balanced Model Verification")
) {
  
  message("\nGenerating balanced vs raw comparison plots...")
  message("Indicators: ", paste(indicators, collapse = ", "))
  message("Output directory: ", out_dir, "\n")
  
  results <- map(indicators, function(v) {
    message("Processing: ", v)
    tryCatch(
      plot_balanced_vs_raw(
        response_var  = v,
        data_balanced = data_balanced,
        data_raw      = data_raw,
        out_dir       = out_dir
      ),
      error = function(e) {
        message("  ✗ Error for ", v, ": ", e$message)
        NULL
      }
    )
  })
  
  n_success <- sum(!map_lgl(results, is.null))
  message("\n✓ Complete: ", n_success, "/", length(indicators),
          " plots saved to ", out_dir)
  
  invisible(results)
}

# ----------------- 5. RUN -----------------
run_all_comparison_plots()
