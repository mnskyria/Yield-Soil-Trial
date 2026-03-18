# ============================================================
# 02_Summaries.R
# ============================================================

# ----------------- 1. SUMMARIZE FUNCTION -----------------

summarise_vars <- function(data, group_by_cols, vars) {
  data |>
    group_by(dplyr::across(all_of(group_by_cols))) |>
    summarise(
      across(
        all_of(vars),
        list(
          mean = ~round(mean(.x, na.rm = TRUE), 3),
          se   = ~round(sd(.x, na.rm = TRUE) / sqrt(sum(!is.na(.x))), 3)
        ),
        .names = "{.col}_{.fn}"
      ),
      .groups = "drop"
    )
}
# ----------------- 2. SOIL SUMMARIES (all years, no T0) -----------------

sum_soil_all <- summarise_vars(
  dat,
  c("year", "treatment"),
  soil_vars
) |>
  pivot_longer(
    -(year:treatment),
    names_to  = c("variable", ".value"),
    names_sep = "_(?=[^_]+$)"
  ) |>
  select(year, treatment, variable, mean, se) |>
  arrange(variable, year, treatment)

# ----------------- 3. CROP SUMMARIES (all years, no T0) -----------------
sum_crop_all <- summarise_vars(
  dat |> filter(year != "T0"),
  c("year", "treatment"),
  crop_vars
) |>
  pivot_longer(
    -(year:treatment),
    names_to  = c("variable", ".value"),
    names_sep = "_(?=[^_]+$)"
  ) |>
  select(year, treatment, variable, mean, se) |>
  arrange(variable, year, treatment)

# ----------------- 4. WRITE -----------------
readr::write_csv(
  sum_soil_all,
  file.path(CONFIG$summ_dir, "summary_soil_all_years.csv")
)

readr::write_csv(
  sum_crop_all,
  file.path(CONFIG$summ_dir, "summary_crops_all_years.csv")
)

message("✓ Summaries written to: ", CONFIG$summ_dir)
