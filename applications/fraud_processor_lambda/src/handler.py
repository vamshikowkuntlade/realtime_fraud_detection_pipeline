"""
===============================================================================
Main Lambda Fraud Processing Engine
===============================================================================

This file acts as the Lambda entrypoint.

Responsibilities:
- decode Kinesis records
- validate payloads
- apply fraud rules
- enrich events
- archive events into S3
- store fraud alerts in DynamoDB
- emit operational logs

This Lambda intentionally acts ONLY as:
    ingest → process → enrich → route

It is NOT:
- a workflow orchestrator
- a BI system
- a batch ETL platform
"""

import base64
import json
from datetime import datetime
from decimal import Decimal

import boto3

from config import (
    DYNAMODB_TABLE_NAME,
    S3_ARCHIVE_BUCKET,
)

from fraud_rules import evaluate_fraud

from logger import get_logger

from models import enrich_transaction

from validators import validate_transaction


# Structured application logger.
logger = get_logger(__name__)


# Initialize DynamoDB resource client.
# Resource API is higher-level and object-oriented.
dynamodb = boto3.resource("dynamodb")


# Reference operational fraud alerts table.
fraud_table = dynamodb.Table(
    DYNAMODB_TABLE_NAME
)


# Initialize low-level S3 client.
s3_client = boto3.client("s3")


def archive_to_s3(transaction: dict):

    """
    Archives ALL processed transactions into S3.

    S3 acts as:
    - historical archive
    - analytical storage layer
    - Athena query source
    - audit retention layer
    """

    timestamp = datetime.utcnow()

    # Hive-compatible partitioned folder structure.
    # This improves Athena analytical performance later.
    key = (

        f"raw/"
        f"year={timestamp.year}/"
        f"month={timestamp.month:02d}/"
        f"day={timestamp.day:02d}/"
        f"{transaction['transaction_id']}.json"
    )

    s3_client.put_object(

        Bucket=S3_ARCHIVE_BUCKET,

        Key=key,

        Body=json.dumps(transaction),

        ContentType="application/json",

        ServerSideEncryption="aws:kms",  #denied upload to S3, bacsue of explicit deny
    )




def write_fraud_alert(transaction: dict):

    """
    DynamoDB does not support Python float types.

    Financial systems require precise decimal arithmetic.

    Therefore:
    convert float monetary values into Decimal objects
    before writing into DynamoDB.
    """

    transaction["transaction_amount"] = Decimal(
        str(transaction["transaction_amount"])
    )

    fraud_table.put_item(
        Item=transaction
    )
    




def process_record(record):

    """
    Processes individual Kinesis record.
    """

    # Kinesis stores payloads as Base64 encoded bytes.
    payload = base64.b64decode(
        record["kinesis"]["data"]
    )

    # Convert JSON payload into Python dictionary.
    transaction = json.loads(payload)

    # Validate payload structure.
    valid, error = validate_transaction(transaction)

    if not valid:

        logger.error(

            json.dumps(
                {
                    "event": "validation_failed",
                    "error": error,
                    "transaction": transaction,
                }
            )
        )

        return

    # Execute fraud-scoring logic.
    fraud_result = evaluate_fraud(transaction)

    # Attach operational enrichment metadata.
    enriched_transaction = enrich_transaction(
        transaction,
        fraud_result,
    )

    # Archive ALL transactions into historical S3 lake.
    archive_to_s3(enriched_transaction)

    # Store only fraud alerts operationally.
    if enriched_transaction["fraud_flag"]:

        write_fraud_alert(enriched_transaction)

    # Emit structured operational log.
    logger.info(

        json.dumps(
            {
                "event": "transaction_processed",
                "transaction_id": enriched_transaction["transaction_id"],
                "fraud_flag": enriched_transaction["fraud_flag"],
            }
        )
    )


def lambda_handler(event, context):

    """
    AWS Lambda entrypoint.

    Event Source Mapping automatically delivers batches
    from Kinesis into this handler.
    """

    for record in event["Records"]:

        try:

            process_record(record)

        except Exception as error:

            # Isolate individual record failures.
            # Prevent one bad event from crashing entire batch.
            logger.error(

                json.dumps(
                    {
                        "event": "processing_failure",
                        "error": str(error),
                    }
                )
            )

    return {
        "statusCode": 200
    }