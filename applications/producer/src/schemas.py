from dataclasses import dataclass, asdict
from datetime import datetime
from typing import Dict
import uuid


@dataclass
class TransactionEvent:
    """
    Represents a single banking transaction event.

    This schema acts as the standardized event contract
    shared across the streaming platform.
    """

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
        """
        Convert dataclass into dictionary format
        for JSON serialization and Kinesis publishing.
        """
        return asdict(self)


def generate_transaction_id() -> str:
    """
    Generate globally unique transaction identifier.
    """
    return str(uuid.uuid4())


def generate_timestamp() -> str:
    """
    Generate ISO-8601 UTC timestamp.
    """
    return datetime.utcnow().isoformat()