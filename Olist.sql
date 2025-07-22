---The Relational Database Management System (RDBMS) used is PostgreSQL.
/*
1. Create all Dimension tables:
- Customer
- Geolocation
- Product
- Category
- Seller

2. Create all Fact tables:
- Orders
- Order Payment
- Order Items
- Order Reviews
*/
----------------------------------------------------------------------------

---Note: You can create the tables, Views, SP etc via VS Code and it will reflect in PG Admin or you can create the tables, Views, SP etc in PG Admin and it will reflect in VS Code

----Create Customers table
create table olist_datasets.customers(customer_id varchar(50) primary key,
customer_unique_id varchar(50) not null,
customer_zip_code_prefix varchar(50) not null,
customer_city varchar(50) not null,
customer_state varchar(2) not null
);

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

----Create Geolocation
create table olist_datasets.geolocation(
geolocation_zip_code_prefix int not null,
geolocation_lat float not null,
geolocation_lng float not null,
geolocation_city varchar(100) not null,
geolocation_state varchar(50) not null
);

----Retrieve the geolocation data
select *
from olist_datasets.geolocation;

---Distinct geolocation zipcode
SELECT distinct geolocation_zip_code_prefix
from olist_datasets.geolocation;

---Create a unique table with geolocation data
---CTE
with geolocation_base as (
SELECT distinct geolocation_zip_code_prefix,
geolocation_state as state,
geolocation_city as city,
geolocation_lat,
geolocation_lng
from olist_datasets.geolocation
)
select *
from geolocation_base;

---Temp table
drop table if exists geolocation_base_;
SELECT distinct geolocation_zip_code_prefix,
geolocation_state as state,
geolocation_city as city,
geolocation_lat,
geolocation_lng
into geolocation_base_
from olist_datasets.geolocation;

select *
from geolocation_base_;

---Create a View to store the unique geolocation data
create View olist_datasets.geolocation_unique as
with geolocation_base as (
SELECT distinct geolocation_zip_code_prefix,
geolocation_state as state,
geolocation_city as city,
geolocation_lat,
geolocation_lng
from olist_datasets.geolocation
)
select *
from geolocation_base;

---Retrieve the View table
select * from olist_datasets.geolocation_unique;


---Create a Product table
create table olist_datasets.product(
product_id varchar(500) primary key not null,
product_category_name varchar(200),
product_name_lenght	int,
product_description_lenght int,
product_photos_qty int,	
product_weight_g int,
product_length_cm int,
product_height_cm int,
product_width_cm int
);

---Retrieve the table
select * from olist_datasets.product;

---Verify if there's duplicate in the product table
select product_id, count(product_id)
from olist_datasets.product
group by product_id
having count(product_id) > 1;

---Create a Category table
create table olist_datasets.product_category(
product_category_name varchar(100) primary key,
product_category_name_english varchar(100) not null
);

---Retrieve the table
select * from olist_datasets.product_category;

---Create a Seller table
create table olist_datasets.sellers(
seller_id varchar(500) primary key,
seller_zip_code_prefix varchar(50) not null,
seller_city varchar(100) not null,
seller_state varchar(2) not null
);

---Retrieve the table
select * from olist_datasets.sellers;

---Create Order table
create table olist_datasets.orders(
order_id varchar(100) primary key not null,
customer_id varchar(100) not null,
order_status varchar(20) not null,
order_purchase_timestamp timestamp not null,
order_approved_at timestamp,
order_delivered_carrier_date timestamp,
order_delivered_customer_date timestamp,
order_estimated_delivery_date timestamp
);

---Retrieve the data
select * from olist_datasets.orders;

---Create Payment table
create table olist_datasets.order_payment(
order_id varchar(100) not null,
payment_sequential int not null,
payment_type varchar(10) not null,
payment_installments int not null,
payment_value float not null
);

---Alter the order payment table, alter the payment_type column, and extend the lenght of variable character
alter table olist_datasets.order_payment alter column payment_type type varchar(20);

---Retrieve the table
select * from olist_datasets.order_payment;

---Create Order Item table
create table olist_datasets.order_items(
order_id varchar(100) not null,
order_item_id int not null,
product_id varchar(100) not null,
seller_id varchar(100) not null,
shipping_limit_date timestamp not null,
price float not null,
freight_value float not null
);

---Retrieve the table
select * from olist_datasets.order_items;

---Create Order Reviews
create table olist_datasets.order_reviews(
review_id varchar(100) not null,
order_id varchar(100) not null,
review_score int not null,
review_comment_title varchar(1000),
review_comment_message varchar(5000),
review_creation_date timestamp not null,
review_answer_timestamp timestamp not null
);

--Retrieve the table
select * from olist_datasets.order_reviews;

------------------------------------------------------------------------
---Solutions to Business Questions
