# Phase 1 — Engineering Foundation & Repository Design

## Project

Real-Time Fraud Detection Platform

## Objective of This Phase

The objective of this phase is to establish the engineering foundation of the project before deploying any AWS infrastructure.

This phase focuses on:

* repository organization,
* engineering standards,
* naming conventions,
* local development setup,
* environment isolation,
* dependency management,
* and future CI/CD readiness.

This mirrors how production-grade financial data platforms are initialized in enterprise environments.

---

# Engineering Philosophy

This project is intentionally designed as a:

* governed,
* production-style,
* event-driven,
* serverless,
* real-time fraud detection platform.

The implementation approach prioritizes:

* reproducibility,
* operational clarity,
* maintainability,
* observability,
* Infrastructure as Code,
* and deployment discipline.

The project is not being developed as a tutorial-style AWS demo.

The goal is to simulate real engineering practices used in regulated financial environments.

---

# Local Development Environment

## Operating Environment

| Component               | Value              |
| ----------------------- | ------------------ |
| Host OS                 | Windows            |
| Development Environment | Ubuntu WSL         |
| Cloud Provider          | AWS                |
| Version Control         | Git + GitHub       |
| CLI Configuration       | AWS CLI Configured |

---

# Repository Initialization

## Git Initialization

The repository was initialized locally using:

```bash
git init
```

The repository was connected to GitHub and the initial README was pushed successfully.

This establishes:

* source control,
* collaboration readiness,
* version tracking,
* and CI/CD compatibility.

---

# Repository Structure

The project repository follows a domain-oriented engineering structure.

```text
realtime_fraud_detection_platform/
│
├── README.md
├── .gitignore
├── requirements.txt
│
├── docs/
│   ├── architecture/
│   ├── implementation-roadmap/
│   ├── runbooks/
│   └── diagrams/
│
├── infrastructure/
│   ├── terraform/
│   │   ├── environments/
│   │   │   ├── dev/
│   │   │   ├── stage/
│   │   │   └── prod/
│   │   │
│   │   ├── modules/
│   │   │   ├── kinesis/
│   │   │   ├── lambda/
│   │   │   ├── dynamodb/
│   │   │   ├── s3/
│   │   │   ├── iam/
│   │   │   ├── kms/
│   │   │   ├── monitoring/
│   │   │   ├── glue/
│   │   │   ├── athena/
│   │   │   ├── eventbridge/
│   │   │   └── stepfunctions/
│   │   │
│   │   ├── backend/
│   │   └── global/
│   │
│   └── README.md
│
├── applications/
│   ├── producer/
│   │   ├── src/
│   │   └── tests/
│   │
│   ├── fraud_processor_lambda/
│   │   ├── src/
│   │   └── tests/
│   │
│   └── workflow_handlers/
│
├── analytics/
│   ├── athena_queries/
│   ├── dashboards/
│   └── schemas/
│
├── governance/
│   ├── iam-policies/
│   ├── kms-policies/
│   ├── data-classification/
│   └── compliance-notes/
│
├── scripts/
├── tests/
│
└── .github/
    └── workflows/
```

---

# Why This Structure Matters

The repository is intentionally separated into multiple engineering domains.

## Documentation Layer

The `docs/` directory stores:

* architecture documents,
* implementation roadmaps,
* operational runbooks,
* and architecture diagrams.

This supports:

* operational maturity,
* onboarding,
* auditability,
* and engineering communication.

---

## Infrastructure Layer

The `infrastructure/terraform/` directory isolates all Infrastructure as Code.

The structure supports:

* reusable Terraform modules,
* environment isolation,
* remote state management,
* and CI/CD deployments.

The environment structure includes:

* dev,
* stage,
* prod.

This mirrors real enterprise deployment workflows.

---

## Application Layer

The `applications/` directory separates executable business logic.

Current applications include:

| Application            | Purpose                                   |
| ---------------------- | ----------------------------------------- |
| producer               | Simulates upstream transaction generation |
| fraud_processor_lambda | Real-time fraud processing engine         |
| workflow_handlers      | Event-driven orchestration workflows      |

Each application maintains:

* source code,
* tests,
* isolated dependencies,
* and future container compatibility.

---

## Analytics Layer

The `analytics/` directory stores:

* Athena queries,
* dashboard assets,
* analytical schemas,
* and reporting artifacts.

This separates analytical workloads from operational workloads.

---

## Governance Layer

The `governance/` directory centralizes:

* IAM policy references,
* KMS policy design,
* compliance notes,
* and data-classification standards.

This reinforces governance-first engineering.

---

# Naming Convention Strategy

A production-grade naming strategy was established early in the project lifecycle.

The objective is to ensure:

* operational clarity,
* scalability,
* environment awareness,
* and searchability.

---

## Project Identifier

The official project short-name is:

```text
rtfd
```

Meaning:

```text
Real-Time Fraud Detection
```

This prefix will be applied consistently across AWS resources.

---

# Standard Resource Naming Format

```text
<project>-<environment>-<resource-purpose>-<service>
```

Example:

```text
rtfd-dev-transaction-ingestion-kds
```

---

# Naming Examples

| Resource Type   | Example                            |
| --------------- | ---------------------------------- |
| Kinesis Stream  | rtfd-dev-transaction-ingestion-kds |
| Lambda Function | rtfd-dev-fraud-processor-lambda    |
| DynamoDB Table  | rtfd-dev-fraud-alerts-ddb          |
| S3 Bucket       | rtfd-dev-raw-archive-123456789012  |
| KMS Key         | rtfd-dev-core-kms                  |
| IAM Role        | rtfd-dev-fraud-processor-role      |

---

# Naming Standards

## Use Lowercase

All resource names use lowercase wherever AWS permits.

---

## Use Hyphens

Hyphens are preferred over underscores for AWS-native readability.

Correct:

```text
rtfd-dev-fraud-processor-lambda
```

Incorrect:

```text
rtfd_dev_fraud_processor_lambda
```

---

## Include Business Context

Resource names must describe business responsibility clearly.

Avoid vague names such as:

* lambda1
* test-bucket
* fraud-stream

Prefer descriptive names such as:

* transaction-ingestion
* fraud-processor
* fraud-alerts
* workflow-router

---

# Python Development Environment

## Virtual Environment

A dedicated Python virtual environment was created:

```bash
python3 -m venv venv
```

The environment is activated using:

```bash
source venv/bin/activate
```

This isolates project dependencies from the host system.

---

# Development Dependencies

The following foundational engineering dependencies were installed:

| Package       | Purpose                         |
| ------------- | ------------------------------- |
| boto3         | AWS SDK                         |
| pytest        | Testing framework               |
| black         | Code formatting                 |
| flake8        | Linting                         |
| isort         | Import sorting                  |
| python-dotenv | Environment variable management |

Dependencies were frozen into:

```text
requirements.txt
```

using:

```bash
pip freeze > requirements.txt
```

This supports:

* reproducibility,
* CI/CD,
* Lambda packaging,
* and deterministic deployments.

---

# Git Ignore Strategy

A production-oriented `.gitignore` was created.

Ignored assets include:

* virtual environments,
* Terraform state files,
* local IDE metadata,
* logs,
* Python cache artifacts,
* and environment variable files.

This prevents accidental leakage of:

* credentials,
* local state,
* and unnecessary artifacts.

---

# Engineering Outcome of Phase 1

At the completion of this phase:

* repository structure exists,
* engineering standards are defined,
* naming conventions are established,
* development tooling is configured,
* dependency management is initialized,
* and the project is prepared for Infrastructure as Code implementation.

The platform now has a scalable engineering foundation suitable for:

* Terraform deployment,
* CI/CD integration,
* multi-environment infrastructure,
* and production-style cloud engineering workflows.

---

# Next Phase

Phase 2 will establish the Terraform foundation of the platform.

This includes:

* Terraform installation and version pinning,
* remote backend architecture,
* reusable module design,
* provider configuration,
* environment variable management,
* and Infrastructure as Code initialization.
