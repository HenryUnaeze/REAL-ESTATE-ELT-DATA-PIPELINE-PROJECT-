---## INSERTIN DATA FROM TRANSFORMED_LISTINGS TABLE 

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
