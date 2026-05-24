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



from datetime import datetime


REQUIRED_FIELDS = {
    "transaction_id": str,
    "card_number": str,
    "merchant_id": str,
    "transaction_amount": (int, float),
    "transaction_timestamp": str,
    "location": str,
}


def validate_transaction(transaction: dict):

    validation_errors = []

    # ---------------------------------------------------------
    # Validate required fields exist
    # ---------------------------------------------------------

    for field, expected_type in REQUIRED_FIELDS.items():

        if field not in transaction:

            validation_errors.append(
                f"Missing required field: {field}"
            )

            continue

        # -----------------------------------------------------
        # Validate field types
        # -----------------------------------------------------

        if not isinstance(transaction[field], expected_type):

            validation_errors.append(
                f"Invalid type for {field}"
            )

    # ---------------------------------------------------------
    # Validate transaction amount
    # ---------------------------------------------------------

    amount = transaction.get("transaction_amount")

    if isinstance(amount, (int, float)):

        if amount <= 0:

            validation_errors.append(
                "Transaction amount must be greater than zero"
            )

    # ---------------------------------------------------------
    # Validate timestamp format
    # ---------------------------------------------------------

    timestamp = transaction.get("transaction_timestamp")

    if timestamp:

        try:

            datetime.fromisoformat(timestamp)

        except ValueError:

            validation_errors.append(
                "Invalid ISO-8601 timestamp format"
            )

    # ---------------------------------------------------------
    # Final validation result
    # ---------------------------------------------------------

    if validation_errors:

        return False, validation_errors

    return True, None