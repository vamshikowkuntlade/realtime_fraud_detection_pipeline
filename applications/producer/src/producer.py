import json
import signal
import sys
import time

import boto3

from config import (
    AWS_REGION,
    KINESIS_STREAM_NAME,
    TRANSACTION_INTERVAL_SECONDS,
)
from logger import get_logger
from transaction_generator import generate_transaction_event


logger = get_logger(__name__)


running = True


def shutdown_handler(signum, frame):
    """
    Gracefully stop producer process.
    """

    global running

    logger.info(
        "Shutdown signal received. Stopping producer gracefully."
    )

    running = False


signal.signal(signal.SIGINT, shutdown_handler)
signal.signal(signal.SIGTERM, shutdown_handler)


kinesis_client = boto3.client(
    "kinesis",
    region_name=AWS_REGION,
)


def publish_transaction():
    """
    Generate and publish transaction event to Kinesis.
    """

    transaction = generate_transaction_event()

    transaction_payload = transaction.to_dict()

    response = kinesis_client.put_record(
        StreamName=KINESIS_STREAM_NAME,
        Data=json.dumps(transaction_payload),
        PartitionKey=transaction.card_number,
    )

    logger.info(
        json.dumps(
            {
                "event": "transaction_published",
                "transaction_id": transaction.transaction_id,
                "partition_key": transaction.card_number,
                "sequence_number": response["SequenceNumber"],
            }
        )
    )


def main():
    """
    Main continuous producer loop.
    """

    logger.info("Starting transaction producer.")

    while running:

        try:

            publish_transaction()

            time.sleep(TRANSACTION_INTERVAL_SECONDS)

        except Exception as error:

            logger.error(
                json.dumps(
                    {
                        "event": "producer_error",
                        "error": str(error),
                    }
                )
            )

    logger.info("Producer stopped gracefully.")

    sys.exit(0)


if __name__ == "__main__":
    main()