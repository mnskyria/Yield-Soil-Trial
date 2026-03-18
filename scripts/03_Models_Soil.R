# ============================================================
#03_Models_Soil.R
# ============================================================

`%||%` <- function(a, b) if (is.null(a)) b else a

# ---------- 1. WORKBOOK HELPERS -----------------------------------------
sanitize_sheet <- function(x) {
  x <- gsub("[:\\\\/\\?\\*\\[\\]]", "_", x)
  substr(x, 1, 31)
}

wb_add_tbl <- function(wb, sheet, tbl) {
  sn <- sanitize_sheet(sheet)
  if (sn %in% sheets(wb)) removeWorksheet(wb, sn)
  addWorksheet(wb, sn)
  writeData(wb, sn, tbl)
  
  num_cols <- which(vapply(tbl, is.numeric, TRUE))
  if (length(num_cols)) {
    addStyle(
      wb, sn, createStyle(numFmt = "0.000"),
      rows = 2:(nrow(tbl) + 1),
      cols = num_cols,
      gridExpand = TRUE
    )
  }
  setColWidths(wb, sn, cols = 1:ncol(tbl), widths = "auto")
}

# ---------- 2. MAIN RUNNER ----------------------------------------
run_soil_lm_treatment_year_to_excel <- function(
    soil_vars,
    data,
    outfile,
    year_levels = c("T0", "2024"),
    emm_adjust  = "tukey"
) {
  
  dir.create(dirname(outfile), recursive = TRUE, showWarnings = FALSE)
  wb <- createWorkbook()
  
  model_summary <- list()
  coef_tbl      <- list()
  contrast_tbl  <- list()
  pairs_tbl     <- list()
  
  run_log <- tibble(
    var = character(),
    n_used = integer(),
    ok = logical(),
    notes = character()
  )
  
  for (v in soil_vars) {
    
    needed <- c(v, "treatment", "year")
    if (!all(needed %in% names(data))) {
      run_log <- add_row(
        run_log, var = v, n_used = 0L, ok = FALSE,
        notes = "missing required columns"
      )
      next
    }
    
    dat <- data |>
      select(all_of(needed)) |>
      drop_na()
    
    if (nrow(dat) < 5) {
      run_log <- add_row(
        run_log, var = v, n_used = nrow(dat), ok = FALSE,
        notes = "too few observations"
      )
      next
    }
    
    dat$year <- factor(as.character(dat$year), levels = year_levels)
    if (sum(!is.na(dat$year)) < 2) {
      run_log <- add_row(
        run_log, var = v, n_used = nrow(dat), ok = FALSE,
        notes = "required year levels missing"
      )
      next
    }
    
    fml <- as.formula(paste(v, "~ treatment * year"))
    
    mod <- try(lm(fml, data = dat), silent = TRUE)
    if (inherits(mod, "try-error")) {
      run_log <- add_row(
        run_log, var = v, n_used = 0L, ok = FALSE,
        notes = as.character(mod)
      )
      next
    }
    
    n_used <- nobs(mod)
    sm <- summary(mod)
    
    # ---- Model summary
    model_summary[[v]] <- tibble(
      indicator = v,
      n_used = n_used,
      r2 = sm$r.squared,
      adj_r2 = sm$adj.r.squared,
      f_stat = unname(sm$fstatistic[1]),
      df1 = unname(sm$fstatistic[2]),
      df2 = unname(sm$fstatistic[3]),
      p_value = pf(
        sm$fstatistic[1],
        sm$fstatistic[2],
        sm$fstatistic[3],
        lower.tail = FALSE
      )
    )
    
    # ---- Coefficients
    coef_tbl[[v]] <-
      broom::tidy(mod) |>
      mutate(indicator = v, n_used = n_used, .before = 1)
    
    # ---- emmeans-derived outputs
    emm <- try(emmeans(mod, ~ treatment * year), silent = TRUE)
    
    if (!inherits(emm, "try-error")) {
      
      # (2024 − T0) within treatment
      contrast_tbl[[v]] <-
        contrast(
          emm,
          method = "pairwise",
          by = "treatment",
          levels = list(year = year_levels),
          adjust = emm_adjust
        ) |>
        as_tibble() |>
        mutate(indicator = v, .before = 1)
      
      # Treatment pairwise within year
      pairs_tbl[[v]] <-
        pairs(
          emmeans(mod, ~ treatment | year),
          adjust = emm_adjust
        ) |>
        as_tibble() |>
        mutate(indicator = v, .before = 1)
      
      run_log <- add_row(
        run_log, var = v, n_used = n_used, ok = TRUE, notes = ""
      )
      
    } else {
      run_log <- add_row(
        run_log, var = v, n_used = n_used, ok = FALSE,
        notes = "emmeans failed"
      )
    }
  }
  
  # ---- Write workbook
  wb_add_tbl(wb, "Model_Summary", bind_rows(model_summary))
  wb_add_tbl(wb, "Coefficients", bind_rows(coef_tbl))
  wb_add_tbl(wb, "Contrast_2024_minus_T0", bind_rows(contrast_tbl))
  wb_add_tbl(wb, "Pairs_trt_within_year", bind_rows(pairs_tbl))
  wb_add_tbl(wb, "Run_Log", run_log)
  
  saveWorkbook(wb, outfile, overwrite = TRUE)
  message("✓ Wrote soil LM summary: ", normalizePath(outfile, winslash = "/"))
  
  invisible(list(
    model_summary = bind_rows(model_summary),
    coefficients  = bind_rows(coef_tbl),
    contrasts     = bind_rows(contrast_tbl),
    pairs         = bind_rows(pairs_tbl),
    log           = run_log,
    path          = outfile
  ))
}

# ---------- 3. RUN AND EXPORT ----------------------------------------------
out <- run_soil_lm_treatment_year_to_excel(
  soil_vars  = soil_vars,
  data       = dat_2024_T0,
  outfile    = file.path(CONFIG$model_dir, "Soil_LM_Treatment_Year_Balanced.xlsx"),
  emm_adjust = "tukey"
)

out_raw <- run_soil_lm_treatment_year_to_excel(
  soil_vars  = soil_vars,
  data       = dat_RAW,
  outfile    = file.path(CONFIG$model_dir, "Soil_LM_Treatment_Year_Full.xlsx"),
  emm_adjust = "tukey"
)
