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