# ============================================================
# 12_Figure_Fertility-Threshold-Macro.R
# ============================================================

# ----------------- 1. BUILD EACH PLOT -----------------
NH4mod <- lm(NH4 ~ treatment * year, data = dat_2024_T0, na.action = na.omit)
Pmod <- lm(P ~ treatment * year, data = dat_2024_T0, na.action = na.omit)
Kmod <- lm(K ~ treatment * year, data = dat_2024_T0, na.action = na.omit)
Mgmod <- lm(Mg ~ treatment * year, data = dat_2024_T0, na.action = na.omit)

NH4plot <- plot_model_with_thresholds(
  model = NH4mod,
  data = dat_2024_T0,
  response_var = "NH4",
  adequacy_low = 2,
  adequacy_high = 10,
  y_label = "NH₄⁺ Min (ppm)",
  star_y_offset = 5,
  y_limits = c(3,8)
) +
  ggtitle("NH₄⁺ Mineralization") +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      size = 16,
      face = "bold",
      margin = margin(b = 5)
    ),
    axis.text.x  = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title.y = element_text(size = 14, margin = margin(r = 10)),
    axis.text.y = element_text(size = 14),
    legend.position = "none"
  )

Pplot <- plot_model_with_thresholds(
  model = Pmod,
  data = dat_2024_T0,
  response_var = "P",
  adequacy_low = 28,
  adequacy_high = 69,
  excessive = 139,
  y_label = "MIII P (ppm)",
  star_y_offset = 3.5,
  y_limits = c(30, 110),
  y_break_by = 15#,
  #panel_title = "MIII Phosphorus"
) +
  ggtitle("MIII Phosphorus") +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      size = 16,
      face = "bold",
      margin = margin(b = 5)
    ),
    axis.text.x  = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title.y = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    legend.position = "none"
  )


Kplot <- plot_model_with_thresholds(
  model = Kmod,
  data = dat_2024_T0,
  response_var = "K",
  adequacy_low = 107,
  adequacy_high = 233,
  excessive = 561,
  y_label = "MIII K (ppm)",
  y_limits = c(100,600),
  y_break_by = 150,
  star_y_offset = 4#,
  #panel_title = "MIII Potassium"
) +
  ggtitle("MIII Potassium") +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      size = 16,
      face = "bold",
      margin = margin(b = 5)
    ),
    axis.text.x  = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title.y = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    legend.position = "none"
  )


Mgplot <- plot_model_with_thresholds(
  model = Mgmod,
  data = dat_2024_T0,
  response_var = "Mg",
  adequacy_low = 60,
  adequacy_high = 301,
  y_label = "MIII Mg (ppm)",
  y_limits = c(100, 300),
  y_break_by = 40,
  star_y_offset = 4
) +  
  ggtitle("MIII Magnesium") +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      size = 16,
      face = "bold",
      margin = margin(b = 5)
    ),
    axis.title.y = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    legend.position = "none"
  )


# ----------------- 2. STACK VERTICALLY -----------------
combined_plot_macro <- (
  NH4plot / Pplot / Kplot / Mgplot
) +
  plot_layout(guides = "collect") &
  scale_x_discrete(labels = treat_labels_threshold) &   # << shared x-axis labels
  theme(
    legend.position = "right",
    legend.text = element_text(size = 14),
    legend.title = element_text(size = 14),
    plot.margin = margin(t = 10, r = 2, b = 10, l = 2),
    legend.key.width = unit(0.6, "lines"),
    legend.spacing.x = unit(2, "pt")
  )
# Display
combined_plot_macro

# ----------------- 3. EXPORT -----------------
ggsave(
  "threshold_macro.jpg",
  plot   = combined_plot_macro,
  path   = file.path(CONFIG$figs_dir, "Fertility Threshold Plots"),
  width  = 7.5,
  height = 10.5,
  units  = "in",
  dpi    = 1200
)

