/*
		PHASE 1: Convert Each WorkSheet into csv file 
        Import table from the each csv file in Workbench
*/
create table customers_new as
select customer_id,name,location
from customers;
drop table customers;
alter table customers_new rename to customers;

create table orderdetails_new as
select order_id,product_id,quantity,price_per_unit
from orderdetails;
select*from orderdetails_new;
drop table orderdetails;
alter table orderdetails_new rename to orderdetails;

create table orders_new as
select order_id,order_date,customer_id,total_amount
from orders;
select*from orders_new;
drop table orders;
alter table orders_new rename to orders; 

create table products_new as 
select product_id,name,category,price
from products;
select * from products_new;
drop table products;
alter table products_new rename to products;
/*
	PHASE 2: Data Quality Check
*/
-- Null Values
select *
from customers
where customer_id is null;

select *
from orderdetails
where order_id is null;

select *
from orders
where order_id is null;

select * 
from products
where product_id is null;

-- Duplicates
select customer_id,count(*) 
from customers
group by customer_id
having count(*)>1;

select order_id,product_id,quantity,price_per_unit,count(*) 
from orderdetails
group by order_id,product_id,quantity,price_per_unit
having count(*)>1;

create table dist as 
select distinct *
from orderdetails;

select order_id,product_id,quantity,price_per_unit,count(*)
from dist
group by order_id,product_id,quantity,price_per_unit
having count(*)>1;

drop table orderdetails;
alter table dist rename to orderdetails;

select order_id,order_date,customer_id,total_amount,count(*)
from orders
group by order_id,order_date,customer_id,total_amount
having count(*)>1;

select product_id,name,category,price,count(*)
from products
group by product_id,name,category,price
having count(*)>1;

-- Date Data type
select str_to_date(order_date,'%Y-%m-%d')
from orders;

SET SQL_SAFE_UPDATES = 0;

UPDATE orders
SET order_date = STR_TO_DATE(order_date,'%Y-%m-%d');

alter table orders 
modify column order_date  date;
select* from orders;

-- Verify Revenue
select sum(quantity*price_per_unit) as revenue
from orderdetails;

select sum(total_amount)
from orders;

SELECT
    (SELECT SUM(quantity * price_per_unit) FROM orderdetails) -
    (SELECT SUM(total_amount) FROM orders) AS difference;
    
SELECT
    o.order_id,
    o.total_amount,
    SUM(od.quantity * od.price_per_unit) AS detail_amount
FROM orders o
JOIN orderdetails od
ON o.order_id = od.order_id
GROUP BY o.order_id, o.total_amount
HAVING o.total_amount <> SUM(od.quantity * od.price_per_unit);

SELECT order_id,
       COUNT(*) AS line_items
FROM orderdetails
WHERE order_id IN (183,165,163,148,141,140,136,132,119,117,115,108,103,94,89,84,80,74,62,54,51,42,18,16)
GROUP BY order_id;

SELECT *
FROM orders
WHERE order_id = 108;

SELECT order_id,SUM(quantity * price_per_unit)
FROM orderdetails
WHERE order_id = 108
group by order_id;
/*Data validation revealed that orders.
total_amount did not always reconcile with transaction-level data in orderdetails. 
Revenue metrics were therefore calculated from quantity × price_per_unit in 
the orderdetails table to ensure accuracy.*/
CREATE TABLE orders_backup AS
SELECT * FROM orders;
UPDATE orders o
JOIN (
    SELECT order_id,
           SUM(quantity * price_per_unit) AS calc_amount
    FROM orderdetails
    GROUP BY order_id
) od
ON o.order_id = od.order_id
SET o.total_amount = od.calc_amount;

/*
	PHASE 3: Customer Analysis
*/
-- 1. Total Customers
select count(*) as TotalCustomers
from customers;

-- 2. Customers by Location
select location,count(*) as TotalCustomers
from customers
group by location
order by count(*) desc;

-- 3. Top 10 Customers by Revenue
select c.customer_id,
	c.name,
    sum(o.total_amount) as Revenue
from customers c
join orders o
on c.customer_id = o.customer_id
group by c.customer_id,c.name
order by Revenue desc
limit 10;

-- 4. Average order Value Per Customer
select c.customer_id,
	c.name,
    round(avg(o.total_amount),2) as AvgOrderValue
from customers c
join orders o
on c.customer_id = o.customer_id
group by c.customer_id,c.name
order by AvgOrderValue desc;

/*
	PHASE 4: Product Analysis
*/
-- 5. Best Selling Products
select p.product_id,
	p.name,
    sum(od.quantity) as UnitsSold
from products p
join orderdetails od
on p.product_id = od.product_id
group by p.product_id,p.name
order by UnitsSold desc;

-- 6. Revenue by Product
select p.product_id,
	p.name,
    sum(od.quantity*od.price_per_unit) as Revenue
from products p
join orderdetails od
on p.product_id = od.product_id
group by p.product_id,p.name
order by Revenue desc;

-- 7. Revenue by Category
select 
	p.category,
    sum(od.quantity*od.price_per_unit) as Revenue
from products p
join orderdetails od
on p.product_id = od.product_id
group by p.category
order by Revenue desc;

-- 8. High Revenue Product
select p.product_id,
	p.name,
    sum(od.quantity*od.price_per_unit) as Revenue
from products p
join orderdetails od
on p.product_id = od.product_id
group by p.product_id,p.name
order by Revenue desc
limit 1;

/*
	PHASE 5: Sales Analysis
*/
-- 9.Monthly Revenue Trend
select month(order_date) as MonthNo,
	year(order_date) as Year,
sum(total_amount) as Revenue
from orders
group by month(order_date),year(order_date)
order by Year , MonthNo asc;

-- 10. Monthly Order Volume
select month(order_date) as MonthNo,
	year(order_date) as Year,
sum(order_id) as TotalOrders
from orders
group by month(order_date),year(order_date)
order by Year , MonthNo asc;

-- 11. Average Order Value by Month
select month(order_date) as MonthNo,
	year(order_date) as Year,
round(avg(total_amount),2) as AvgOrderValue
from orders
group by month(order_date),year(order_date)
order by Year , MonthNo asc;

-- 12. Month-over-Month (MoM) Revenue Growth
with MonthlySales as(
		select month(order_date) as MonthNo,
			YEAR(order_date) as Year,
			sum(total_amount) as Revenue
		from orders
		group by month(order_date) ,YEAR(order_date) 
		order by year,MonthNo asc
)
select MonthNo,
	Year,
    lag(Revenue) over(order by MonthNo) as PrevMonthRevenue,
    round(100*(Revenue-lag(Revenue) over(order by MonthNo))
    /lag(Revenue) over(order by MonthNo),2) as MoM_Growth
from MonthlySales;
-- 13. Highest Revenue Month
SELECT
    MONTH(order_date) AS MonthNo,
    Year(order_date) as Year,
    SUM(total_amount) AS Revenue
FROM orders
GROUP BY Year(order_date),MONTH(order_date)
ORDER BY Revenue DESC
LIMIT 1;

-- 14. Revenue by Customer Location
SELECT
    c.location,
    ROUND(SUM(o.total_amount),2) AS Revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.location
ORDER BY Revenue DESC;

-- 15. Running Revenue Total
with MonthlySales as(
		select month(order_date) as MonthNo,
			YEAR(order_date) as Year,
			sum(total_amount) as Revenue
		from orders
		group by month(order_date) ,YEAR(order_date) 
		order by year,MonthNo asc
)
select MonthNo,
	Revenue,
    sum(Revenue) over(order by MonthNo) as RunningTotal
from MonthlySales;

/*
	PHASE 6: ADVANCED SQL ANALYSIS
*/
-- 16. Customer Lifetime Value (CLV)
select c.customer_id,
	c.name,
    count(o.order_id) as TotalOrders,
    sum(o.total_amount) as LifeTimeValue
from customers c
join orders o
on c.customer_id = o.customer_id
group by c.customer_id,c.name
order by LifeTimeValue desc;

-- 17. Top 20% Customers Contribution (Pareto Analysis)
WITH CustomerRevenue AS
(
    SELECT
        customer_id,
        SUM(total_amount) Revenue
    FROM orders
    GROUP BY customer_id
)

SELECT *
FROM CustomerRevenue
ORDER BY Revenue DESC;

-- 18. Customer Segmentation
select customer_id,
	sum(total_amount) as Revenue,
	case 
		when sum(total_amount)<100000 then 'Low Value'
        when sum(total_amount) between 100000 and 500000 then 'Regular'
        else 'VIP'
	end as Segment
from orders
group by customer_id;

-- 19. Product Ranking Within Category

SELECT
    p.category,
    p.name,
    SUM(od.quantity) UnitsSold,
    RANK() OVER(
        PARTITION BY p.category
        ORDER BY SUM(od.quantity) DESC
    ) AS ProductRank
FROM products p
JOIN orderdetails od
ON p.product_id=od.product_id
GROUP BY p.category,p.name;

WITH RFM AS
(
    SELECT
        customer_id,
        DATEDIFF(
            (SELECT MAX(order_date) FROM orders),
            MAX(order_date)
        ) AS Recency,
        COUNT(order_id) AS Frequency,
        SUM(total_amount) AS Monetary
    FROM orders
    GROUP BY customer_id
)

-- 20. RFM Analysis (Most Advanced Query)
SELECT *
FROM RFM
ORDER BY Monetary DESC;