# ============================================================
# 05_Models_Balanced-Verification.R
# ============================================================

# ----------------- 1. CONFIRM DATASETS -----------------
stopifnot("dat_2024_T0" %in% ls())
stopifnot("dat_RAW" %in% ls())

message("Balanced dataset rows: ", nrow(dat_2024_T0))
message("Raw dataset rows:      ", nrow(dat_RAW))

# ----------------- 2. REUSABLE MODEL RUNNER -----------------
run_contrast_models <- function(data, soil_vars,
                                year_levels = c("T0", "2024")) {
  map_dfr(soil_vars, function(v) {
    
    dat <- data %>%
      select(all_of(c(v, "treatment", "year"))) %>%
      drop_na() %>%
      mutate(
        year      = factor(as.character(year), levels = year_levels),
        treatment = factor(as.character(treatment))
      )
    
    if (nrow(dat) < 5 || length(unique(dat$year)) < 2) {
      message("Skipping ", v, " - insufficient data")
      return(NULL)
    }
    
    mod <- lm(as.formula(paste(v, "~ treatment * year")), data = dat)
    emm <- emmeans(mod, ~ treatment * year)
    
    cont <- contrast(emm,
                     method = "pairwise",
                     by     = "treatment",
                     adjust = "tukey") %>%
      as_tibble() %>%
      filter(grepl("T0", contrast)) %>%
      mutate(
        indicator = v,
        n_used    = nobs(mod),
        df_resid  = mod$df.residual,
        r2        = summary(mod)$r.squared,
        .before   = 1
      )
    
    return(cont)
  })
}

# ----------------- 3. RUN BOTH MODELS -----------------
message("\nFitting balanced models (n = 40)...")
results_balanced <- run_contrast_models(dat_2024_T0, soil_vars) %>%
  mutate(approach = "balanced")

message("Fitting raw models...")
results_raw <- run_contrast_models(dat_RAW, soil_vars) %>%
  mutate(approach = "raw")

# ----------------- 4. RANDOM SUBSAMPLE ITERATIONS -----------------
message("Running 500 random subsample iterations...")

run_subsample_iterations <- function(soil_vars,
                                     n_iter = 500,
                                     seed   = 42) {
  set.seed(seed)
  
  dat_T0_fixed  <- dat_RAW %>% filter(year == "T0")
  dat_2024_full <- dat_RAW %>% filter(year == "2024")
  
  map_dfr(1:n_iter, function(i) {
    
    subsample_2024 <- dat_2024_full %>%
      group_by(treatment, trt_rep) %>%
      slice_sample(n = 1) %>%
      ungroup()
    
    dat_iter <- bind_rows(dat_T0_fixed, subsample_2024) %>%
      mutate(year = factor(as.character(year), levels = c("T0", "2024")))
    
    run_contrast_models(dat_iter, soil_vars) %>%
      mutate(iteration = i)
  })
}

results_subsample <- run_subsample_iterations(soil_vars, n_iter = 500)

# ----------------- 5. SUMMARISE SUBSAMPLE STABILITY -----------------
subsample_summary <- results_subsample %>%
  group_by(indicator, treatment, contrast) %>%
  summarise(
    mean_estimate = mean(estimate),
    sd_estimate   = sd(estimate),
    mean_p        = mean(p.value),
    prop_sig      = mean(p.value < 0.05),
    .groups       = "drop"
  )

# ----------------- 6. COMPARE AND FLAG DIFFERENCES -----------------
comparison <- results_balanced %>%
  select(indicator, treatment, estimate, p.value, df_resid, r2) %>%
  left_join(
    results_raw %>% select(indicator, treatment, estimate, p.value, df_resid, r2),
    by     = c("indicator", "treatment"),
    suffix = c("_bal", "_raw")
  ) %>%
  left_join(
    subsample_summary %>%
      select(indicator, treatment,
             mean_estimate, sd_estimate, mean_p, prop_sig),
    by = c("indicator", "treatment")
  ) %>%
  mutate(
    sig_bal          = p.value_bal < 0.05,
    sig_raw          = p.value_raw < 0.05,
    sig_changed      = sig_bal != sig_raw,
    estimate_diff    = round(estimate_raw - estimate_bal, 4),
    subsample_stable = prop_sig > 0.8 | prop_sig < 0.2,
    note = case_when(
      sig_changed &  sig_bal  ~ "Lost significance in raw (power reduction)",
      sig_changed & !sig_bal  ~ "Gained significance in raw",
      !subsample_stable        ~ "Subsample unstable (borderline)",
      TRUE                     ~ "Consistent across approaches"
    )
  )

# ----------------- 7. PRINT SUMMARY TO CONSOLE -----------------
message("\n=== VALIDATION SUMMARY ===")
message("Significance flips (balanced vs raw): ", sum(comparison$sig_changed))
message("Subsample-unstable contrasts:         ", sum(!comparison$subsample_stable))
message("\nFlipped contrasts:")
comparison %>%
  filter(sig_changed) %>%
  select(indicator, treatment, estimate_bal, p.value_bal,
         p.value_raw, prop_sig, note) %>%
  print(n = Inf)

# ----------------- 8. EXPORT TO EXCEL -----------------
wb <- createWorkbook()
wb_add_tbl(wb, "Full_Comparison",    comparison)
wb_add_tbl(wb, "Sig_Flips",          filter(comparison, sig_changed))
wb_add_tbl(wb, "Subsample_Unstable", filter(comparison, !subsample_stable))
wb_add_tbl(wb, "Subsample_Summary",  subsample_summary)

saveWorkbook(
  wb,
  file.path(CONFIG$model_dir, "Validation_Balanced_vs_Raw.xlsx"),
  overwrite = TRUE
)

message("\n✓ Validation complete. Written to: ",
        file.path(CONFIG$model_dir, "Validation_Balanced_vs_Raw.xlsx"))
