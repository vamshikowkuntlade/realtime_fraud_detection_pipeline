"""
===============================================================================
Structured JSON Logging Layer
===============================================================================

Production systems rely heavily on logs for:

- debugging
- monitoring
- observability
- operational investigations
- CloudWatch analysis
- alerting

Instead of using raw print() statements,
we emit machine-readable JSON logs.

This mirrors:
- Lambda production logging
- Kubernetes logging
- container observability
- enterprise monitoring systems
"""

import json
import logging
import sys


class JsonFormatter(logging.Formatter):

    """
    Custom formatter that converts logs into structured JSON.

    Example output:

    {
        "level": "INFO",
        "message": "transaction processed",
        "timestamp": "...",
        "logger": "__main__"
    }
    """

    def format(self, record):

        log_record = {

            # INFO / ERROR / WARNING
            "level": record.levelname,

            # Actual log message
            "message": record.getMessage(),

            # Timestamp automatically generated
            "timestamp": self.formatTime(record),

            # Logger name
            "logger": record.name,
        }

        return json.dumps(log_record)


def get_logger(name: str):

    """
    Creates reusable application logger.

    Logging is sent to stdout because:
    AWS Lambda automatically captures stdout
    into CloudWatch Logs.
    """

    logger = logging.getLogger(name)

    logger.setLevel(logging.INFO)

    # Prevent duplicate handlers during Lambda warm starts.
    if not logger.handlers:

        handler = logging.StreamHandler(sys.stdout)

        handler.setFormatter(JsonFormatter())

        logger.addHandler(handler)

    return logger