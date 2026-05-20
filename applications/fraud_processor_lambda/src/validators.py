"""
===============================================================================
Validation Layer
===============================================================================

Production systems NEVER trust incoming events blindly.

Even if OUR producer generates clean payloads today,
future producers or external systems may send:

- malformed events
- incomplete JSON
- schema drift
- corrupted records

Validation protects downstream systems from bad data.
"""


# Required fields expected inside every transaction event.
REQUIRED_FIELDS = [

    "transaction_id",
    "card_number",
    "merchant_id",
    "transaction_amount",
    "transaction_timestamp",
    "location",
]


def validate_transaction(transaction: dict):

    """
    Validates transaction payload structure and business sanity.

    Returns:
        (True, None) if valid
        (False, error_message) if invalid
    """

    missing_fields = []

    # Verify every required field exists.
    for field in REQUIRED_FIELDS:

        if field not in transaction:

            missing_fields.append(field)

    # Reject payload if required fields missing.
    if missing_fields:

        return False, f"Missing fields: {missing_fields}"

    # Reject negative or zero transaction amounts.
    # Fraud systems should never process invalid monetary values.
    if transaction["transaction_amount"] <= 0:

        return False, "Invalid transaction amount"

    return True, None