### -------QUERRY

----Components: 
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
