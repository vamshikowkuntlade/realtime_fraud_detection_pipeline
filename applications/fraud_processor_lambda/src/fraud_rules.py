"""
===============================================================================
Fraud Detection Rules
===============================================================================

This file isolates fraud-scoring logic from infrastructure logic.

This separation is VERY important because fraud rules evolve constantly.

Keeping fraud logic isolated improves:
- maintainability
- testing
- future ML integration
- rule deployment flexibility
"""


# High-value transaction threshold.
# Transactions above this amount are considered suspicious.
HIGH_AMOUNT_THRESHOLD = 1000


# Geographies intentionally marked as high-risk for demo purposes.
# Later phases may evolve this into:
# - risk databases
# - external APIs
# - ML-driven scoring
RISKY_LOCATIONS = [

    "Mumbai",
    "Lagos",
]


def evaluate_fraud(transaction: dict):

    """
    Applies simple rule-based fraud detection.

    Returns:
    {
        "fraud_flag": bool,
        "fraud_reasons": list
    }
    """

    fraud_reasons = []

    # Rule 1:
    # Extremely large transactions are suspicious.
    if transaction["transaction_amount"] > HIGH_AMOUNT_THRESHOLD:

        fraud_reasons.append("HIGH_AMOUNT")

    # Rule 2:
    # Transactions from risky geographies above moderate amounts
    # are flagged.
    if (
        transaction["location"] in RISKY_LOCATIONS
        and transaction["transaction_amount"] > 500
    ):

        fraud_reasons.append("RISKY_GEOLOCATION")

    return {

        "fraud_flag": len(fraud_reasons) > 0,

        "fraud_reasons": fraud_reasons,
    }