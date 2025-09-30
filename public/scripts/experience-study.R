# Experience Study Helper
# -------------------------------------------
# Analizza l'esperienza osservata rispetto alle basi attese
# per coorti di assicurati. Fornisce indicatori A/E, fattori
# di credibilità e un suggerimento di tasso rettificato.

experience_table <- data.frame(
  age_band = c("25-34", "35-44", "45-54", "55-64", "65-74"),
  exposures = c(1820, 2310, 2055, 1490, 820),
  deaths = c(2, 5, 12, 18, 23),
  expected_qx = c(0.0012, 0.0018, 0.0029, 0.0048, 0.0075)
)

calculate_experience <- function(experience) {
  experience$expected_claims <- experience$exposures * experience$expected_qx
  experience$actual_qx <- with(experience, deaths / exposures)
  experience$a_to_e <- with(experience, deaths / expected_claims)

  credibility_cap <- max(experience$exposures)
  experience$credibility <- pmin(1, sqrt(experience$exposures / credibility_cap))

  base_adjustment <- sum(experience$deaths) / sum(experience$expected_claims)
  experience$adjusted_qx <- (experience$credibility * experience$actual_qx) +
    ((1 - experience$credibility) * experience$expected_qx * base_adjustment)

  list(
    table = experience,
    aggregate_ae = base_adjustment,
    weighted_adjustment = sum(experience$adjusted_qx * experience$exposures) /
      sum(experience$exposures)
  )
}

print_experience_report <- function(result) {
  cat("\n=== Experience Study Report ===\n")
  print(within(result$table, {
    actual_qx <- round(actual_qx * 1000, 3)
    expected_qx <- round(expected_qx * 1000, 3)
    adjusted_qx <- round(adjusted_qx * 1000, 3)
    a_to_e <- round(a_to_e, 3)
    credibility <- round(credibility, 3)
  }), row.names = FALSE)

  cat("\nA/E aggregato             :", round(result$aggregate_ae, 3), "\n")
  cat("Tasso medio rettificato   :", round(result$weighted_adjustment, 4), "\n")
}

# Consente l'uso come libreria o come script standalone
run_experience_example <- function() {
  result <- calculate_experience(experience_table)
  print_experience_report(result)
  invisible(result)
}

if (identical(environment(), globalenv())) {
  run_experience_example()
}

# Utilizzo personalizzato:
# 1. Creare un data.frame con colonne: age_band, exposures, deaths, expected_qx.
# 2. Passarlo a `calculate_experience()` e usare `print_experience_report()`
#    per ottenere una sintesi leggibile dei risultati.
