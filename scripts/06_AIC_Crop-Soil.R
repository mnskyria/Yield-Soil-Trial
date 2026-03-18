# ============================================================
# 06_AIC_Crop-Soil.R 
# ============================================================

options(na.action = "na.fail")  # required for AICc in MuMIn

# ----------------- 1. INDICATOR + CROP DEFINITIONS -----------------
INDICATORS <- c(
  "pH", "EC", "totalN", "NH4", "P", "K", "Ca", "Mg",
  "Cu", "Mn", "Zn",
  "SOC", "SLAKES", "BD", "POXC"
)

# ----------------- 2. YEARLY TREATMENT-REP MEANS -----------------
# Bean and carrot: all three years
dat_yearly_means <- dat %>%
  filter(year %in% c("2022", "2023", "2024")) %>%
  group_by(year, treatment, trt_rep) %>%
  summarise(
    across(all_of(INDICATORS), mean, na.rm = TRUE),
    across(c("carrot1", "bean", "kale"), mean, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(year = factor(year, levels = c("2022", "2023", "2024")))

# Kale: Years 2-3 only (Year 1 excluded due to establishment failure)
# dat_kale is defined in utils.R

# ----------------- 3. FIT MODELS + EXTRACT METRICS -----------------
fit_lm_aic_full <- function(data, indicators, crops) {
  
  map_dfr(crops, function(crop) {
    map_dfr(indicators, function(ind) {
      
      # Drop unused factor levels after na.omit
      model_data <- data %>%
        select(all_of(c(crop, ind, "year", "treatment"))) %>%
        drop_na() %>%
        droplevels()   # << key fix
      
      # Skip if fewer than 2 year levels remain
      if (length(levels(model_data$year)) < 2) {
        message("Skipping ", crop, " ~ ", ind, ": fewer than 2 year levels after NA removal")
        return(NULL)
      }
      
      model <- lm(
        as.formula(paste0(crop, " ~ ", ind, " + year")),
        data = model_data,
        na.action = na.omit
      )
      
      tibble(
        crop      = crop,
        indicator = ind,
        Resid_dev = deviance(model),
        Resid_df  = model$df.residual,
        AIC       = AIC(model),
        AICc      = MuMIn::AICc(model),
        logLik    = as.numeric(logLik(model)),
        R2        = summary(model)$r.squared
      )
    })
  })
}

# ----------------- 4. RUN ALL MODELS -----------------
# Bean and carrot: full three-year dataset
aic_bean_carrot <- fit_lm_aic_full(
  data       = dat_yearly_means,
  indicators = INDICATORS,
  crops      = c("carrot1", "bean")
)

# Kale: Years 2-3 only
aic_kale <- fit_lm_aic_full(
  data       = dat_kale,
  indicators = INDICATORS,
  crops      = "kale"
)

# Combine
aic_full <- bind_rows(aic_bean_carrot, aic_kale)

# ----------------- 5. RANK RESULTS WITHIN CROP -----------------
aic_ranked <- aic_full %>%
  group_by(crop) %>%
  mutate(
    rank      = rank(AICc, ties.method = "first"),
    deltaAICc = AICc - min(AICc),
    weight    = exp(-0.5 * deltaAICc) / sum(exp(-0.5 * deltaAICc))
  ) %>%
  arrange(crop, AICc) %>%
  ungroup() %>%
  select(
    crop, indicator, rank,
    Resid_dev, Resid_df,
    AIC, AICc, deltaAICc, weight,
    R2, logLik
  )

# ----------------- 6.CANDIDATE MODELS (ΔAIC < 2) -----------------
aic_candidates <- aic_ranked %>%
  filter(deltaAICc < 2)

# ----------------- 7. EXPORT -----------------
dir.create(CONFIG$aic_dir, recursive = TRUE, showWarnings = FALSE)

write.csv(
  aic_ranked,
  file.path(CONFIG$aic_dir, "AIC_full_crop_soil_models.csv"),
  row.names = FALSE
)

write.csv(
  aic_candidates,
  file.path(CONFIG$aic_dir, "AIC_candidate_models.csv"),
  row.names = FALSE
)

# ----------------- 8. PRINT SUMMARY -----------------
message("\n=== FULL MODEL SET ===")
print(aic_ranked)

message("\n=== CANDIDATE MODELS (ΔAICc < 2) ===")
print(aic_candidates)

# ----------------- 9. CANDIDATE MODEL FITTING + DIAGNOSTICS -----------------
# --- Bean: NH4 ---
beanNH4mod <- lm(bean ~ NH4 + year, data = dat_yearly_means, na.action = na.omit)
summary(beanNH4mod)
check_diagnostics(beanNH4mod, data = dat_yearly_means)

beanNH4plot <- plot_pred_with_raw_indicator(
  beanNH4mod,
  dat_yearly_means,
  response_var  = "bean",
  indicator_var = "NH4",
  x_label       = "NH₄⁺ Mineralization (ppm)",
  y_label       = "Bean Yield (g)"
)

beanNH4plot
ggsave(
  "beanNH4mod.jpg",
  plot   = beanNH4plot,
  path   = CONFIG$outputs_dir,
  width  = 7,
  height = 4,
  units  = "in",
  dpi    = 300
)

# --- Carrot: Mg ---
carrotMgmod <- lm(carrot1 ~ Mg + year, data = dat_yearly_means, na.action = na.omit)
summary(carrotMgmod)
check_diagnostics(carrotMgmod, data = dat_yearly_means)

carrotMgplot <- plot_pred_with_raw_indicator(
  carrotMgmod,
  dat_yearly_means,
  response_var  = "carrot1",
  indicator_var = "Mg",
  x_label       = "MIII Magnesium (ppm)",
  y_label       = "Carrot Yield (g)"
)

carrotMgplot

ggsave(
  "carrotMgplot.jpg",
  plot   = carrotMgplot,
  path   = CONFIG$outputs_dir,
  width  = 7,
  height = 4,
  units  = "in",
  dpi    = 300
)

# --- Kale candidate models (Years 2-3 only) ---
# Top AIC candidates: BD (rank 1) and SOC (rank 2, ΔAICc = 1.23)

kaleBDmod  <- lm(kale ~ BD  + year, data = dat_kale, na.action = na.omit)
kaleSOCmod <- lm(kale ~ SOC + year, data = dat_kale, na.action = na.omit)

summary(kaleBDmod)
summary(kaleSOCmod)

check_diagnostics(kaleBDmod,  data = dat_kale)
check_diagnostics(kaleSOCmod, data = dat_kale)

# Optional: plot top candidate
kaleBDplot <- plot_pred_with_raw_indicator(
  kaleBDmod,
  dat_kale,
  response_var  = "kale",
  indicator_var = "BD",
  x_label       = "Bulk Density (g/cm³)",
  y_label       = "Kale Yield (g)"
)

kaleBDplot

ggsave(
  "kaleBDplot.jpg",
  plot   = kaleBDplot,
  path   = CONFIG$outputs_dir,
  width  = 7,
  height = 4,
  units  = "in",
  dpi    = 300
)

# ----------------- 10. PERCENTAGE CHANGE CALCULATIONS FOR RESULTS TEXT -----------------
# Mean yields — bean and carrot from dat_yearly_means,
# kale from dat_kale (Years 2-3 only)
mean_bean_carrot <- dat_yearly_means %>%
  summarise(
    mean_bean   = mean(bean,    na.rm = TRUE),
    mean_carrot = mean(carrot1, na.rm = TRUE)
  )

mean_kale <- dat_kale %>%
  summarise(mean_kale = mean(kale, na.rm = TRUE))

cat("Mean bean yield:   ", round(mean_bean_carrot$mean_bean,   1), "g\n")
cat("Mean carrot yield: ", round(mean_bean_carrot$mean_carrot, 1), "g\n")
cat("Mean kale yield:   ", round(mean_kale$mean_kale,          1), "g\n")

# Bean: 523g per ppm NH4+
bean_pct <- (523 / mean_bean_carrot$mean_bean) * 100
cat("Bean: 523g =", round(bean_pct, 1), "% of mean bean yield\n")

# Bean: 861g year effect
bean_year_pct <- (861 / mean_bean_carrot$mean_bean) * 100
cat("Bean year effect: 861g =", round(bean_year_pct, 1), "% of mean bean yield\n")

# Carrot: 24g per ppm Mg
carrot_pct_per_ppm <- (24 / mean_bean_carrot$mean_carrot) * 100
cat("Carrot: 24g per ppm =", round(carrot_pct_per_ppm, 1), "% of mean carrot yield per ppm\n")

# Carrot: 2.3kg year effect
carrot_year_pct <- (2300 / mean_bean_carrot$mean_carrot) * 100
cat("Carrot year effect: 2.3kg =", round(carrot_year_pct, 1), "% of mean carrot yield\n")

# Mg range for context
mg_range <- range(dat_yearly_means$Mg, na.rm = TRUE)
cat("Mg range:", round(mg_range[1], 1), "to", round(mg_range[2], 1), "ppm\n")