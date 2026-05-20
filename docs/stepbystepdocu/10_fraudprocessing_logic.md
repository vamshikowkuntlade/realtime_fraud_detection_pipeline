# Real-Time Lambda Fraud Processing Engine

---

# Objective

The objective of this phase was to transform the platform from:

```text id="3iwjlwm"
streaming infrastructure
```

into:

# A Real-Time Event-Driven Fraud Detection Engine

This phase introduced:

* real Lambda processing logic
* Kinesis record consumption
* payload decoding
* event validation
* fraud rule evaluation
* event enrichment
* S3 archival writes
* DynamoDB fraud alert persistence
* structured JSON logging
* runtime configuration management
* production-style distributed-system debugging
* and operational integration troubleshooting

At the completion of this phase, the platform officially became:

```text id="q0jlwm"
Producer
    ↓
Kinesis
    ↓
Lambda Fraud Processor
    ├── S3 Historical Archive
    └── DynamoDB Fraud Alert Store
```

---

# Final Architecture

```text id="krwjlwm"
Python Producer
        ↓
Amazon Kinesis Data Streams
        ↓
AWS Lambda Fraud Processor
       ├── Validation Layer
       ├── Fraud Rules Engine
       ├── Event Enrichment Layer
       ├── Structured Logging
       ├── S3 Historical Archive
       └── DynamoDB Fraud Alerts
```

---

# Why This Phase Was Important

Until now:

* infrastructure existed
* ingestion existed
* storage existed

BUT:

```text id="jtwjlwm"
no real processing logic existed
```

Kinesis was receiving events, but nothing was:

* validating them
* enriching them
* detecting fraud
* or routing them operationally

This phase introduced the:

# Real-Time Processing Layer

which acts as the operational brain of the platform.

---

# Core Engineering Principle

The Lambda processor was intentionally designed as:

# A Stream Processing Engine

NOT:

* a workflow orchestrator
* a batch ETL platform
* a reporting system
* or an analytics engine

Responsibilities intentionally remain narrow:

```text id="1mjlwm"
ingest → validate → enrich → route
```

This mirrors real production streaming architectures.

---

# Final Repository Structure

```text id="jlwm33"
applications/
└── fraud_processor_lambda/
    ├── src/
    │   ├── handler.py
    │   ├── fraud_rules.py
    │   ├── validators.py
    │   ├── logger.py
    │   ├── config.py
    │   └── models.py
    │
    ├── requirements.txt
    └── lambda_function.zip
```

---

# Why Application Responsibilities Were Split

The Lambda was intentionally NOT written as:

```python id="jlwm49"
one giant handler.py
```

Instead responsibilities were isolated into reusable layers.

| File           | Responsibility        |
| -------------- | --------------------- |
| handler.py     | Lambda orchestration  |
| fraud_rules.py | Fraud-scoring logic   |
| validators.py  | Payload validation    |
| logger.py      | Structured logging    |
| config.py      | Runtime configuration |
| models.py      | Event enrichment      |

This mirrors real enterprise service architecture.

---

# requirements.txt

```txt id="jlwm51"
boto3
```

---

# Why boto3 Was Added

`boto3` provides AWS SDK integration for:

* S3
* DynamoDB
* Kinesis
* Lambda service interactions

Even though Lambda runtime already includes boto3, explicitly managing dependencies prepares the platform for:

* CI/CD packaging
* deterministic deployments
* future dependency management

---

# Runtime Configuration Layer

## config.py

```python id="jlwm52"
import os

AWS_REGION = os.getenv(
    "AWS_REGION",
    "us-east-1"
)

DYNAMODB_TABLE_NAME = os.getenv(
    "DYNAMODB_TABLE_NAME"
)

S3_ARCHIVE_BUCKET = os.getenv(
    "S3_ARCHIVE_BUCKET"
)
```

---

# What This Introduced

This phase introduced:

# Runtime Environment Configuration

Infrastructure values are NOT hardcoded.

Instead:

Terraform injects configuration dynamically into Lambda runtime variables.

Example:

```hcl id="jlwm53"
environment {

  variables = {

    DYNAMODB_TABLE_NAME = var.dynamodb_table_name

    S3_ARCHIVE_BUCKET = var.s3_bucket_name
  }
}
```

This improves:

* portability
* multi-environment deployment
* CI/CD compatibility
* infrastructure reuse

---

# Structured Logging Layer

## logger.py

```python id="jlwm54"
import json
import logging
import sys


class JsonFormatter(logging.Formatter):

    def format(self, record):

        log_record = {

            "level": record.levelname,

            "message": record.getMessage(),

            "timestamp": self.formatTime(record),

            "logger": record.name,
        }

        return json.dumps(log_record)


def get_logger(name: str):

    logger = logging.getLogger(name)

    logger.setLevel(logging.INFO)

    if not logger.handlers:

        handler = logging.StreamHandler(sys.stdout)

        handler.setFormatter(JsonFormatter())

        logger.addHandler(handler)

    return logger
```

---

# Why Structured Logging Matters

Cloud-native systems rely heavily on logs for:

* observability
* debugging
* monitoring
* operational investigations
* distributed tracing

Structured JSON logs enable:

* CloudWatch Insights queries
* searchable operational telemetry
* centralized observability

This mirrors production monitoring architecture.

---

# Validation Layer

## validators.py

```python id="jlwm55"
REQUIRED_FIELDS = [

    "transaction_id",
    "card_number",
    "merchant_id",
    "transaction_amount",
    "transaction_timestamp",
    "location",
]


def validate_transaction(transaction: dict):

    missing_fields = []

    for field in REQUIRED_FIELDS:

        if field not in transaction:

            missing_fields.append(field)

    if missing_fields:

        return False, f"Missing fields: {missing_fields}"

    if transaction["transaction_amount"] <= 0:

        return False, "Invalid transaction amount"

    return True, None
```

---

# Why Validation Was Introduced

Production systems NEVER trust incoming events blindly.

Validation protects downstream systems from:

* malformed payloads
* corrupted records
* schema drift
* invalid business values

Without validation:

```text id="jlwm56"
bad event
    ↓
Lambda failure
    ↓
consumer lag
    ↓
retry storms
```

This introduced:

# Defensive Event Engineering

---

# Fraud Detection Layer

## fraud_rules.py

```python id="jlwm57"
HIGH_AMOUNT_THRESHOLD = 3000

RISKY_LOCATIONS = [

    "Mumbai",
    "Lagos",
]


def evaluate_fraud(transaction: dict):

    fraud_reasons = []

    if transaction["transaction_amount"] > HIGH_AMOUNT_THRESHOLD:

        fraud_reasons.append("HIGH_AMOUNT")

    if (
        transaction["location"] in RISKY_LOCATIONS
        and transaction["transaction_amount"] > 500
    ):

        fraud_reasons.append("RISKY_GEOLOCATION")

    return {

        "fraud_flag": len(fraud_reasons) > 0,

        "fraud_reasons": fraud_reasons,
    }
```

---

# Why Fraud Logic Was Isolated

Fraud rules evolve constantly.

Separating fraud logic from infrastructure logic improves:

* maintainability
* independent testing
* future ML integration
* rule deployment flexibility

This mirrors real fraud-detection platforms.

---

# Event Enrichment Layer

## models.py

```python id="jlwm58"
from datetime import datetime, timedelta


def enrich_transaction(
    transaction: dict,
    fraud_result: dict
):

    transaction["fraud_flag"] = fraud_result["fraud_flag"]

    transaction["fraud_reasons"] = fraud_result["fraud_reasons"]

    transaction["processed_at"] = datetime.utcnow().isoformat()

    transaction["timestamp"] = transaction[
        "transaction_timestamp"
    ]

    transaction["expiry_time"] = int(

        (
            datetime.utcnow() + timedelta(days=90)
        ).timestamp()
    )

    return transaction
```

---

# What Event Enrichment Means

Streaming systems progressively add metadata to events.

Example evolution:

```text id="jlwm59"
raw event
    ↓
validated event
    ↓
fraud-scored event
    ↓
operationally enriched event
```

This phase introduced:

* fraud metadata
* operational timestamps
* TTL lifecycle management
* DynamoDB schema adaptation

---

# Main Lambda Processing Engine

## handler.py

```python id="jlwm60"
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


logger = get_logger(__name__)

dynamodb = boto3.resource("dynamodb")

fraud_table = dynamodb.Table(
    DYNAMODB_TABLE_NAME
)

s3_client = boto3.client("s3")
```

---

# Why These Components Matter

This initialized:

| Component               | Responsibility            |
| ----------------------- | ------------------------- |
| boto3 DynamoDB resource | operational fraud storage |
| boto3 S3 client         | archival storage          |
| structured logger       | observability             |
| enrichment layer        | metadata evolution        |
| fraud rules             | scoring engine            |
| validation layer        | defensive processing      |

---

# S3 Archival Logic

## archive_to_s3()

```python id="jlwm61"
def archive_to_s3(transaction: dict):

    timestamp = datetime.utcnow()

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

        ServerSideEncryption="aws:kms",
    )
```

---

# Why Partitioned S3 Structure Was Used

Objects were intentionally partitioned using:

```text id="jlwm62"
year=
month=
day=
```

This improves:

* Athena analytical performance
* partition pruning
* query efficiency
* historical archival organization

This mirrors real governed data-lake design.

---

# Why SSE-KMS Was Added

The S3 bucket policy enforced:

```text id="jlwm63"
all uploads MUST use SSE-KMS encryption
```

Without encryption headers:

```text id="jlwm64"
S3 explicitly denied uploads
```

This introduced an important AWS security concept:

# Explicit DENY Always Wins

---

# DynamoDB Write Logic

## write_fraud_alert()

```python id="jlwm65"
def write_fraud_alert(transaction: dict):

    transaction["transaction_amount"] = Decimal(
        str(transaction["transaction_amount"])
    )

    fraud_table.put_item(
        Item=transaction
    )
```

---

# Why Decimal Conversion Was Required

DynamoDB does NOT support Python float types.

Financial systems require precise decimal arithmetic.

Example floating-point issue:

```python id="jlwm66"
0.1 + 0.2
```

becomes:

```python id="jlwm67"
0.30000000000000004
```

This introduced a critical financial engineering concept:

# Money Should NEVER Use Floating-Point Arithmetic

---

# Kinesis Record Processing

## process_record()

```python id="jlwm68"
payload = base64.b64decode(
    record["kinesis"]["data"]
)

transaction = json.loads(payload)
```

---

# What This Introduced

Kinesis stores records as:

```text id="jlwm69"
Base64-encoded bytes
```

Lambda processing converts:

```text id="jlwm70"
Base64 bytes
    ↓
JSON string
    ↓
Python dictionary
```

This introduced:

# Event Serialization & Stream Decoding

---

# Lambda Handler

## lambda_handler()

```python id="jlwm71"
def lambda_handler(event, context):

    for record in event["Records"]:

        try:

            process_record(record)

        except Exception as error:

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
```

---

# Why Record-Level Exception Isolation Matters

Without isolated processing:

```text id="jlwm72"
1 bad record
    ↓
entire batch fails
```

This introduced:

# Fault Isolation

which is critical in distributed stream-processing systems.

---

# Production Debugging Issues Encountered

This phase intentionally exposed real distributed-system integration failures.

---

# Issue 1 — S3 AccessDenied

## Problem

Lambda failed writing to S3.

## Root Cause

Bucket policy enforced SSE-KMS encryption.

Lambda upload lacked:

```python id="jlwm73"
ServerSideEncryption="aws:kms"
```

## Resolution

Added SSE-KMS upload header.

---

# Issue 2 — DynamoDB Float Failure

## Problem

```text id="jlwm74"
Float types are not supported
```

## Root Cause

DynamoDB rejects Python float types.

## Resolution

Converted float values into:

```python id="jlwm75"
Decimal(str(value))
```

---

# Issue 3 — Missing DynamoDB Sort Key

## Problem

```text id="jlwm76"
Missing key timestamp
```

## Root Cause

DynamoDB schema required:

```text id="jlwm77"
transaction_id
timestamp
```

but event only contained:

```text id="jlwm78"
transaction_timestamp
```

## Resolution

Enrichment layer adapted streaming schema into operational schema.

---

# Issue 4 — Python Syntax Error

## Problem

```text id="jlwm79"
expected indented block
```

## Root Cause

Python indentation mistake after function definition.

## Resolution

Corrected indentation structure.

---

# Issue 5 — datetime Not Defined

## Problem

```text id="jlwm80"
name 'datetime' is not defined
```

## Root Cause

Missing import.

## Resolution

Added:

```python id="jlwm81"
from datetime import datetime, timedelta
```

---

# Operational Validation Achieved

At completion of this phase:

✅ Kinesis stream ingestion works
✅ Lambda event processing works
✅ Payload decoding works
✅ Validation layer works
✅ Fraud scoring works
✅ Event enrichment works
✅ S3 archival writes work
✅ DynamoDB fraud writes work
✅ Structured logging works
✅ Runtime configuration works
✅ Distributed-system debugging completed

---

# Final Operational Flow

```text id="jlwm82"
Producer
    ↓
Kinesis
    ↓
Lambda Fraud Processor
    ├── Validation
    ├── Fraud Scoring
    ├── Event Enrichment
    ├── Structured Logging
    ├── S3 Historical Archive
    └── DynamoDB Fraud Alerts
```

---

# Engineering Concepts Learned

This phase introduced several critical production-grade concepts:

* event-driven processing
* Kinesis stream decoding
* structured JSON logging
* defensive validation
* fraud-scoring architecture
* event enrichment
* S3 governed archival
* DynamoDB operational persistence
* SSE-KMS enforcement
* Decimal financial arithmetic
* schema adaptation
* distributed-system debugging
* CloudWatch operational troubleshooting
* and fault-isolated stream processing

---

# Engineering Outcome

At the completion of this phase:

The platform officially evolved from:

```text id="jlwm83"
streaming infrastructure
```

into:

# A Real-Time Distributed Fraud Detection Engine

capable of:

* ingesting live transactions
* processing events in real time
* detecting fraud
* archiving historical records
* storing operational fraud alerts
* and supporting production-style observability and debugging workflows.
