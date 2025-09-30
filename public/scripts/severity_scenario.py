"""Severity Scenario Simulator
--------------------------------------------
Genera campioni sintetici di severità sinistri utilizzando
una miscela di distribuzioni lognormali e Pareto.
Utile per confrontare scenari stress test e analisi di coda.
"""

from math import exp, log
from random import random
from statistics import mean, quantiles
from typing import List


def pareto_sample(alpha: float, xm: float) -> float:
    """Campione da una distribuzione Pareto classica."""
    u = 1 - random()
    return xm / (u ** (1 / alpha))


def lognormal_sample(mu: float, sigma: float) -> float:
    """Campione da una lognormale parametrizzata da media logaritmica e sigma."""
    from random import gauss

    return float(exp(gauss(mu, sigma)))


def severity_mixture(n: int, weight: float = 0.75) -> List[float]:
    samples: List[float] = []
    for _ in range(n):
        # weight determina la probabilità di utilizzare la componente lognormale
        if random() < weight:
            samples.append(lognormal_sample(mu=log(4_500), sigma=0.55))
        else:
            samples.append(pareto_sample(alpha=2.2, xm=12_000))
    return samples


def summarize(samples: List[float]) -> None:
    qs = quantiles(samples, n=100)
    print("Campioni generati       :", len(samples))
    print("Severità media          :", round(mean(samples), 2))
    print("Mediana                 :", round(qs[49], 2))
    print("P90 / P95 / P99        :", round(qs[89], 2), round(qs[94], 2), round(qs[98], 2))


def main() -> None:
    print("=== Severity Scenario Simulator ===")
    base_samples = severity_mixture(10_000, weight=0.8)
    summarize(base_samples)

    stress_samples = severity_mixture(10_000, weight=0.55)
    print("\nScenario stress (maggiore peso di coda Pareto):")
    summarize(stress_samples)


if __name__ == "__main__":
    main()
