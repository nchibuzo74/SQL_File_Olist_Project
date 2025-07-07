---The Relational Database Management System (RDBMS) used is PostgreSQL.
/*
1. Create all Dimension tables:
- Customer
- Geolocation
- Product
- Category
- Seller

2. Create all Fact tables:
- Order
- Payment
- Order Item
- Order Review
*/
----------------------------------------------------------------------------
---Retrieve the customer data
select *
from olist_datasets.customers;

---Unique Customers
SELECT count(distinct(customer_id)) as unique_customers
from olist_datasets.customers;

---Check for duplicate customers
SELECT customer_id, count(customer_id) as customer_count
from olist_datasets.customers
group by customer_id
having count(customer_id) > 1;

----Retrieve the geolocation data
select *
from olist_datasets.geolocation;

---Distinct geolocation zipcode
SELECT distinct geolocation_zip_code_prefix
from olist_datasets.geolocation;

---Create a unique table with geolocation data
with geolocation_base as (
SELECT geolocation_zip_code_prefix,
geolocation_state as state,
geolocation_city as city,
max(geolocation_lat) as max_lat,
max(geolocation_lng) as max_lng
from olist_datasets.geolocation
group by geolocation_zip_code_prefix, 
geolocation_state, geolocation_city
)
select *
from geolocation_base;
---
