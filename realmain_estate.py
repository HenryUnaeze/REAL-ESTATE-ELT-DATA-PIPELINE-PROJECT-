## PYTHON CODE FOR ETL ON REAL ESTATE

import os
import sys
import logging
import traceback
import requests
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

# --------------------------
# Setup
# --------------------------
load_dotenv()

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
LOG_PATH = os.path.join(BASE_DIR, "etl.log")

logging.basicConfig(
    filename=LOG_PATH,
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s"
)

# Configs from .env
url = "https://api.rentcast.io/v1/listings/sale?limit=150"
api_key = os.getenv("API_KEY")
db_name = os.getenv("DB_NAME")
db_user = os.getenv("USER")
db_pass = os.getenv("DB_PASSWORD")
db_host = os.getenv("DB_HOST")
db_port = os.getenv("PORT")

headers = {
    "Accept": "application/json",
    "X-Api-Key": api_key
}

# SQLAlchemy engine
engine = create_engine(
    f"postgresql+psycopg2://{db_user}:{db_pass}@{db_host}:{db_port}/{db_name}"
)


# --------------------------
# ETL Functions
# --------------------------
def extract_data(url):
    """Fetch JSON from API and return DataFrame."""
    logging.info("Extracting data from API...")
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        data = response.json()
        df = pd.json_normalize(data)
        logging.info("Extract success: %s rows", len(df))
        return df
    else:
        raise Exception(f"Error fetching data: {response.status_code} - {response.text}")


def transform_data(df):
    """Clean and standardize dataframe."""
    logging.info("Transforming data...")
    listing_data_cleaned = df[[
        'id', 'formattedAddress', 'city', 'state', 'zipCode', 'county',
        'latitude', 'longitude', 'propertyType', 'bedrooms', 'bathrooms',
        'squareFootage', 'lotSize', 'yearBuilt', 'status', 'price',
        'listingType', 'listedDate', 'removedDate', 'createdDate',
        'lastSeenDate', 'daysOnMarket', 'mlsName', 'mlsNumber',
        'listingAgent.name', 'listingAgent.phone', 'listingAgent.email',
        'listingAgent.website', 'listingOffice.name', 'listingOffice.phone',
        'listingOffice.email', 'listingOffice.website'
    ]].copy()

    listing_data_cleaned.rename(columns={
        'formattedAddress': 'full_address',
        'zipCode': 'postal_code'
    }, inplace=True)

    # Normalize column names
    listing_data_cleaned.columns = (
        listing_data_cleaned.columns
        .str.strip()
        .str.replace(r'([A-Z])', r'_\1', regex=True)
        .str.replace(" ", "_")
        .str.replace(r'[^0-9a-zA-Z_]', r'_', regex=True)
        .str.lower()
        .str.replace('__', '_')
        .str.strip('_')
    )

    logging.info("Transform success: %s rows", len(listing_data_cleaned))
    return listing_data_cleaned


# --------------------------
# Main ETL Runner
# --------------------------
def main() -> int:
    logging.info("ETL start")
    try:
        df = extract_data(url)
        df.to_sql("raw_listings", engine, if_exists="replace", index=False, method="multi")

        df_clean = transform_data(df)
        df_clean.to_sql("transformed_listings", engine, if_exists="replace", index=False, method="multi")

        logging.info("Rows: raw=%s clean=%s", len(df), len(df_clean))
        logging.info("ETL success")
        return 0
    except Exception:
        logging.error("ETL failed\n%s", traceback.format_exc())
        return 1


if __name__ == "__main__":
    sys.exit(main())


conn.close()
engine.dispose()
