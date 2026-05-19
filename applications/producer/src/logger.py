import json
import logging
import sys





class JsonFormatter(logging.Formatter):
    """
    Custom JSON log formatter for structured logging.
    """

    def format(self, record):
        log_record = {
            "level": record.levelname,
            "message": record.getMessage(),
            "logger": record.name,
            "timestamp": self.formatTime(record),
        }

        return json.dumps(log_record)


def get_logger(name: str) -> logging.Logger:
    """
    Create structured JSON logger.
    """

    logger = logging.getLogger(name)

    logger.setLevel(logging.INFO)

    if not logger.handlers:

        handler = logging.StreamHandler(sys.stdout)

        handler.setFormatter(JsonFormatter())

        logger.addHandler(handler)

    return logger


