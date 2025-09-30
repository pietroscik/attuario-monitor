"""Loss Ratio Monitor
--------------------------------------------
Script Python per calcolare loss ratio, combined ratio
ed evoluzione temporale di portafogli assicurativi.
Può essere eseguito con `python loss_ratio.py`.
"""

from dataclasses import dataclass
from typing import Iterable, List


@dataclass
class Segment:
    name: str
    earned_premium: float
    claims_paid: float
    case_reserves: float
    expenses: float = 0.0

    @property
    def incurred_claims(self) -> float:
        return self.claims_paid + self.case_reserves

    @property
    def loss_ratio(self) -> float:
        if self.earned_premium == 0:
            return 0.0
        return self.incurred_claims / self.earned_premium

    @property
    def combined_ratio(self) -> float:
        if self.earned_premium == 0:
            return 0.0
        return (self.incurred_claims + self.expenses) / self.earned_premium


def aggregate(segments: Iterable[Segment]) -> Segment:
    segments = list(segments)
    return Segment(
        name="Aggregato",
        earned_premium=sum(s.earned_premium for s in segments),
        claims_paid=sum(s.claims_paid for s in segments),
        case_reserves=sum(s.case_reserves for s in segments),
        expenses=sum(s.expenses for s in segments),
    )


def loss_ratio_trend(history: List[Segment]) -> List[float]:
    """Restituisce la progressione della loss ratio cumulata."""
    ratios = []
    premium_cum = 0.0
    incurred_cum = 0.0
    for segment in history:
        premium_cum += segment.earned_premium
        incurred_cum += segment.incurred_claims
        ratios.append(0.0 if premium_cum == 0 else incurred_cum / premium_cum)
    return ratios


def format_ratio(value: float) -> str:
    return f"{value:.1%}"


def main() -> None:
    quarterly_history = [
        Segment("Q1", earned_premium=3_250_000, claims_paid=1_420_000, case_reserves=320_000, expenses=610_000),
        Segment("Q2", earned_premium=3_340_000, claims_paid=1_390_000, case_reserves=305_000, expenses=595_000),
        Segment("Q3", earned_premium=3_410_000, claims_paid=1_515_000, case_reserves=342_000, expenses=602_000),
        Segment("Q4", earned_premium=3_560_000, claims_paid=1_498_000, case_reserves=357_000, expenses=618_000),
    ]

    print("=== Loss Ratio Monitor ===")
    for seg in quarterly_history:
        print(
            f"{seg.name}: loss ratio {format_ratio(seg.loss_ratio)} | combined ratio {format_ratio(seg.combined_ratio)}"
        )

    portfolio = aggregate(quarterly_history)
    print("\nAggregato anno: loss ratio", format_ratio(portfolio.loss_ratio))
    print("Aggregato anno: combined ratio", format_ratio(portfolio.combined_ratio))

    trend = loss_ratio_trend(quarterly_history)
    print("\nTrend cumulato:")
    for seg, ratio in zip(quarterly_history, trend):
        print(f"  Fino a {seg.name}: {format_ratio(ratio)}")


if __name__ == "__main__":
    main()
