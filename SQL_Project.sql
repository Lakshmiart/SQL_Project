use projectdp;

-- Q1-Write a query to identify the number of duplicates in "sales_transaction" table. 
-- Also, create a separate table containing the unique values and remove the the original table 
-- from the databases and replace the name of the new table with the original name.

select ï»¿TransactionID , count(*) from Sales_transaction
group by ï»¿TransactionID
having count(*) >1;
create table Sales_transaction1 as
select distinct * from Sales_transaction;
drop table Sales_transaction;
ALTER TABLE Sales_transaction1 
RENAME TO Sales_transaction;
select * from Sales_transaction;

-- Q2-Write a query to identify the discrepancies in the price of the same product 
-- in "sales_transaction" and "product_inventory" tables. Also, 
-- update those discrepancies to match the price in both the tables. 

select st.ï»¿TransactionID, st.price as TransactionPrice, pi.price as InventoryPrice
from sales_transaction st 
join product_inventory pi on st.productID=pi.ï»¿ProductID
where st.price<>pi.price;

update sales_transaction as st set
price=(select pi.price from product_inventory pi where pi.ï»¿ProductID=st.ProductID)
where st.productID in 
(select pi.ï»¿ProductID from product_inventory pi where st.Price<>pi.Price);

-- Q3 Write a SQL query to identify the null values in the dataset and replace those by “Unknown”.
select count(*) 
from customer_profiles 
where location is Null;

update customer_profiles 
set location='Unknown'
where location is null;

select * from customer_profiles ;   
    
-- Q4-Write a SQL query to summarize the total sales and quantities sold per product by the company.
select ProductID, sum(quantitypurchased) as TotalUnitsSold, sum(quantitypurchased*price) as TotalSales
from Sales_transaction
group by ProductID
order by 3 desc; 

-- Q5-Write a SQL query to count the number of transactions per customer to understand purchase frequency.

select customerID, count(ï»¿TransactionID) as NumberOfTransactions
from Sales_transaction
group by 1
order by 2 desc;

-- Write a SQL query to evaluate the performance of the product categories based on the total sales 
-- which help us understand the product categories which needs to be promoted in the marketing campaigns.


Select Pi.Category, sum(st.quantitypurchased) as TotalUnitsSold, sum(st.Price*st.quantitypurchased) as TotalSales
from Sales_transaction st
join product_inventory PI on st.productID=Pi.ï»¿ProductID
group by PI.Category
order by TotalSales desc;

-- Write a SQL query to find the top 10 products with the total sales revenue 
-- from the sales transactions. This will help the company to identify the High sales products 
-- which needs to be focused to increase the revenue of the company.

select ProductID, 
sum(price * QuantityPurchased) as TotalRevenue 
from Sales_transaction
group by ProductID
order by TotalRevenue desc
limit 10;

-- Write a SQL query to find the ten products with the least amount of units 
-- sold from the sales transactions, provided that at least one unit was sold for those products.

select ProductID, sum(QuantityPurchased) as TotalUnitsSold
from Sales_transaction
group by 1
having sum(QuantityPurchased)>1
order by 2 
limit 10;

-- Write a SQL query to understand the month on month growth rate of sales of the company 
-- which will help understand the growth trend of the company.
WITH monthly_sales AS

(

   SELECT

       MONTH(TransactionDate) AS month,

       SUM(QuantityPurchased*Price) AS total_sales

   FROM

       sales_transaction

   GROUP BY

       1

)

SELECT

   month,

   total_sales,

   LAG(total_sales) OVER (ORDER BY month) AS previous_month_sales,

   ((total_sales - LAG(total_sales) OVER (ORDER BY month)) / LAG(total_sales) OVER (ORDER BY month)) * 100 AS mom_growth_percentage

FROM

   monthly_sales

ORDER BY

   month;

-- Write a SQL query that describes the number of transaction along with the total amount spent by each customer 
-- which are on the higher side and will help us understand the customers who are the high frequency purchase customers in the company. 

select CustomerID, 
count(ï»¿TransactionID) as NumberOfTransactions, sum(Price*quantityPurchased) as TotalSpent
from sales_transaction
group by CustomerID
having count(ï»¿TransactionID)>10 and sum(Price*quantityPurchased)>1000
order by TotalSpent desc;

-- Write a SQL query that describes the number of transaction along with the total amount spent by each customer,
-- which will help us understand the customers who are occasional customers or have low purchase frequency in the company. 

select CustomerID, Count(ï»¿TransactionID) as NumberOfTransactions, 
sum(Price*Quantitypurchased) as TotalSpent
from Sales_transaction
group by CustomerID
having Count(ï»¿TransactionID)<=2
order by 2, 3 desc;

-- Write a SQL query that describes the total number of purchases made by each customer 
-- against each productID to understand the repeat customers in the company. 

select CustomerID, ProductID, count(ProductID) as TimesPurchased
from Sales_transaction
group by CustomerID, ProductID
having count(ProductID)>1
order by 3 desc;

-- Write an SQL query that segments customers based on the total quantity of products they have purchased. Also, 
-- count the number of customers in each segment which will help us target a particular segment for marketing.

CREATE TABLE customer_SEGMENT AS
SELECT ï»¿CustomerID,
    CASE 
        WHEN TotalQuantity > 30 THEN "High"
        WHEN TotalQuantity BETWEEN 10 AND 30 THEN "Med"
        WHEN TotalQuantity BETWEEN 1 AND 10 THEN "Low"
        ELSE "None" 
    END AS CustomerSegment
FROM (
    SELECT a.ï»¿CustomerID, SUM(b.QuantityPurchased) AS TotalQuantity
    FROM customer_profiles a
    JOIN sales_transaction b
    ON a.ï»¿CustomerID = b.CustomerID
    GROUP BY a.ï»¿CustomerID
) AS totquant;

SELECT CustomerSegment, COUNT(*)
FROM customer_SEGMENT
GROUP BY CustomerSegment;
