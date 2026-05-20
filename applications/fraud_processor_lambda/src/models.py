from datetime import datetime, timedelta

def enrich_transaction(
    transaction: dict,
    fraud_result: dict
):

    transaction["fraud_flag"] = fraud_result["fraud_flag"]

    transaction["fraud_reasons"] = fraud_result["fraud_reasons"]

    transaction["processed_at"] = datetime.utcnow().isoformat()

    # DynamoDB sort key
    transaction["timestamp"] = transaction[
        "transaction_timestamp"
    ]

    transaction["expiry_time"] = int(

        (
            datetime.utcnow() + timedelta(days=90)
        ).timestamp()
    )

    return transaction