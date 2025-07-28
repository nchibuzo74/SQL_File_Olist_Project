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

-----------------------------------------------------------

---Create an Store Procedure (SP) to store the unique geolocation data
create procedure olist_datasets.geolocation_unique()
LANGUAGE SQL
as $$
with UP_geolocation_base as (
SELECT distinct geolocation_zip_code_prefix,
geolocation_state as state,
geolocation_city as city,
geolocation_lat,
geolocation_lng
from olist_datasets.geolocation
)
select *
from UP_geolocation_base;
$$;

---execute the SP
CALL olist_datasets.geolocation_unique();


------------------------------------------------------------------------------------------------------------------------------
-------Create a dump table from a store procedure----------
create or replace procedure olist_datasets.USP_geolocation_unique_()
LANGUAGE SQL
as $$

drop table if exists USP_geolocation_base_;
SELECT distinct geolocation_zip_code_prefix,
geolocation_state as state,
geolocation_city as city,
geolocation_lat,
geolocation_lng
into USP_geolocation_base_
from olist_datasets.geolocation;

---Final block
drop table if exists USP_Get_geolocation_base;
select *
into USP_Get_geolocation_base
from USP_geolocation_base_;

---main action of creating the dummy table: drop into, delete, insert and select
/*
select *                ----change the create to alter (i.e. we are altering the proc). Uncomment the block before the below code, then comment the below code then compile. Run exec List_Percentage 
into olist_datasets.USP_geolocation_unique_
from USP_Get_geolocation_base;
*/

---delete from olist_datasets.USP_geolocation_unique_;   --------------Uncomment the block and comment above line then compile. Run exec List_Percentage

insert into olist_datasets.USP_geolocation_unique_   ------Uncomment both block lines of code - this line and next block of line and comment above line  then compile. Run exec List_Percentage
select * from USP_Get_geolocation_base;

$$;

CALL olist_datasets.USP_geolocation_unique_();

---Retrieve the dump table
select * from olist_datasets.USP_geolocation_unique_;
------------------------------------------------------------------------------------------------------------------------------------------------------


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
---Solutions to Business Questions:
------------------------------------------------------------------------
/*
Customer and Sales Analysis:
1. Total Customer State
2. Total Customer City
3. Total Customers
4. Total Delivered Order
5. Total Delivered Revenue and Average Yearly Revenue
6. Total Products
7. Average Monthly Revenue
8. AOV
9. CMV
*/

---CTE: A Customer base
with customer_base as (
    select distinct *
    from olist_datasets.customers
),
---Total Customers
aggregated_customers as (
    select count(distinct(customer_state)) as total_customer_state, count(distinct(customer_city)) as total_customer_city,
	count(customer_id) as total_customers
    from customer_base
),
---Sales info:
fact_sales as (
    select order_id, customer_id, order_purchase_timestamp, order_delivered_customer_date, order_estimated_delivery_date, order_status
    from olist_datasets.orders 
),
---Payment info:
fact_payment as (
    select order_id, sum(payment_value) as amount
    from olist_datasets.order_payment
    --where payment_type <> 'not_defined'
    group by order_id
),
---Average Monthly Revenue
year_month_revenue as (
    select a.order_id, extract(year from a.order_purchase_timestamp) as year_, extract(month from a.order_purchase_timestamp) as month_,
    sum(b.payment_value) as revenue
    from olist_datasets.orders as a
    inner join olist_datasets.order_payment as b
    on a.order_id = b.order_id
    --where b.payment_type <> 'not_defined'
    and a.order_status = 'delivered'
    group by a.order_id, extract(year from a.order_purchase_timestamp), extract(month from a.order_purchase_timestamp)
)
---Final Result
select ac.total_customer_state, ac.total_customer_city, ac.total_customers, count(distinct(s.customer_id)) as total_customers_with_delivered_order,
count(distinct(s.order_id)) as total_delivered_order, sum(p.amount) as delivered_revenue,
(sum(p.amount)/count(distinct(extract(year from s.order_purchase_timestamp)))) as average_yearly_revenue,
avg(ym.revenue) as average_monthly_revenue,
(sum(ym.revenue)/count(ym.month_)) as average_monthly_revenue_2
from fact_sales as s
left join fact_payment as p
on s.order_id = p.order_id
left join year_month_revenue as ym
on s.order_id = ym.order_id
cross join aggregated_customers as ac
where s.order_status = 'delivered' 
group by ac.total_customer_state, ac.total_customer_city, ac.total_customers;

---------More questions to be answered on customer and sales analysis:
/*
10. Customers by State
11. Order Trend
12. GMV Trend
13. Percentage Order Fulfilement
14. Average SKU Per Order
15. Average Item Size per Order
16. Order Item Contribution per Order
17. GMV Segmentation
18. Average Number of Order per Customers by Month Year
19. Weekly Delivery Time
20. Delivery Effectiveness - Days Taken
21. Top 10 Customers
*/

---Customers by State
select customer_state, count(distinct(customer_id)) as total_customers
from olist_datasets.customers
group by customer_state
order by customer_state asc;

---Order Trend
select extract(
        year
        from order_purchase_timestamp
    ) as year_,
    extract(
        month
        from order_purchase_timestamp
    ) as month_,
    to_char(order_purchase_timestamp, 'Month') as month_name,
    count(
        distinct(order_id)) as total_order
        from olist_datasets.orders
        group by extract(
                year
                from order_purchase_timestamp
            ),
            extract(
        month
        from order_purchase_timestamp
    ),
    to_char(order_purchase_timestamp, 'Month')
        order by extract(
                year
                from order_purchase_timestamp
            ) asc, 
            extract(
        month
        from order_purchase_timestamp
    ) asc;

---GMV Trend
select extract(
        year
        from order_purchase_timestamp
    ) as year_,
    extract(
        month
        from order_purchase_timestamp
    ) as month_,
    to_char(order_purchase_timestamp, 'Month') as month_name,
    sum(nullif(p.payment_value,0)) as total_gmv
from olist_datasets.orders as o
inner join olist_datasets.order_payment as p
on o.order_id = p.order_id
where o.order_status = 'delivered'
group by extract(
        year
        from order_purchase_timestamp
    ),
    extract(
        month
        from order_purchase_timestamp
    ),
    to_char(order_purchase_timestamp, 'Month')
order by extract(
        year
        from order_purchase_timestamp
    ) asc,
    extract(
        month
        from order_purchase_timestamp
    ) asc;

---Percentage Order Fulfilment
---All orders
with all_orders as (
    select count(distinct(order_id)) as total_orders
    from olist_datasets.orders
)
---Final Result
select ((count(distinct(o.order_id))::float / ao.total_orders::float) * 100) as percentage_order_fulfilment
from olist_datasets.orders as o
cross join all_orders as ao
where o.order_status = 'delivered'
group by ao.total_orders;

---Average SKU Per Order
select count(distinct(p.product_id)) as total_sku, count(distinct(o.order_id)) as total_orders,
(count(distinct(p.product_id))::float) / (count(distinct(o.order_id))::float) as average_sku_per_order
from olist_datasets.Orders as o
inner join olist_datasets.order_items as oi
on o.order_id = oi.order_id
inner join olist_datasets.product as p
on oi.product_id = p.product_id
where o.order_status = 'delivered';

---Average Item Size per Order
select count(oi.order_item_id) as total_items, count(distinct(o.order_id)) as total_orders,
(count(oi.order_item_id)::float) / (count(distinct(o.order_id))::float) as average_item_per_order
from olist_datasets.Orders as o
inner join olist_datasets.order_items as oi
on o.order_id = oi.order_id
where o.order_status = 'delivered';

---Order Item Contribution per Order
---It simple means the bucket segment of the items per order
---You need a bucket segment to know the contribution of the items per order
---CTE
with bucket_segment as (
select o.order_id,
case when count(oi.order_item_id) <= 3 then 'Low'
            when count(oi.order_item_id) > 3 and count(oi.order_item_id) <= 10 then 'Medium'
            else 'High'
            end as bucket_segment,
case when count(oi.order_item_id) <= 3 then 1
            when count(oi.order_item_id) > 3 and count(oi.order_item_id) <= 10 then 2
            else 3
            end as sort_bucket_segment,
case when count(oi.order_item_id) <= 3 then 'Order with at least 3 products'
            when count(oi.order_item_id) > 3 and count(oi.order_item_id) <= 10 then 'Order with at least 4-10 products'
            else 'Order with more than 10 products'
            end as order_item_segment
from olist_datasets.Orders as o
inner join olist_datasets.order_items as oi
on o.order_id = oi.order_id
where o.order_status = 'delivered'
group by o.order_id
)
select bucket_segment, order_item_segment, count(distinct(order_id)) as total_delivered_order
from bucket_segment
group by sort_bucket_segment, bucket_segment, order_item_segment
order by sort_bucket_segment asc;

---GMV Segmentation
---It simple means the bucket segment of the GMV per customer count
---You need a bucket segment to know the contribution of the GMV per customer count
with bucket_segment as (
select o.customer_id,
case when sum(p.payment_value) <= 1000 then 'Low'
            when sum(p.payment_value) > 1000 and sum(p.payment_value) <= 5000 then 'Medium'
            else 'High'
            end as bucket_segment,
case when sum(p.payment_value) <= 1000 then 1
            when sum(p.payment_value) > 1000 and sum(p.payment_value) <= 5000 then 2
            else 3
            end as sort_bucket_segment,
case when sum(p.payment_value) <= 1000 then 'Customer with less than $1000 GMV'
            when sum(p.payment_value) > 1000 and sum(p.payment_value) <= 5000 then 'Customer with $1000 - $5000 GMV'
            else 'Customer with more than $5000 GMV'
            end as gmv_segment
from olist_datasets.Orders as o
inner join olist_datasets.order_payment as p
on o.order_id = p.order_id
where o.order_status = 'delivered'
group by o.customer_id
)
select bucket_segment, gmv_segment, count(distinct(customer_id)) as total_customers
from bucket_segment
group by sort_bucket_segment, bucket_segment, gmv_segment
order by sort_bucket_segment asc;

---Average Number of Order per Customers by Month Year