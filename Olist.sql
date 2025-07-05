---Retrieve the customer data
select *
from olist_datasets.customers;

---Unique Customers
SELECT count(distinct(customer_id)) as unique_customers
from olist_datasets.customers;

----Retrieve the geolocation data
select *
from olist_datasets.geolocation;

---Distinct geolocation zipcode
SELECT distinct geolocation_zip_code_prefix
from olist_datasets.geolocation;
