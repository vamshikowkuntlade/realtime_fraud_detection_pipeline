# Real-Time Transaction Producer


---

# Objective

The objective of this phase was to activate the platform’s real-time ingestion layer by building a production-style streaming transaction producer using Python and Amazon Kinesis Data Streams.

This phase introduced:cd~

* real-time event generation
* streaming producer engineering
* AWS SDK integration
* structured event schema design
* realistic transaction simulation
* partition-key architecture
* structured JSON logging
* graceful shutdown handling
* operational telemetry monitoring
* and production-style cloud-native application structure

This implementation intentionally mirrors how enterprise financial systems engineer upstream streaming producers for event-driven fraud platforms.

---

# Why This Phase Was Important

Before this phase, the platform infrastructure existed but no live transaction traffic was flowing through the system.

The platform already contained:

| Component         | Purpose                           |
| ----------------- | --------------------------------- |
| Terraform Backend | Infrastructure state management   |
| KMS               | Centralized encryption governance |
| IAM               | Least-privilege access control    |
| S3                | Historical analytical archive     |
| Kinesis           | Streaming ingestion backbone      |
| DynamoDB          | Operational fraud-serving store   |

However:

```text
No live events existed.
```

This phase officially transformed the project into:

# A Live Streaming System

---

# Final Architecture After This Phase

```text
Python Producer
        ↓
Amazon Kinesis Data Stream
        ↓
(Future)
Lambda Fraud Processing Engine
```

The producer now acts as the:

* upstream transaction simulator
* event ingestion source
* streaming workload generator
* and operational traffic producer

for the fraud detection platform.

---

# Important Streaming Architecture Principle

The producer intentionally performs ONLY:

```text
generate → structure → emit
```

It does NOT perform:

* fraud detection
* enrichment
* analytics
* persistence
* orchestration

Those responsibilities belong to downstream consumers.

This separation mirrors real-world event-driven architecture.

---

# Repository Structure

```text
applications/
└── producer/
    ├── src/
    │   ├── config.py
    │   ├── logger.py
    │   ├── producer.py
    │   ├── schemas.py
    │   └── transaction_generator.py
    │
    ├── tests/
    │
    ├── requirements.txt
    └── .env
```

---

# Why Structured Application Design Was Introduced

The implementation intentionally avoided:

```text
single-file producer scripts
```

Instead, the producer was separated into dedicated engineering layers.

| File                     | Responsibility            |
| ------------------------ | ------------------------- |
| schemas.py               | Event contract definition |
| transaction_generator.py | Event simulation          |
| config.py                | Runtime configuration     |
| logger.py                | Structured logging        |
| producer.py              | AWS SDK publishing        |

---

# Why Separation Of Concerns Matters

This architecture improves:

* maintainability
* readability
* scalability
* observability
* testability
* CI/CD readiness
* deployment flexibility

This mirrors production-grade streaming application design.

---

# Python Virtual Environment Setup

## Commands Executed

```bash
cd applications/producer

python3 -m venv venv

source venv/bin/activate
```

---

# Why Virtual Environments Matter

Virtual environments isolate:

* dependencies
* runtime behavior
* package versions
* application environments

This prevents:

* dependency conflicts
* inconsistent developer environments
* deployment instability

This mirrors:

* container runtimes
* Lambda packaging
* CI/CD build systems
* and isolated production deployments.

---

# Dependencies Installed

```bash
pip install boto3 python-dotenv faker
```

---

# Dependency Purpose

| Package       | Purpose                          |
| ------------- | -------------------------------- |
| boto3         | AWS SDK integration              |
| python-dotenv | Runtime configuration management |
| faker         | Realistic transaction simulation |

---

# requirements.txt

```bash
pip freeze > requirements.txt
```

This establishes reproducible dependency management.

---

# Event Schema Engineering

One of the most important streaming-system concepts introduced during this phase was:

# Event Schema Standardization

Streaming systems require:

```text
consistent event contracts
```

Without schemas:

* downstream systems break
* analytics become inconsistent
* validation becomes unreliable
* event evolution becomes chaotic

---

# schemas.py

```python
from dataclasses import dataclass, asdict
from datetime import datetime
from typing import Dict
import uuid


@dataclass
class TransactionEvent:

    transaction_id: str
    card_number: str
    merchant_id: str
    merchant_category: str
    transaction_amount: float
    currency: str
    transaction_timestamp: str
    location: str
    payment_method: str

    def to_dict(self) -> Dict:
        return asdict(self)


def generate_transaction_id() -> str:
    return str(uuid.uuid4())


def generate_timestamp() -> str:
    return datetime.utcnow().isoformat()
```

---

# Why @dataclass Was Used

The project intentionally used:

# Python Dataclasses

instead of raw dictionaries.

This improves:

* schema consistency
* readability
* type clarity
* maintainability
* reusable event contracts

This mirrors production Python engineering.

---

# Why UUID Transaction IDs Matter

Fraud systems require:

# Globally Unique Event Identifiers

UUIDs prevent:

* collisions
* replay ambiguity
* duplicate confusion
* tracing inconsistencies

---

# Why ISO-8601 Timestamps Matter

The producer intentionally generates:

```text
ISO-8601 UTC timestamps
```

because they are:

* globally standardized
* timezone-safe
* analytics-friendly
* Athena-compatible
* chronologically sortable

---

# Realistic Transaction Generator

The producer intentionally simulates:

# Real Banking Transaction Behavior

instead of meaningless random synthetic data.

---

# transaction_generator.py

```python
import random
from faker import Faker

from schemas import (
    TransactionEvent,
    generate_timestamp,
    generate_transaction_id,
)

fake = Faker()


MERCHANT_CATEGORIES = [
    "GROCERY",
    "RESTAURANT",
    "ELECTRONICS",
    "TRAVEL",
    "GAMING",
    "LUXURY",
    "FUEL",
    "HEALTHCARE",
]

PAYMENT_METHODS = [
    "CHIP",
    "SWIPE",
    "ONLINE",
    "CONTACTLESS",
]

LOCATIONS = [
    "Toronto",
    "Vancouver",
    "Montreal",
    "Calgary",
    "Mumbai",
    "Lagos",
    "New York",
    "London",
]


def generate_card_number() -> str:
    return f"****-****-****-{random.randint(1000, 9999)}"


def generate_transaction_amount() -> float:

    weighted_ranges = [
        random.uniform(5, 100),
        random.uniform(100, 500),
        random.uniform(500, 5000),
    ]

    weights = [0.7, 0.25, 0.05]

    return round(random.choices(weighted_ranges, weights=weights)[0], 2)


def generate_transaction_event() -> TransactionEvent:

    return TransactionEvent(
        transaction_id=generate_transaction_id(),
        card_number=generate_card_number(),
        merchant_id=f"MER-{random.randint(10000, 99999)}",
        merchant_category=random.choice(MERCHANT_CATEGORIES),
        transaction_amount=generate_transaction_amount(),
        currency="CAD",
        transaction_timestamp=generate_timestamp(),
        location=random.choice(LOCATIONS),
        payment_method=random.choice(PAYMENT_METHODS),
    )
```

---

# Why Weighted Transaction Distributions Matter

Real banking traffic is NOT uniformly distributed.

Most real transactions are:

```text
small-to-medium purchases
```

while large purchases are relatively rare.

The producer intentionally models:

| Range     | Probability |
| --------- | ----------- |
| $5–100    | 70%         |
| $100–500  | 25%         |
| $500–5000 | 5%          |

This creates:

* realistic behavior
* believable fraud patterns
* meaningful analytics
* operationally useful workloads

---

# Why Fraud-Prone Locations Were Included

The producer intentionally includes:

* Mumbai
* Lagos
* London
* New York

because future fraud rules will later incorporate:

```text
geographical risk analysis
```

This creates more realistic fraud-processing scenarios.

---

# Why Masked Card Numbers Matter

The producer intentionally avoids:

```text
full PCI-sensitive card data exposure
```

even though synthetic data is used.

This demonstrates:

# Security-Conscious Engineering

which is important in financial systems.

---

# Structured JSON Logging

This phase introduced:

# Production-Style Observability

Instead of:

```python
print("transaction sent")
```

the producer emits structured JSON logs.

---

# logger.py

```python
import json
import logging
import sys


class JsonFormatter(logging.Formatter):

    def format(self, record):
        log_record = {
            "level": record.levelname,
            "message": record.getMessage(),
            "logger": record.name,
            "timestamp": self.formatTime(record),
        }

        return json.dumps(log_record)


def get_logger(name: str) -> logging.Logger:

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

Structured logs improve:

* debugging
* observability
* monitoring
* log searchability
* CloudWatch analysis
* operational telemetry

This mirrors:

* Lambda logging
* container logging
* Kubernetes observability
* enterprise monitoring systems

---

# Why stdout Logging Matters

The producer intentionally logs to:

```text
stdout
```

because cloud-native infrastructure automatically captures stdout streams.

Examples:

| Platform   | Captures stdout |
| ---------- | --------------- |
| AWS Lambda | CloudWatch      |
| Docker     | Container logs  |
| Kubernetes | Pod logs        |
| ECS        | CloudWatch      |

---

# Runtime Configuration Management

The project intentionally separated configuration from application logic.

---

# config.py

```python
import os
from dotenv import load_dotenv

load_dotenv()


AWS_REGION = os.getenv("AWS_REGION", "us-east-1")

KINESIS_STREAM_NAME = os.getenv(
    "KINESIS_STREAM_NAME",
    "rtfd-dev-transaction-ingestion-kds"
)

TRANSACTION_INTERVAL_SECONDS = float(
    os.getenv("TRANSACTION_INTERVAL_SECONDS", "1")
)
```

---

# .env

```text
AWS_REGION=us-east-1
KINESIS_STREAM_NAME=rtfd-dev-transaction-ingestion-kds
TRANSACTION_INTERVAL_SECONDS=1
```

---

# Why Configuration Separation Matters

Production systems should NEVER hardcode:

* stream names
* regions
* credentials
* deployment values
* operational parameters

This improves:

* portability
* CI/CD flexibility
* multi-environment deployment
* operational scalability

---

# AWS SDK Kinesis Publishing Logic

This phase officially introduced:

# Real-Time Stream Publishing

using:

```text
boto3
```

and Amazon Kinesis Data Streams.

---

# producer.py

```python
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
```

---

# Why boto3 Matters

The producer now officially integrates with:

# AWS SDK For Python

using:

```python
boto3.client("kinesis")
```

This establishes:

```text
Application
        ↓
AWS SDK
        ↓
Kinesis API
        ↓
Distributed Streaming Infrastructure
```

---

# Partition-Key Engineering

One of the most important streaming-system concepts introduced during this phase was:

# Partition Key Strategy

The producer intentionally uses:

```python
PartitionKey=transaction.card_number
```

instead of transaction IDs.

---

# Why card_number Was Chosen

Kinesis guarantees ordering:

# PER Partition Key

Meaning:

```text
same card activity
        ↓
same shard ordering
```

This is useful for:

* fraud investigations
* transaction chronology
* replay consistency
* behavioral analysis

---

# Important Distributed Systems Concept Learned

Kinesis internally performs:

```text
Partition Key
      ↓
Hash Function
      ↓
Shard Assignment
```

This controls:

* ordering
* distribution
* throughput balancing
* shard utilization

---

# Continuous Streaming Loop

The producer now runs as:

# A Long-Running Streaming Service

using:

```python
while running:
```

This differs fundamentally from:

* batch ETL jobs
* cron jobs
* scheduled workflows

The producer continuously emits live transaction events.

---

# Graceful Shutdown Handling

The producer intentionally implemented:

```python
signal.signal()
```

This allows:

```bash
CTRL + C
```

to safely stop the application.

---

# Why Graceful Shutdown Matters

Production systems must safely handle:

* deployments
* restarts
* failures
* operational shutdowns
* scaling operations

Without graceful shutdown:

* partial writes occur
* inconsistent state appears
* operational reliability decreases

---

# Error Isolation

Publishing logic was intentionally wrapped inside:

```python
try:
```

This prevents:

```text
single publish failure
        ↓
entire producer crash
```

This introduces streaming fault isolation.

---

# Running The Producer

## Activate Virtual Environment

```bash
source venv/bin/activate
```

---

## Start Producer

```bash
python src/producer.py
```

---

# Example Structured Logs

```json
{
  "level": "INFO",
  "message": "{\"event\": \"transaction_published\", \"transaction_id\": \"bbb9aec5-ea73-421b-b98a-e8f3950f1627\", \"partition_key\": \"****-****-****-6161\"}",
  "logger": "__main__",
  "timestamp": "2026-05-18 20:08:21"
}
```

---

# Operational Validation In AWS

The streaming infrastructure was validated operationally using:

```text
AWS Console
    ↓
Kinesis
    ↓
Monitoring
```

Observed metrics included:

* IncomingRecords
* PutRecord.Success
* PutRecord.Latency
* Throughput

---

# What These Metrics Confirmed

| Metric            | Meaning                       |
| ----------------- | ----------------------------- |
| IncomingRecords   | Records entering stream       |
| PutRecord.Success | Successful AWS ingestion      |
| PutRecord.Latency | Low ingestion latency         |
| Throughput        | Live streaming traffic exists |

---

# Important Operational Understanding Learned

This phase introduced one of the most important cloud engineering principles:

# Application Logs + Infrastructure Telemetry

Real systems are operated using BOTH:

| Layer                | Visibility                 |
| -------------------- | -------------------------- |
| Application Layer    | Producer logs              |
| Infrastructure Layer | CloudWatch/Kinesis metrics |

This dual visibility is foundational in production operations.

---

# Current Producer Throughput

Current configuration intentionally emits:

```text
~1 transaction per second
```

This validates:

```text
1 shard is sufficient
```

for the current workload.

This reinforces an important engineering principle:

# Scale Based On Measured Workload

NOT hypothetical future traffic.

---

# Engineering Concepts Introduced In This Phase

This phase introduced several critical production-grade engineering concepts:

* event schema standardization
* streaming producer architecture
* structured application layering
* AWS SDK integration
* Kinesis publishing
* partition-key engineering
* ordered event streaming
* realistic workload simulation
* structured JSON logging
* graceful shutdown handling
* operational observability
* continuous stream processing
* runtime configuration management
* streaming telemetry analysis

---

# Engineering Outcome Of This Phase

At the completion of this phase:

✅ Real-time streaming producer exists
✅ Live Kinesis ingestion is operational
✅ AWS SDK integration is functional
✅ Structured event schemas are established
✅ Realistic transaction simulation exists
✅ Structured JSON observability is operational
✅ Partition-key architecture is functioning
✅ Continuous streaming behavior is active
✅ Graceful shutdown handling is implemented
✅ Operational Kinesis telemetry is validated
✅ Production-style streaming producer architecture exists

The platform now officially supports:

* continuous real-time ingestion
* distributed event streaming
* ordered partitioned event flow
* operational telemetry
* and cloud-native streaming infrastructure.

---

# Next Phase

# Phase 5 — Lambda Fraud Processing Engine

This phase will introduce:

* Lambda event source mappings
* stream batch processing
* fraud rule evaluation
* event enrichment
* DynamoDB operational writes
* S3 archival
* Lambda observability
* retry behavior
* partial failure handling
* and real-time fraud-processing workflows

The platform will evolve from:

```text
Streaming Infrastructure
```

into:

# A Real-Time Fraud Detection Platform
