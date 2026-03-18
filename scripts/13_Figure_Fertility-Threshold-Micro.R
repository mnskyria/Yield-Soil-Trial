# ============================================================
# 13_Figure_Fertility-Threshold-Micro.R
# ============================================================

# ----------------- 1. BUILD EACH PLOT -----------------
Cumod <- lm(Cu ~ treatment * year, data = dat_2024_T0, na.action = na.omit)
Mnmod <- lm(Mn ~ treatment * year, data = dat_2024_T0, na.action = na.omit)
Znmod <- lm(Zn ~ treatment * year, data = dat_2024_T0, na.action = na.omit)


Cuplot <- plot_model_with_thresholds(
  model = Cumod,
  data = dat_2024_T0,
  response_var = "Cu",
  adequacy_low = 0.8,
  adequacy_high = 100,
  y_label = "MIII Cu (ppm)",
  y_limits = c(2, 7)
) +
  ggtitle("MIII Copper") +
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


Mnplot <- plot_model_with_thresholds(
  model = Mnmod,
  data = dat_2024_T0,
  response_var = "Mn",
  adequacy_low = 9,
  adequacy_high = 44,
  y_label = "MIII Mn (ppm)",
  y_limits = c(20, 79),
  y_break_by = 10,
  star_y_offset = 1.5
) +
  ggtitle("MIII Manganese") +
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


Znplot <- plot_model_with_thresholds(
  model = Znmod,
  data = dat_2024_T0,
  response_var = "Zn",
  adequacy_low = 2.8,
  adequacy_high = 1000,
  y_label = "MIII Zn (ppm)",
  y_limits = c(10, 180),
  y_break_by = 30,
  star_y_offset = 2
) +  
  scale_x_discrete(labels = treat_labels_threshold)+
  ggtitle("MIII Zinc") +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      size = 16,
      face = "bold",
      margin = margin(b = 5)
    ),
    axis.title.y = element_text(size = 14, margin = margin(r = 10)),
    axis.text.y = element_text(size = 14),
    legend.position = "none"
  )

# ----------------- 2. STACK VERTICALLY -----------------
combined_plot_micro <- (
  Cuplot / Mnplot / Znplot
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
combined_plot_micro

# ----------------- 3. EXPORT -----------------
ggsave(
  "threshold_micro.png",
  plot   = combined_plot_micro,
  path   = file.path(CONFIG$figs_dir, "Fertility Threshold Plots"),
  width  = 7.5,
  height = 7.5,
  units  = "in",
  dpi    = 300
)

