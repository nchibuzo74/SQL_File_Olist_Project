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

3. Add constraint and index to the tables
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

---Create index on "customer_id" in customers table
create index idx_customer_id on olist_datasets.customers(customer_id);

---Create a constraint on Customers table. Set order_id as foreign key
alter table olist_datasets.order_payment add constraint fk_order_id foreign key(order_id) references olist_datasets.orders (order_id);

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

---Create a two more tables from Geolocation. Geolocation can be normalize to 3NF (third normalize form)

-----Create a Geolocation Zip_Code by merging key columns from customers and sellers tables.
drop table if exists olist_datasets.geolocation_zip_code;
select distinct customer_zip_code_prefix
into olist_datasets.geolocation_zip_code
from olist_datasets.customers

union

select distinct seller_zip_code_prefix
from olist_datasets.sellers;

---Set constraint to the geolocation_zip_code and rename the column
---rename the column
alter table olist_datasets.geolocation_zip_code rename column customer_zip_code_prefix to zip_code_prefix;

---set the constraint
alter table olist_datasets.geolocation_zip_code add constraint pk_zip_code_prefix primary key(zip_code_prefix);

---Set index to the table
create index idx_zip_code_prefix on olist_datasets.geolocation_zip_code(zip_code_prefix);

---create a table with Geolocation City and State
drop table if exists olist_datasets.geolocation_city_state;
select distinct customer_city as city, customer_state as state
into olist_datasets.geolocation_city_state
from olist_datasets.customers

union

select distinct seller_city, seller_state
from olist_datasets.sellers;

---create a composite key (i.e. concatenate city and state)
alter table olist_datasets.geolocation_city_state add column city_state varchar(200);

---add records to the city_state column
update olist_datasets.geolocation_city_state
set city_state = concat(city,'-',state)
where city_state is null;

---Set constraint (primary key) to the table on city_state.
alter table olist_datasets.geolocation_city_state add constraint pk_city_state primary key(city_state);

---Set index on the table
create index idx_city_state on olist_datasets.geolocation_city_state(city_state);

---Retrieve the table
select * from olist_datasets.geolocation_city_state;

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

---Create index on "product_id" in product table
create index idx_product_id on olist_datasets.product(product_id);

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

---Create index on "product_category_name" in category table
create index idx_product_category_name on olist_datasets.product_category(product_category_name);

---Retrieve the table
select * from olist_datasets.product_category;

---Create a Seller table
create table olist_datasets.sellers(
seller_id varchar(500) primary key,
seller_zip_code_prefix varchar(50) not null,
seller_city varchar(100) not null,
seller_state varchar(2) not null
);

---Create index on "seller_id" in Seller table
create index idx_seller_id on olist_datasets.sellers(seller_id);

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

---Create Index on the "order_id" in the orders table
create index idx_order_id on olist_datasets.orders(order_id);

---Create Index on the "order_status" in the orders table
create index idx_order_status on olist_datasets.orders(order_status);

---Create a constraint on Orders table. Set customer_id as foreign key
alter table olist_datasets.orders add constraint fk_customer_id foreign key(customer_id) references olist_datasets.customers (customer_id);

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

---Create a constraint on Payment table. Set order_id as foreign key
alter table olist_datasets.order_payment add constraint fk_order_id foreign key(order_id) references olist_datasets.orders (order_id);

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

---Create a constraint on Item table. Set order_id as foreign key
alter table olist_datasets.order_items add constraint fk_order_id foreign key(order_id) references olist_datasets.orders (order_id);

---Create a constraint on Orders table. Set seller_id as foreign key
alter table olist_datasets.order_items add constraint fk_seller_id foreign key(seller_id) references olist_datasets.sellers (seller_id);


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

---Create a constraint on Reviews table. Set order_id as foreign key
alter table olist_datasets.order_reviews add constraint fk_order_id foreign key(order_id) references olist_datasets.orders (order_id);

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

---CTE
---Customers GMV
WITH customer_gmv AS (
  SELECT 
    o.customer_id,
    SUM(p.payment_value) AS total_payment
  FROM olist_datasets.Orders AS o
  INNER JOIN olist_datasets.order_payment AS p
    ON o.order_id = p.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY o.customer_id
),
---Percentiles for GMV
percentiles AS (
  SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_payment) AS p25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY total_payment) AS median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_payment) AS p75,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY total_payment) AS p90
  FROM customer_gmv
),
---Bucket Segment
bucket_segment AS (
  SELECT 
    c.customer_id,
    c.total_payment,
    CASE
      WHEN c.total_payment <= p.p25 THEN 'Low'
      WHEN c.total_payment > p.p25 AND c.total_payment <= p.median THEN 'Medium'
      WHEN c.total_payment > p.median AND c.total_payment <= p.p75 THEN 'Medium High'
      ELSE 'High'
    END AS bucket_segment,
    CASE
      WHEN c.total_payment <= p.p25 THEN 1
      WHEN c.total_payment > p.p25 AND c.total_payment <= p.median THEN 2
      WHEN c.total_payment > p.median AND c.total_payment <= p.p75 THEN 3
      ELSE 4
    END AS sort_order
  FROM customer_gmv as c
  CROSS JOIN percentiles as p
)
---Final Result
SELECT
  bucket_segment,
  COUNT(DISTINCT customer_id) AS customer_count,
  MIN(total_payment) AS min_value,
  MAX(total_payment) AS max_value,
  AVG(total_payment) AS avg_value
FROM bucket_segment
GROUP BY sort_order, bucket_segment
ORDER BY sort_order;

---Average Number of Order per Customers by Month Year
select extract(year from o.order_purchase_timestamp) as year_,
extract(month from o.order_purchase_timestamp) as month_,
to_char(o.order_purchase_timestamp, 'Month') as month_name,
count(distinct(o.order_id)) as total_orders,
count(distinct(o.customer_id)) as total_customers,
(count(distinct(o.order_id))::float) / (count(distinct(o.customer_id))::float) as average_order_per_customer
from olist_datasets.orders as o
where o.order_status = 'delivered'
group by extract(year from o.order_purchase_timestamp),
extract(month from o.order_purchase_timestamp),
to_char(o.order_purchase_timestamp, 'Month')
order by extract(year from o.order_purchase_timestamp) asc,
extract(month from o.order_purchase_timestamp) asc;

---Weekly Delivery Time
select extract(year from o.order_purchase_timestamp) as year_,
extract(week from o.order_purchase_timestamp) as week_,
to_char(o.order_purchase_timestamp, 'Week') as week_name,
avg(extract(day from (o.order_delivered_customer_date - o.order_purchase_timestamp))) as average_delivery_time,
max(extract(day from (o.order_delivered_customer_date - o.order_purchase_timestamp))) as max_delivery_time,
count(distinct(o.order_id)) as total_orders
from olist_datasets.orders as o
where o.order_status = 'delivered'
group by extract(year from o.order_purchase_timestamp),
extract(week from o.order_purchase_timestamp),
to_char(o.order_purchase_timestamp, 'Week')
order by extract(year from o.order_purchase_timestamp) asc,
extract(week from o.order_purchase_timestamp) asc;

---Delivery Effectiveness - Days Taken
SELECT 
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year_,
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month_,
    TO_CHAR(o.order_purchase_timestamp, 'Month') AS month_name,
    CASE 
        WHEN EXTRACT(DAY FROM o.order_purchase_timestamp) <= 7 THEN 'Week 1'
        WHEN EXTRACT(DAY FROM o.order_purchase_timestamp) <= 14 THEN 'Week 2'
        WHEN EXTRACT(DAY FROM o.order_purchase_timestamp) <= 21 THEN 'Week 3'
        ELSE 'Week 4' 
    END AS purchase_week_of_month,
    CASE 
        WHEN o.order_delivered_customer_date IS NULL THEN 'Not delivered'
        WHEN EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) <= 1 THEN '1 day'
        WHEN EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) = 2 THEN '2 days'
        WHEN EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) = 3 THEN '3 days'
        WHEN EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) = 4 THEN '4 days'
        WHEN EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) = 5 THEN '5 days'
        ELSE '> 5 days' 
    END AS days_taken,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM olist_datasets.orders AS o
WHERE o.order_status = 'delivered'
GROUP BY 
    EXTRACT(YEAR FROM o.order_purchase_timestamp),
    EXTRACT(MONTH FROM o.order_purchase_timestamp),
    TO_CHAR(o.order_purchase_timestamp, 'Month'),
    CASE 
        WHEN EXTRACT(DAY FROM o.order_purchase_timestamp) <= 7 THEN 'Week 1'
        WHEN EXTRACT(DAY FROM o.order_purchase_timestamp) <= 14 THEN 'Week 2'
        WHEN EXTRACT(DAY FROM o.order_purchase_timestamp) <= 21 THEN 'Week 3'
        ELSE 'Week 4' 
    END,
    CASE 
        WHEN o.order_delivered_customer_date IS NULL THEN 'Not delivered'
        WHEN EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) <= 1 THEN '1 day'
        WHEN EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) = 2 THEN '2 days'
        WHEN EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) = 3 THEN '3 days'
        WHEN EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) = 4 THEN '4 days'
        WHEN EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) = 5 THEN '5 days'
        ELSE '> 5 days' 
    END
ORDER BY 
    EXTRACT(YEAR FROM o.order_purchase_timestamp) ASC,
    EXTRACT(MONTH FROM o.order_purchase_timestamp) ASC;

---Top 10 Customers
select c.customer_id, c.customer_city, c.customer_state, count(distinct(o.order_id)) as total_orders,
sum(p.payment_value) as total_revenue
from olist_datasets.customers as c
inner join olist_datasets.orders as o
on c.customer_id = o.customer_id
inner join olist_datasets.order_payment as p
on o.order_id = p.order_id
where o.order_status = 'delivered'
group by c.customer_id, c.customer_city, c.customer_state
order by total_revenue desc
limit 10;

----What is the average time between first and second purchase?
---get all customers order
with customer_order as (
select customer_id, order_id, min(order_purchase_timestamp:: date) as earliest_purchase_date,
max(order_purchase_timestamp:: date) as second_purchase_date
from olist_datasets.orders
group by customer_id, order_id
having count(distinct(order_id)) = 2
);


/*
---Payment Analysis:
1. Total Payment Type
2. Payment Count
3. Mix Payment Count
4. Non Mix Payment Count
5. Total Payment Amount
6. Mix Payment Amount
7. Non Mix Payment Amount
8. Monthly Payment Count (Transaction)
9. Mix Monthly Payment Count (Transaction)
10. Non Mix Monthly Payment Count (Transaction)
11. Payment Amount Trend
12. Payment Type Ratio Trend
13. Payment Type Mix Ratio Trend
14. Payment Amount Segmentation
15. Mixed Payment Amount Segmentation
16. Non Mixed Payment Amount Segmentation
17. Payment Count Segmentation
18. Payment Installment Segmentation
*/

---Total Payment Type
select count(distinct(p.payment_type)) as total_payment_type
from olist_datasets.order_payment as p
inner join olist_datasets.orders as o
on p.order_id = o.order_id
where o.order_status = 'delivered';

---2. Payment Count
select count(p.payment_type) as total_payment_count
from olist_datasets.order_payment as p
    inner join olist_datasets.orders as o on p.order_id = o.order_id
where o.order_status = 'delivered';

---3. Mix Payment Count
---identify the payment type count per order
with aggregation_payment_type as (
select p.order_id,
    count(distinct(p.payment_type)) as count_of_payment_type,
    string_agg(p.payment_type, ' | ') as list_of_payment_type --case when count(distinct(p.payment_type)) > 1 then 1 else null end as mix_payment_status
from olist_datasets.order_payment as p
    inner join olist_datasets.orders as o on p.order_id = o.order_id
where o.order_status = 'delivered'
group by p.order_id
---order by count(distinct(p.payment_type)) desc;
)
--Final block
select sum(case when count_of_payment_type > 1 then count_of_payment_type else null end) as mix_payment_count
from aggregation_payment_type;

---4. Non Mix Payment Count
---identify the payment type count per order
with aggregation_payment_type as (
select p.order_id,
    count(distinct(p.payment_type)) as count_of_payment_type,
    string_agg(p.payment_type, ' | ') as list_of_payment_type --case when count(distinct(p.payment_type)) > 1 then 1 else null end as mix_payment_status
from olist_datasets.order_payment as p
    inner join olist_datasets.orders as o on p.order_id = o.order_id
where o.order_status = 'delivered'
group by p.order_id
---order by count(distinct(p.payment_type)) desc;
)
--Final block
select sum(case when count_of_payment_type = 1 then count_of_payment_type else null end) as mix_payment_count
from aggregation_payment_type;

---sanity check
with cte as (
select p.order_id,
    count(distinct(p.payment_type)) as count_of_payment_type
   -- string_agg(p.payment_type, ' | ') as list_of_payment_type --case when count(distinct(p.payment_type)) > 1 then 1 else null end as mix_payment_status
from olist_datasets.order_payment as p
    inner join olist_datasets.orders as o on p.order_id = o.order_id
where o.order_status = 'delivered'
group by p.order_id
)
select sum(count_of_payment_type) as total_payment_count
from cte;

---5. Total Payment Amount
select sum(p.payment_value) as total_payment
from olist_datasets.order_payment as p
inner join olist_datasets.orders as o  
on p.order_id = o.order_id
where o.order_status = 'delivered';


----6 & 7. Mix and Non Mix Payment Amount
----Get all delivered mix payment by order
with order_payment_status as (
select o.order_id, count(distinct(p.payment_type)) as payment_type_count,
string_agg(p.payment_type,' | ') as list_of_payment_type,
 sum(p.payment_value) as total_payment,
 count(p.order_id) as payment_sequence_,
 case when count(distinct(p.payment_type)) > 1 then 'Mix' else 'Non Mix' end as payment_status
from olist_datasets.order_payment as p
inner join olist_datasets.orders as o  
on p.order_id = o.order_id
where o.order_status = 'delivered'
group by o.order_id
---order by count(distinct(p.payment_type)) desc;
)
---Final block: get all mix payment amount
select payment_status, sum(total_payment) as mix_payment_amount
from order_payment_status
where payment_status = 'Mix'
group by payment_status

union all

select payment_status, sum(total_payment) as non_mix_payment_amount
from order_payment_status
where payment_status = 'Non Mix'
group by payment_status;


----8. Monthly Payment Count (Transaction)
select extract(year from o.order_purchase_timestamp) as year_,
extract(month from o.order_purchase_timestamp) as month_,
to_char(o.order_purchase_timestamp, 'Month') as month_name,
count(p.payment_type) as monthly_payment_count
from olist_datasets.orders as o
inner join olist_datasets.order_payment as p
on o.order_id = p.order_id
where o.order_status = 'delivered'
group by extract(year from o.order_purchase_timestamp),
extract(month from o.order_purchase_timestamp),
to_char(o.order_purchase_timestamp, 'Month')
order by extract(year from o.order_purchase_timestamp) asc,
extract(month from o.order_purchase_timestamp) asc;


---9. Mix Monthly Payment Count (Transaction)
---Get all delivered mix payment by order
with order_payment_status as (
select o.order_id, count(distinct(p.payment_type)) as payment_type_count,
string_agg(p.payment_type,' | ') as list_of_payment_type,
 count(p.order_id) as payment_sequence_,
 case when count(distinct(p.payment_type)) > 1 then 'Mix' else 'Non Mix' end as payment_status,
 extract(year from o.order_purchase_timestamp) as year_,
 extract(month from o.order_purchase_timestamp) as month_,
 to_char(o.order_purchase_timestamp, 'Month') as month_name
from olist_datasets.order_payment as p
inner join olist_datasets.orders as o  
on p.order_id = o.order_id
where o.order_status = 'delivered'
group by o.order_id, extract(year from o.order_purchase_timestamp),
 extract(month from o.order_purchase_timestamp),
 to_char(o.order_purchase_timestamp, 'Month')
---order by count(distinct(p.payment_type)) desc;
)
---Final block: get all mix payment count by month year
select year_, month_, month_name, sum(case when payment_status = 'Mix' then payment_type_count else null end) as mix_monthly_payment_count
from order_payment_status
group by year_, month_, month_name
order by year_ asc, month_ asc;

---10. Non Mix Monthly Payment Count (Transaction)
---Get all delivered mix payment by order
with order_payment_status as (
select o.order_id, count(distinct(p.payment_type)) as payment_type_count,
string_agg(p.payment_type,' | ') as list_of_payment_type,
 count(p.order_id) as payment_sequence_,
 case when count(distinct(p.payment_type)) > 1 then 'Mix' else 'Non Mix' end as payment_status,
 extract(year from o.order_purchase_timestamp) as year_,
 extract(month from o.order_purchase_timestamp) as month_,
 to_char(o.order_purchase_timestamp, 'Month') as month_name
from olist_datasets.order_payment as p
inner join olist_datasets.orders as o  
on p.order_id = o.order_id
where o.order_status = 'delivered'
group by o.order_id, extract(year from o.order_purchase_timestamp),
 extract(month from o.order_purchase_timestamp),
 to_char(o.order_purchase_timestamp, 'Month')
---order by count(distinct(p.payment_type)) desc;
)
---Final block: get all non mix payment count by month year
select year_, month_, month_name, sum(case when payment_status = 'Non Mix' then payment_type_count else null end) as non_mix_monthly_payment_count
from order_payment_status
group by year_, month_, month_name
order by year_ asc, month_ asc;

---11. Payment Amount Trend
select extract(year from o.order_purchase_timestamp) as year_,
extract(month from o.order_purchase_timestamp) as month_,
to_char(o.order_purchase_timestamp, 'Month') as month_name,
sum(p.payment_value) as total_payment_amount
from olist_datasets.orders as o
inner join olist_datasets.order_payment as p
on o.order_id = p.order_id
where o.order_status = 'delivered'
group by extract(year from o.order_purchase_timestamp),
extract(month from o.order_purchase_timestamp),
to_char(o.order_purchase_timestamp, 'Month')
order by extract(year from o.order_purchase_timestamp) asc,
extract(month from o.order_purchase_timestamp) asc;

---12. Payment Type Ratio Trend
---CTE: get payment type count by month year
with payment_type_monthly as (
select extract(year from o.order_purchase_timestamp) as year_,
extract(month from o.order_purchase_timestamp) as month_,
to_char(o.order_purchase_timestamp, 'Month') as month_name,
p.payment_type,
count(p.payment_type) as payment_type_count,
sum(p.payment_value) as payment_type_amount
from olist_datasets.orders as o
inner join olist_datasets.order_payment as p
on o.order_id = p.order_id
where o.order_status = 'delivered'
group by extract(year from o.order_purchase_timestamp),
extract(month from o.order_purchase_timestamp),
to_char(o.order_purchase_timestamp, 'Month'),
p.payment_type
),
---Final block: get payment type ratio trend
total_payment_type_monthly as (
select year_, month_, month_name, sum(payment_type_count) as total_payment_count
from payment_type_monthly
group by year_, month_, month_name
)
select ptm.year_, ptm.month_, ptm.month_name, ptm.payment_type, ptm.payment_type_count,
tptm.total_payment_count,
(ptm.payment_type_count::float / tptm.total_payment_count::float) * 100 as payment_type_ratio_percentage,
ptm.payment_type_amount
from payment_type_monthly as ptm
inner join total_payment_type_monthly as tptm
on ptm.year_ = tptm.year_ and ptm.month_ = tptm.month_
order by ptm.year_ asc, ptm.month_ asc, ptm.payment_type asc;


---13. Payment Type Mix Ratio Trend
---CTE: get mix payment type count by month year
with order_payment_status as (
select o.order_id, count(distinct(p.payment_type)) as payment_type_count,
string_agg(p.payment_type,' | ') as list_of_payment_type,
 count(p.order_id) as payment_sequence_,
 case when count(distinct(p.payment_type)) > 1 then 'Mix' else 'Non Mix' end as payment_status,
 case when count(distinct(p.payment_type)) > 1 then sum(p.payment_value) else null end as mix_payment_amount,
 extract(year from o.order_purchase_timestamp) as year_,
 extract(month from o.order_purchase_timestamp) as month_,
 to_char(o.order_purchase_timestamp, 'Month') as month_name
from olist_datasets.order_payment as p
inner join olist_datasets.orders as o  
on p.order_id = o.order_id
where o.order_status = 'delivered'
group by o.order_id, extract(year from o.order_purchase_timestamp),
 extract(month from o.order_purchase_timestamp),
 to_char(o.order_purchase_timestamp, 'Month')
),
---Aggregate mix payment type count by month year
mix_payment_monthly as (
select year_, month_, month_name,
sum(case when payment_status = 'Mix' then payment_type_count else null end) as mix_payment_count,
sum(case when payment_status = 'Non Mix' then payment_type_count else null end) as non_mix_payment_count,
sum(mix_payment_amount) as mix_payment_amount_
from order_payment_status
group by year_, month_, month_name
),
---Final block: get mix payment type ratio trend
total_payment_monthly as (
select year_, month_, month_name,
(mix_payment_count + non_mix_payment_count) as total_payment_count
from mix_payment_monthly
)
select mpm.year_, mpm.month_, mpm.month_name,
mpm.mix_payment_count, mpm.mix_payment_amount_,
sum(tpm.total_payment_count) as total_payment_count_,
(mpm.mix_payment_count::float / sum(tpm.total_payment_count::float)) * 100 as mix_payment_ratio_percentage
from mix_payment_monthly as mpm
cross join total_payment_monthly as tpm
group by mpm.year_, mpm.month_, mpm.month_name, mpm.mix_payment_count, mpm.mix_payment_amount_
order by mpm.year_ asc, mpm.month_ asc;