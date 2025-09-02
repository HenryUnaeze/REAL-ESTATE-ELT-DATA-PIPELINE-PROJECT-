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

``` python 
## PYTHON CODE FOR ETL ON REAL ESTATE

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
``` 
# Secure Data Loading to PostgreSQL
# Data Pipeline Overview

| Step                          | Description                                                                                                                                           |
|-------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Raw Data Archiving**        | The initial, unprocessed data from the **RentCast API** is loaded into a dedicated `raw_listings` table, ensuring a complete and unaltered record for historical purposes and auditing. |
| **Transformed Data Integration** | The cleaned, standardized, and enriched real estate data is integrated into the `transformed_listings` table, optimized for direct use by Zico Real Estate's analytical platforms. |
| **Robust Connection Management** | The system uses **SQLAlchemy** and **psycopg2** to establish and manage reliable connections to PostgreSQL, with connection pooling and disposal for optimal performance. |
| **Guaranteed Data Integrity** | Data handling processes ensure consistency, accuracy, and reliability across all stages of the pipeline.                                             |


![Alt Text](https://github.com/HenryUnaeze/REAL-ESTATE-ELT-DATA-PIPLINE-PROJECT-/blob/main/Data%20Loading%20in%20Postgres.png)

# Optimized Data Model for Analytics
Following successful data loading, our focus shifts to structuring the transformed data for optimal query performance, enabling rapid insights and powerful analytical capabilities for Zico Real Estate.
![Alt Text](https://github.com/HenryUnaeze/REAL-ESTATE-ELT-DATA-PIPLINE-PROJECT-/blob/main/Primary%20and%20Secondary.png)
![Alt Text](https://github.com/HenryUnaeze/REAL-ESTATE-ELT-DATA-PIPLINE-PROJECT-/blob/main/Real_Estate%20Data%20Modellin%20g-Page-1.drawio.png)

# Fact and Dimension Tables for Real Estate Analytics
To enable robust and flexible analytical capabilities for Zico Real Estate, we've implemented a star schema data model, separating core metrics from descriptive attributes into fact and dimension tables.
### Star Schema Design
Optimized for analytical queries, the star schema simplifies data retrieval and enhances performance for reporting.
### Central Fact Table
The `property_listings` fact table stores key metrics like price, status, and dates, with foreign keys linking to dimensions.
### Detailed Dimensions
Dedicated dimension tables for Address, Property Location, Property Details, Office, and Agent provide rich descriptive context.
![Alt Text](https://github.com/HenryUnaeze/REAL-ESTATE-ELT-DATA-PIPLINE-PROJECT-/blob/main/Star%20Schema.png)

# SQL Schema: Real Estate Data Warehouse
1. Dimension Tables First (`property_listings`)
2. Fact Table Foundation
3. Indexing for Performance
```sql
---## FACT AND DIMENSION TABLES FOR REAL ESTATE COMPANY 

--- Dim Table (Address)
CREATE TABLE IF NOT EXISTS address(
    address_id BIGSERIAL PRIMARY KEY,
    state TEXT NOT NULL,
    county TEXT NOT NULL,
    city TEXT NOT NULL,
    postal_code TEXT NOT NULL,
    UNIQUE (state, county, city, postal_code)
);

--- Dim Table (Property_Location)
CREATE TABLE IF NOT EXISTS property_location (
    location_id BIGSERIAL PRIMARY KEY,
    bedroom INT NOT NULL,
    bathroom NUMERIC NOT NULL,
    square_footage NUMERIC NOT NULL,
    address_id BIGINT NOT NULL,
    property_type TEXT NOT NULL,
    property_id BIGINT NOT NULL,
    FOREIGN KEY (address_id) REFERENCES address(address_id),
    FOREIGN KEY (property_id) REFERENCES property(property_id),
    UNIQUE (bedroom, bathroom, square_footage, address_id, property_type, property_id)
);

--- Dim Table (Property)
CREATE TABLE IF NOT EXISTS property(
    property_id BIGSERIAL PRIMARY KEY,
    year_built INTEGER,
    lot_size NUMERIC,
    UNIQUE (year_built, lot_size)
);

--- Dim Table (Office)
CREATE TABLE IF NOT EXISTS office (
    office_id BIGSERIAL PRIMARY KEY,
    office_name TEXT NOT NULL,
    office_phone TEXT,
    office_email TEXT,
    office_website TEXT,
    address_id BIGINT NOT NULL,
    location_id BIGINT NOT NULL,
    FOREIGN KEY (address_id) REFERENCES address(address_id),
    FOREIGN KEY (location_id) REFERENCES property_location(location_id),
    UNIQUE (office_name, office_phone, office_email, office_website)
);

--- Dim Table (Agent)
CREATE TABLE IF NOT EXISTS agent (
    agent_id BIGSERIAL PRIMARY KEY,
    listing_agent_name TEXT NOT NULL,
    listing_agent_phone TEXT NOT NULL,
    listing_agent_email TEXT,
    mls_name TEXT NOT NULL,
    mls_number TEXT NOT NULL,
    listing_agent_website TEXT,
    UNIQUE (listing_agent_name, listing_agent_phone, listing_agent_email, mls_name, mls_number, listing_agent_website)
);

--- Fact Table (Property_Listings)
CREATE TABLE IF NOT EXISTS property_listings (
    listing_id BIGSERIAL PRIMARY KEY,
    price NUMERIC,
    status TEXT NOT NULL,
    created_date DATE,
    last_seen_date DATE,
    days_on_market INTEGER,
    removed_date DATE,
    listing_date DATE,
    listing_type TEXT NOT NULL,
    address_id BIGINT NOT NULL,
    location_id BIGINT NOT NULL,
    property_id BIGINT NOT NULL,
    office_id BIGINT NOT NULL,
    agent_id BIGINT NOT NULL,
    FOREIGN KEY (address_id) REFERENCES address(address_id),
    FOREIGN KEY (location_id) REFERENCES property_location(location_id),
    FOREIGN KEY (property_id) REFERENCES property(property_id),
    FOREIGN KEY (office_id) REFERENCES office(office_id),
    FOREIGN KEY (agent_id) REFERENCES agent(agent_id),
    UNIQUE (
        price,
        status,
        created_date,
        last_seen_date,
        days_on_market,
        removed_date,
        listing_date,
        listing_type,
        address_id,
        location_id,
        property_id,
        office_id,
        agent_id
    )
);

ALTER TABLE property_listings
    ALTER COLUMN created_date TYPE TEXT USING created_date::TEXT,
    ALTER COLUMN last_seen_date TYPE TEXT USING last_seen_date::TEXT,
    ALTER COLUMN removed_date TYPE TEXT USING removed_date::TEXT,
    ALTER COLUMN listing_date TYPE TEXT USING listing_date::TEXT;



--- Create indexes on fact table
CREATE INDEX IF NOT EXISTS ix_fact_ploc ON property_listings(location_id);
CREATE INDEX IF NOT EXISTS ix_fact_off ON property_listings(office_id);
CREATE INDEX IF NOT EXISTS ix_fact_prop ON property_listings(property_id);
CREATE INDEX IF NOT EXISTS ix_fact_a ON property_listings(agent_id);
CREATE INDEX IF NOT EXISTS ix_fact_addr ON property_listings(address_id);

 ```

# Data Ingestion: Populating the Data Warehouse
```sql
---## INSERTING DATA FROM TRANSFORMED_LISTINGS TABLE 

-- Address dimension
insert into address(state, county, city, postal_code)
select distinct
    trim(state),
    trim(county),
    trim(city),
    trim(postal_code)
from transformed_listings
where state is not null
  and county is not null
  and city is not null
  and postal_code is not null
on conflict (state, county, city, postal_code)
do nothing;

-- Property dimension
insert into property(year_built, lot_size)
select distinct
    year_built,
    lot_size
from transformed_listings
where year_built is not null
  and lot_size is not null
on conflict (year_built, lot_size)
do nothing;

--property_location dimension
insert into property_location(
    bedroom,
    bathroom,
    square_footage,
    address_id,
    property_type,
    property_id
)
select distinct
    l.bedrooms,
    l.bathrooms,
    l.square_footage,
    a.address_id,
    l.property_type,
    p.property_id
from transformed_listings l
join address a
    on trim(lower(a.state)) = trim(lower(l.state))
   and trim(lower(a.county)) = trim(lower(l.county))
   and trim(lower(a.city)) = trim(lower(l.city))
   and trim(lower(a.postal_code::text)) = trim(lower(l.postal_code::text))
join property p
    on p.year_built = l.year_built
   and p.lot_size = l.lot_size
where l.bedrooms is not null
  and l.bathrooms is not null
  and l.square_footage is not null
on conflict (bedroom, bathroom, square_footage, address_id, property_type, property_id)
do nothing;

-- Office dimension
insert into office(
    office_name,
    office_phone,
    office_email,
    office_website,
    address_id,
    location_id
)
select distinct
    l.listing_office_name,
    l.listing_office_phone,
    l.listing_office_email,
    l.listing_office_website,
    a.address_id,
    pl.location_id
from transformed_listings l
join address a
    on trim(lower(a.state)) = trim(lower(l.state))
   and trim(lower(a.county)) = trim(lower(l.county))
   and trim(lower(a.city)) = trim(lower(l.city))
   and trim(lower(a.postal_code::text)) = trim(lower(l.postal_code::text))
join property_location pl
    on pl.bedroom = l.bedrooms
   and pl.bathroom = l.bathrooms
   and pl.square_footage = l.square_footage
   and pl.address_id = a.address_id
   and pl.property_type = l.property_type
where l.listing_office_name is not null
on conflict (office_name, office_phone, office_email, office_website)
do nothing;

-- Agent dimension
insert into agent(
    listing_agent_name,
    listing_agent_phone,
    listing_agent_email,
    mls_name,
    mls_number,
    listing_agent_website
)
select distinct
    l.listing_agent_name,
    coalesce(l.listing_agent_phone, 'N/A') as listing_agent_phone,
    l.listing_agent_email,
    l.mls_name,
    l.mls_number,
    l.listing_agent_website
from transformed_listings l
where l.listing_agent_name is not null
  and l.mls_name is not null
  and l.mls_number is not null
on conflict (
    listing_agent_name,
    listing_agent_phone,
    listing_agent_email,
    mls_name,
    mls_number,
    listing_agent_website
)
do nothing;

-- Fact table: property_listings
insert into property_listings(
    price,
    status,
    created_date,
    last_seen_date,
    days_on_market,
    removed_date,
    listing_date,
    listing_type,
    address_id,
    location_id,
    property_id,
    office_id,
    agent_id
)
select
    l.price,
    l.status,
    l.created_date::text,     -- convert date to text if needed
    l.last_seen_date::text,
    l.days_on_market,
    l.removed_date::text,
    l.listed_date::text,
    l.listing_type,
    a.address_id,
    pl.location_id,
    p.property_id,
    o.office_id,
    ag.agent_id
from transformed_listings l
join address a
    on trim(lower(a.state)) = trim(lower(l.state))
   and trim(lower(a.county)) = trim(lower(l.county))
   and trim(lower(a.city)) = trim(lower(l.city))
   and trim(lower(a.postal_code::text)) = trim(lower(l.postal_code::text))
join property_location pl
    on pl.bedroom = l.bedrooms
   and pl.bathroom = l.bathrooms
   and pl.square_footage = l.square_footage
   and pl.address_id = a.address_id
   and pl.property_type = l.property_type
join property p
    on p.year_built = l.year_built
   and p.lot_size = l.lot_size
join office o
    on o.office_name = l.listing_office_name
   and coalesce(o.office_phone,'') = coalesce(l.listing_office_phone,'')
   and o.address_id = a.address_id
   and o.location_id = pl.location_id
join agent ag
    on ag.listing_agent_name = l.listing_agent_name
   and ag.listing_agent_phone = l.listing_agent_phone
   and coalesce(ag.listing_agent_email,'') = coalesce(l.listing_agent_email,'')
   and ag.mls_name = l.mls_name
   and ag.mls_number = l.mls_number
on conflict do nothing;
```
## SQL in Action: Real Estate Business Intelligence
```sql
----1. Stored Procedures: Get properties by city & price, update property status.

SELECT 
    a.city,
    ploc.property_type,
    pl.price,
    pl.status,
    pl.listing_id
FROM property_listings pl
JOIN property_location ploc
    ON ploc.location_id = pl.location_id
JOIN address a
    ON ploc.address_id = a.address_id
WHERE a.city = 'Phoenix'         
  AND pl.price BETWEEN 300000 AND 600000  
ORDER BY pl.price;



-----How many property listings exist in each city for each property type?
SELECT 
    a.city, 
    ploc.property_type, 
    COUNT(pl.listing_id) AS total_listings
FROM property_listings pl 
JOIN address a
    ON pl.address_id = a.address_id
JOIN property_location ploc
    ON pl.location_id = ploc.location_id
GROUP BY a.city, ploc.property_type
ORDER BY total_listings desc;


--Which real estate offices have the most listings in each city?

SELECT city, office_name, total_listings
FROM (
    SELECT 
        a.city,
        o.office_name,
        COUNT(pl.listing_id) AS total_listings,
        ROW_NUMBER() OVER (PARTITION BY a.city ORDER BY COUNT(pl.listing_id) DESC) AS rn
    FROM property_listings pl
    JOIN office o
        ON pl.office_id = o.office_id
    JOIN address a
        ON o.address_id = a.address_id
    GROUP BY a.city, o.office_name
) ranked
WHERE rn = 1
ORDER BY city;


----Find top 5 most expensive properties per city
SELECT *
FROM (
    SELECT 
        a.city,
        pl.listing_id,
        ploc.property_type,
        pl.price,
        ROW_NUMBER() OVER (PARTITION BY a.city ORDER BY pl.price DESC) AS rank_in_city
    FROM property_listings pl
    JOIN property_location ploc
        ON pl.location_id = ploc.location_id
    JOIN address a
        ON pl.address_id = a.address_id
) ranked
WHERE rank_in_city <= 5
ORDER BY city, price DESC;

----  Identify agents selling above average.

SELECT 
    ag.listing_agent_name,
    COUNT(pl.listing_id) AS total_listings,
    AVG(pl.price) AS avg_agent_price
FROM property_listings pl
JOIN agent ag
    ON ag.agent_id = pl.agent_id
GROUP BY ag.listing_agent_name
HAVING AVG(pl.price) > (
    SELECT AVG(price) FROM property_listings
)
ORDER BY avg_agent_price DESC;


----Joins: Link property listings with agent details.

SELECT 
    pl.listing_id,
    pl.price,
    pl.status,
    pl.listing_type,
    a.city,
    ag.listing_agent_name,
    ag.listing_agent_phone,
    ag.listing_agent_email,
    ag.mls_name,
    ag.mls_number
FROM property_listings pl
JOIN agent ag
    ON pl.agent_id = ag.agent_id
JOIN address a
    ON pl.address_id = a.address_id
ORDER BY a.city, pl.price DESC;


```

# Visualizing Insights: Power BI Dashboard
Our comprehensive data warehouse and optimized SQL queries culminate in dynamic Power BI dashboards, transforming raw data into intuitive, interactive visualizations. These dashboards provide a single source of truth for all real estate analytics, enabling stakeholders to explore market trends, evaluate agent performance, and identify key opportunities with ease.
![Alt Text](https://github.com/HenryUnaeze/REAL-ESTATE-ELT-DATA-PIPLINE-PROJECT-/blob/main/Visual%20Insight%20on%20PowerBi%20.png)
This visual interface empowers Zico Real Estate to make data-driven decisions swiftly, understand market dynamics at a glance, and monitor operational efficiency in real-time, ultimately enhancing strategic planning and competitive advantage.

# Marketing Intelligence – Executive Summary

| Segment                          | Insight                                                                                                                                      | Opportunity                                                                                                                         |
|----------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| **Scottsdale: The Premium Market** | Scottsdale exhibits the highest average property prices, driven by luxury single-family homes, with listings up to **$7.7M**.               | Target high-net-worth clients with tailored luxury marketing campaigns and specialized sales approaches for this segment.           |
| **Phoenix: Volume & Accessibility** | Phoenix leads in listing volume, offering broader market reach at comparatively lower maximum price points than Scottsdale.                | Focus on high-volume sales strategies and broad marketing outreach, emphasizing accessibility and diverse property options.         |
| **Single-Family Homes: Core Value** | Single-family homes are consistently the most common and valuable property type across all cities observed.                                | Prioritize acquisition and sales efforts on single-family listings, leveraging expertise in this dominant market segment.           |
| **Average Price Dynamics**         | The overall average property price is **~$589K**, significantly influenced by high-value outliers in areas like Scottsdale.                | Implement segmented sales and marketing strategies that account for varying price points, avoiding a one-size-fits-all messaging.   |




