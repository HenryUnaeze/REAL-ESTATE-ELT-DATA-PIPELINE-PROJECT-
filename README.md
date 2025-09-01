# Company Overview 
Zipco Real Estate Agency operates in the fast-paced and competitive world of real estate, where timely access to accurate information is crucial for success. 
Our success factors likely include a strong understanding of local market dynamics and effective marketing strategies.

## Empowering Data-Driven Growth
In the competitive real estate market, timely access to precise information is paramount for success. 
This project is critical for Zipco Real Estate to overcome current data challenges, reinforce its market position, and drive sustained growth.

### Enhanced Decision-Making
-Provide agents and management with rapid access to accurate market insights, enabling agile and informed strategic choices.
### Operational Efficiency
-Streamline data workflows, reduce manual processing, and free up valuable resources for core real estate activities.
### Strengthened Client Service
-Leverage technology to support exceptional customer service and maintain a robust online presence, attracting and retaining leads.
# Key Challenges
### Inefficient Data Workflow
-Cumbersome data processing leads to delays in accessing critical property information and diverts resources to manual tasks.
### Disparate Data Formats
-Inconsistent datasets complicate analysis and reporting, hindering actionable insights for agents and management.
### Compromised Data Quality
-The lack of a streamlined process results in inaccuracies and outdated information, impacting

# Project Rationale
### Enhanced Operational Efficiency
-Automates data processing, significantly reducing the time and effort required to gather, clean, and prepare data.
### Improved Data Quality & Consistency
-Standardizes data formats and ensures accurate integration, leading to reliable, up-to-date information for informed decisions.
### Timely Access to Critical Information
-Enables real-time access to vital property insights and market data, essential for rapid decision-making in a fast-paced environment.
### Cost Reduction
-Minimizes manual data handling and errors, resulting in significant operational cost savings that can be reinvested into growth initiatives.
### Enhanced Decision-Making
Empowers management with accurate insights and analytics, enabling more strategic decisions and effective navigation of the real estate market.

# Strategic Project Objectives

This project focuses on four strategic objectives, each vital for enhancing data efficiency and reliability at Zico Real Estate, laying the groundwork for a more robust and data-driven operation.

## Automated ETL Pipeline
Develop a scalable, automated ETL pipeline with built-in logging and monitoring for consistent data flow and performance tracking.
## Data Cleaning & Transformation
Implement robust cleaning and transformation procedures to ensure data accuracy, consistency, and readiness for analysis and reporting.
## Efficient Data Extraction
Utilize a Python-based solution to efficiently fetch and retrieve property records from the Real Estate API, minimizing delays.
## Optimized Database Loading
Design an optimized process for efficiently inserting transformed data into the PostgreSQL database, ensuring data integrity.
# Project Scope 
![alt text](https://github.com/HenryUnaeze/REAL-ESTATE-ELT-DATA-PIPLINE-PROJECT-/blob/main/Project%20Scope.png)
# Analytical Insights
![alt text](https://github.com/HenryUnaeze/REAL-ESTATE-ELT-DATA-PIPLINE-PROJECT-/blob/main/Analytics%20Insight%20.png)
# Pipeline Architecture 
![alt text](https://github.com/HenryUnaeze/REAL-ESTATE-ELT-DATA-PIPLINE-PROJECT-/blob/main/Data%20Architecture.png)

# Data Extraction 

## Executing the Data Pipeline
Our robust ETL (Extract, Transform, Load) pipeline is the core mechanism for acquiring, processing, and integrating real estate data. Built with Python, it ensures data is consistently updated, cleaned, and made available for analysis within the PostgreSQL database.

Below is the Python script that orchestrates the entire ETL workflow, from API extraction to database loading.

`  ## PYTHON CODE FOR ETL ON REAL ESTATE

import os
import sys
import logging
import traceback
import pandas as pd
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
    

    df=extract_data(url)
    df.head()

##--- LOADING RAW DATA INTO THE DATA BASE
   engine = create_engine(f'postgresql+psycopg2://{user_name}:{password}@{host}:{port}/{db_name}')

try:
    conn = psycopg2.connect(
        host=host,
        database=db_name,
        user=user_name,
        password=password,
        port=port
    )
    print("Connection successful")
except Exception as e:
    print("Connection was unsuccessful:", e)

Connection successful

cur=conn.cursor()

df.to_sql('raw_listings', con=engine, if_exists='replace', index=False,method="multi")

conn.commit()

Total_list =list(df.columns)

def transform_data(df):
    listing_data_cleaned = df[['id', 'formattedAddress', 'city',
       'state', 'zipCode', 'county', 'latitude', 'longitude', 'propertyType',
       'bedrooms', 'bathrooms', 'squareFootage', 'lotSize', 'yearBuilt',
       'status', 'price', 'listingType', 'listedDate', 'removedDate',
       'createdDate', 'lastSeenDate', 'daysOnMarket', 'mlsName', 'mlsNumber',
       'listingAgent.name', 'listingAgent.phone', 'listingAgent.email',
       'listingAgent.website', 'listingOffice.name', 'listingOffice.phone',
       'listingOffice.email', 'listingOffice.website']].copy()
    listing_data_cleaned.rename(columns={
        'formattedAddress': 'full_address','zipCode': 'postal_code'}, inplace=True
        )
    listing_data_cleaned.columns= (
        listing_data_cleaned.columns
        .str.strip()
        .str.replace(r'([A-Z])', r'_\1', regex=True)
        .str.replace(" ", "_")
        .str.replace(r'[^0-9a-zA-Z_]', r'_', regex=True)
        .str.lower()
        .str.replace('__', '_')
        .str.strip('_')
        )
    return listing_data_cleaned

listing_data_cleaned = transform_data(df)


## TRANSFORMED DATA TO BE LOADED TO THE DATABASE

engine = create_engine(f"postgresql+psycopg2://{user_name}:{password}@{host}:{port}/{db_name}")

listing_data_cleaned.to_sql('transformed_listings', con=engine, if_exists='replace', index=False, method="multi")

cur=conn.cursor()
conn.commit()


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
    ` 








