# Chain Ladder Reserving Toolkit
# -------------------------------------------
# Questo script offre funzioni base per calcolare
# fattori di sviluppo, completare un triangolo di sinistri
# cumulato e produrre un riepilogo di riserva utilizzando
# il metodo Chain Ladder con un fattore di coda automatico.
# È scritto solo con funzioni base di R per evitare
# dipendenze esterne.

# Triangolo di esempio (cumulato)
triangle <- matrix(
  c(
    1245, 1894, 2050, 2137, 2162, 2174,
    1312, 1940, 2115, 2208, 2233, NA,
    1398, 2031, 2245, 2336, NA,   NA,
    1476, 2147, 2362, NA,   NA,   NA,
    1540, 2255, NA,   NA,   NA,   NA,
    1638, NA,   NA,   NA,   NA,   NA
  ),
  nrow = 6,
  byrow = TRUE,
  dimnames = list(
    c("2018", "2019", "2020", "2021", "2022", "2023"),
    c("12", "24", "36", "48", "60", "72")
  )
)

# Calcola i fattori di sviluppo medi (volume-weighted)
calc_development_factors <- function(triangle) {
  n_dev <- ncol(triangle)
  factors <- numeric(n_dev - 1)
  for (j in 1:(n_dev - 1)) {
    current <- triangle[1:(nrow(triangle) - j), j]
    next_col <- triangle[1:(nrow(triangle) - j), j + 1]
    valid <- !is.na(current) & !is.na(next_col) & current > 0
    factors[j] <- if (any(valid)) sum(next_col[valid]) / sum(current[valid]) else 1
  }
  stats <- list(
    factors = factors,
    selected = factors,
    tail = tail_factor(factors)
  )
  attr(stats, "class") <- "development_factors"
  stats
}

tail_factor <- function(factors) {
  if (length(factors) == 0) return(1)
  avg_last_two <- if (length(factors) >= 2) mean(tail(factors, 2)) else tail(factors, 1)
  max(avg_last_two, 1)
}

# Completa il triangolo riempiendo le celle NA
complete_triangle <- function(triangle, factors) {
  filled <- triangle
  n_dev <- ncol(triangle)
  for (i in 1:nrow(triangle)) {
    for (j in 1:n_dev) {
      if (is.na(filled[i, j])) {
        prev_value <- filled[i, j - 1]
        if (is.na(prev_value)) next
        factor <- if (j == n_dev) factors$tail else factors$selected[j - 1]
        filled[i, j] <- prev_value * factor
      }
    }
  }
  filled
}

# Crea il riepilogo delle riserve ultimate e IBNR
summary_reserve <- function(original, completed) {
  latest <- apply(original, 1, function(row) {
    vals <- row[!is.na(row)]
    if (length(vals) == 0) return(0)
    tail(vals, 1)
  })
  ultimate <- completed[, ncol(completed)]
  ibnr <- pmax(ultimate - latest, 0)
  data.frame(
    origin_year = rownames(original),
    latest = round(latest, 2),
    ultimate = round(ultimate, 2),
    ibnr = round(ibnr, 2),
    row.names = NULL
  )
}

# Calcola il totale aggregato e un controllo di reasonableness
aggregate_summary <- function(reserve_summary) {
  total_latest <- sum(reserve_summary$latest)
  total_ultimate <- sum(reserve_summary$ultimate)
  list(
    total_latest = total_latest,
    total_ultimate = total_ultimate,
    total_ibnr = total_ultimate - total_latest,
    weighted_loss_dev_factor = total_ultimate / total_latest
  )
}

# Funzione utility: stampa la tabella in modo leggibile
print_reserve_report <- function(reserve_summary, aggregate_stats, factors) {
  cat("\n=== Chain Ladder Reserve Report ===\n")
  cat("Fattori di sviluppo selezionati:\n")
  for (i in seq_along(factors$selected)) {
    cat(sprintf("  %s -> %s : %.4f\n",
      colnames(triangle)[i], colnames(triangle)[i + 1], factors$selected[i]))
  }
  cat(sprintf("  Tail factor (ultimo periodo): %.4f\n\n", factors$tail))

  print(reserve_summary, row.names = FALSE)

  cat("\nTotale ultimo sviluppo noto :", round(aggregate_stats$total_latest, 2), "\n")
  cat("Totale ultimo previsto    :", round(aggregate_stats$total_ultimate, 2), "\n")
  cat("IBNR complessivo          :", round(aggregate_stats$total_ibnr, 2), "\n")
  cat("Fattore sviluppo pesato   :", round(aggregate_stats$weighted_loss_dev_factor, 4), "\n")
}

# Esecuzione completa se lo script viene invocato direttamente
run_example <- function(triangle) {
  factors <- calc_development_factors(triangle)
  completed <- complete_triangle(triangle, factors)
  reserve_summary <- summary_reserve(triangle, completed)
  aggregate_stats <- aggregate_summary(reserve_summary)
  list(
    factors = factors,
    completed_triangle = completed,
    reserve_summary = reserve_summary,
    aggregate = aggregate_stats
  )
}

if (identical(environment(), globalenv())) {
  report <- run_example(triangle)
  print_reserve_report(report$reserve_summary, report$aggregate, report$factors)
}

# Per utilizzare le funzioni con i propri dati:
# 1. Sostituire `triangle` con un triangolo cumulato che contenga NA oltre
#    all'ultima diagonale disponibile.
# 2. Chiamare `run_example(your_triangle)` per ottenere fattori, triangolo completato
#    e il riepilogo delle riserve.
