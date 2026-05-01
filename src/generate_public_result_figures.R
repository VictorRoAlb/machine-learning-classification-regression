args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 2) {
  stop("Usage: Rscript generate_public_result_figures.R <source_dir> <output_dir>")
}

source_dir <- normalizePath(args[[1]], mustWork = TRUE)
output_dir <- args[[2]]

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(pROC)
})

load_rds <- function(filename) {
  readRDS(file.path(source_dir, filename))
}

save_plot <- function(plot_obj, filename, width, height) {
  ggsave(
    filename = file.path(output_dir, filename),
    plot = plot_obj,
    width = width,
    height = height,
    dpi = 300,
    bg = "white"
  )
}

classification_cv <- load_rds("resultados_cv_clasificacion_binaria_todos_final.rds") %>%
  mutate(Modelo = factor(Modelo, levels = Modelo[order(Kappa_CV, Accuracy_CV)]))

classification_cv_long <- bind_rows(
  classification_cv %>%
    transmute(Modelo, Metric = "Accuracy", Value = Accuracy_CV),
  classification_cv %>%
    transmute(Modelo, Metric = "Kappa", Value = Kappa_CV)
)

classification_cv_plot <- ggplot(
  classification_cv_long,
  aes(x = Modelo, y = Value, fill = Metric)
) +
  geom_col(
    position = position_dodge(width = 0.72),
    width = 0.64
  ) +
  coord_flip() +
  scale_fill_manual(values = c("Accuracy" = "#24597f", "Kappa" = "#9b5b31")) +
  labs(
    title = "Classification model comparison in cross-validation",
    subtitle = "Five-fold validation summary used to select the final binary classifier",
    x = NULL,
    y = "Score"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 15.5, color = "#102033"),
    plot.subtitle = element_text(size = 10.5, color = "#5c6b7d"),
    axis.title.y = element_blank(),
    axis.text = element_text(color = "#31465d"),
    legend.position = "top",
    legend.title = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank()
  )

save_plot(classification_cv_plot, "classification_cv_summary.png", 10.4, 6.0)

roc_list <- load_rds("roc_list_clasificacion_binaria_final.rds")

roc_plot <- ggroc(roc_list, legacy.axes = TRUE, linewidth = 0.9) +
  geom_abline(linetype = "dashed", linewidth = 0.4, color = "#66788d") +
  labs(
    title = "ROC comparison across classification models",
    subtitle = "Test-set discrimination curves for the binary technology-level task",
    x = "False positive rate",
    y = "True positive rate"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 15.5, color = "#102033"),
    plot.subtitle = element_text(size = 10.5, color = "#5c6b7d"),
    axis.title = element_text(face = "bold", color = "#102033"),
    axis.text = element_text(color = "#31465d"),
    legend.position = "bottom",
    legend.title = element_blank(),
    panel.grid.minor = element_blank()
  )

save_plot(roc_plot, "classification_roc_comparison.png", 7.6, 5.8)

regression_cv <- load_rds("resultados_cv_regresion_final.rds")

regression_cv_long <- bind_rows(
  regression_cv %>% transmute(Modelo, Metric = "RMSE", Value = RMSE_CV),
  regression_cv %>% transmute(Modelo, Metric = "MAE", Value = MAE_CV),
  regression_cv %>% transmute(Modelo, Metric = "R-squared", Value = Rsquared_CV)
)

regression_cv_plot <- ggplot(
  regression_cv_long,
  aes(x = reorder(Modelo, Value), y = Value, fill = Metric)
) +
  geom_col(width = 0.68, show.legend = FALSE) +
  coord_flip() +
  facet_wrap(~Metric, scales = "free_x", ncol = 1) +
  scale_fill_manual(values = c("RMSE" = "#24597f", "MAE" = "#3f8d71", "R-squared" = "#9b5b31")) +
  labs(
    title = "Regression model comparison in cross-validation",
    subtitle = "Relative behaviour of the main regression candidates used in the project",
    x = NULL,
    y = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 15.5, color = "#102033"),
    plot.subtitle = element_text(size = 10.5, color = "#5c6b7d"),
    axis.text = element_text(color = "#31465d"),
    strip.text = element_text(face = "bold", color = "#102033", size = 11),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank()
  )

save_plot(regression_cv_plot, "regression_cv_summary.png", 8.8, 8.4)

predictions_log <- load_rds("predicciones_mejor_modelo_regresion_final.rds")

predictions_money <- predictions_log %>%
  mutate(
    Real_dirham = exp(Real),
    Pred_dirham = exp(Prediccion)
  )

limit_max <- max(c(predictions_money$Real_dirham, predictions_money$Pred_dirham), na.rm = TRUE)

regression_scatter_plot <- ggplot(
  predictions_money,
  aes(x = Real_dirham, y = Pred_dirham)
) +
  geom_point(color = "#24597f", alpha = 0.62, size = 2.3) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", linewidth = 0.55, color = "#9b5b31") +
  coord_equal(xlim = c(0, limit_max), ylim = c(0, limit_max)) +
  labs(
    title = "Observed vs predicted price for the final regression model",
    subtitle = "Test-set predictions after reversing the log transformation",
    x = "Observed price (Dirham)",
    y = "Predicted price (Dirham)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 15.5, color = "#102033"),
    plot.subtitle = element_text(size = 10.5, color = "#5c6b7d"),
    axis.title = element_text(face = "bold", color = "#102033"),
    axis.text = element_text(color = "#31465d"),
    panel.grid.minor = element_blank()
  )

save_plot(regression_scatter_plot, "regression_actual_vs_predicted.png", 7.2, 6.2)
