import os
from dotenv import load_dotenv

load_dotenv()


AWS_REGION = os.getenv("AWS_REGION", "us-east-1")

KINESIS_STREAM_NAME = os.getenv(
    "KINESIS_STREAM_NAME",
    "rtfd-dev-transaction-ingestion-kds"
)

TRANSACTION_INTERVAL_SECONDS = float(
    os.getenv("TRANSACTION_INTERVAL_SECONDS", "0.2")
)