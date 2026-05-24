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
    """
    Generate masked card number.
    """
    return f"****-****-****-{random.randint(1000, 9999)}"


def generate_transaction_amount() -> float:
    """
    Generate realistic transaction amount.

    Most transactions remain relatively small,
    while occasional large transactions appear.
    """

    weighted_ranges = [
        random.uniform(5, 100),
        random.uniform(100, 500),
        random.uniform(500, 5000),
    ]

    weights = [0.7, 0.25, 0.05]

    return round(random.choices(weighted_ranges, weights=weights)[0], 2)


def generate_transaction_event() -> TransactionEvent:
    """
    Generate realistic banking transaction event.
    """

    return TransactionEvent(
        transaction_id=generate_transaction_id(),
        card_number=generate_card_number(),
        merchant_id=f"MER-{random.randint(10000, 99999)}",
        merchant_category=random.choice(MERCHANT_CATEGORIES),
        transaction_amount=generate_transaction_amount(),
        #transaction_amount="INVALID",   for testing by pushing bad events
        currency="CAD",
        transaction_timestamp=generate_timestamp(),
        location=random.choice(LOCATIONS),
        payment_method=random.choice(PAYMENT_METHODS),
    )