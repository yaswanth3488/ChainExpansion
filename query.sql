



-- *****Optimizing Coffee Shop Expansion: A Data-Driven Approach**** --




  -- Overall Sales Performance:
-- What is the overall trend of sales over time

SELECT 
    YEAR(sale_date) AS year, 
    MONTH(sale_date) AS month, 
    SUM(total) AS total_sales
FROM 
    sales
GROUP BY 
    year, month
ORDER BY 
    year, month;
    
    
  
  -- Sales Count for Each Product
-- How many units of each coffee product have been sold?

SELECT 
	p.product_name,
	COUNT(s.sale_id) as total_orders
FROM products as p
LEFT JOIN
sales as s
ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_orders DESC



   -- Product Popularity and Ranking:
-- Which products are the most popular based on sales volume and revenue

WITH ProductSales AS (
  SELECT
    p.product_name,
    SUM(s.total) AS total_sales,
    ROW_NUMBER() OVER (ORDER BY SUM(s.total) DESC) AS product_rank
  FROM
    sales s
  JOIN products p ON s.product_id = p.product_id
  GROUP BY
    p.product_name
)
SELECT
  product_name,
  total_sales,
  product_rank
FROM
  ProductSales;
  


    -- Customer Segmentation by city
-- How many unique customers are there in each city who have purchased coffee products?

SELECT 
	ct.city_name,
	COUNT(DISTINCT c.customer_id) as unique_customers
FROM city as ct
LEFT JOIN
customers as c
ON c.city_id = ct.city_id
JOIN sales as s
ON s.customer_id = c.customer_id
WHERE 
	s.product_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)
GROUP BY ct.city_name

-- segmentation by purchase count 
WITH CustomerPurchases AS (
  SELECT
    c.customer_id,
    c.customer_name,
    COUNT(*) AS purchase_count,
    AVG(s.total) AS average_order_value
  FROM
    sales s
  JOIN customers c ON s.customer_id = c.customer_id
  GROUP BY
    c.customer_id,
    c.customer_name
)
SELECT
  customer_id,
  customer_name,
  purchase_count,
  average_order_value
FROM
  CustomerPurchases;
  
  
  
   -- City-wise Performance and Ranking:
-- Which cities have the highest sales volume and revenue

WITH CitySales AS (
  SELECT
    ct.city_name,
    SUM(s.total) AS total_sales,
    ROW_NUMBER() OVER (ORDER BY SUM(s.total) DESC) AS city_rank
  FROM
    sales s
  JOIN customers c ON s.customer_id = c.customer_id
  JOIN city ct ON c.city_id=ct.city_id

  GROUP BY
    ct.city_name
)
SELECT
  city_name,
  total_sales,
  city_rank
FROM
  CitySales;
  
  
  

   -- Population and Economic Factors:
-- How does the population and estimated rent of a city correlate with its sales performance

SELECT 
    ct.city_name, 
    ct.population, 
    ct.estimated_rent, 
    SUM(s.total) AS total_sales
FROM 
    sales s
INNER JOIN 
    customers c ON s.customer_id = c.customer_id
INNER JOIN 
    city ct ON c.city_id = ct.city_id
GROUP BY 
    ct.city_name, ct.population, ct.estimated_rent
ORDER BY 
    total_sales DESC;
    
    
    

   -- Average rating breakdown by 
-- product:

SELECT
  p.product_name,
  AVG(s.rating) AS average_customer_satisfaction
FROM
  sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY
  p.product_name;
  

    -- Average rating breakdown by 
-- City:

SELECT
  ct.city_name,
  AVG(s.rating) AS average_city_rating
FROM
  sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ct ON c.city_id=ct.city_id
GROUP BY
  ct.city_name;
  


   -- Average rating breakdown by 
-- Time Period:

SELECT
  YEAR(sale_date) AS year,
  MONTH(sale_date) AS month,
  AVG(rating) AS average_monthly_rating
FROM
  sales
GROUP BY
  YEAR(sale_date),
  MONTH(sale_date);




   -- Low-rated products or cities:
-- Low-rated products:

SELECT
  p.product_name,
  AVG(s.rating) AS average_product_rating
FROM
  sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY
  p.product_name
HAVING
  AVG(s.rating) < (SELECT AVG(rating) FROM sales);
  


-- Low-rated cities:

SELECT
  ct.city_name,
  AVG(s.rating) AS average_city_rating
FROM
  sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ct ON c.city_id=ct.city_id
GROUP BY
  ct.city_name
HAVING
  AVG(s.rating) < (SELECT AVG(rating) FROM sales);
  
  
  


-- Trends in customer satisfaction over time:

SELECT
  YEAR(sale_date) AS year,
  MONTH(sale_date) AS month,
  AVG(rating) AS average_monthly_rating
FROM
  sales
GROUP BY
  YEAR(sale_date),
  MONTH(sale_date)
ORDER BY
  YEAR(sale_date),
  MONTH(sale_date);




    -- Recommendation of Top Three Cities for Coffee Shop Expansion: 
-- Consider factors like total sales, customer satisfaction, city rank, and estimated rent to make recommendations.

WITH CityPerformance AS (
  SELECT
    ct.city_name,
    SUM(s.total) AS total_sales,
    AVG(s.rating) AS average_rating,
    ct.city_rank,
    ct.estimated_rent
  FROM
    sales s
  JOIN customers c ON s.customer_id = c.customer_id
  JOIN city ct ON c.city_id = ct.city_id
  GROUP BY
    ct.city_name, ct.city_rank, ct.estimated_rent
)
SELECT
  city_name,
  total_sales,
  average_rating,
  city_rank,
  estimated_rent
FROM
  CityPerformance
ORDER BY
  total_sales DESC,
  average_rating DESC,
  city_rank ASC,
  estimated_rent ASC
LIMIT 3;



/*
-- Recomendation
City 1: Pune
	1.Estimated rent is very low
	2.Total sales are very high
	3.The average rating/customer satisfaction is also good
    4.City rank is also under 10

City 2: Chennai
	1.Estimated rent is reasonably low
	2.Total sales are also high
	3.The average ratig/customer satisfaction is High
    4.City rank is also acceptable

City 3: Bangalore
	1.Having 1st city rank
	2.Average rating/customer rating is good
	3.Total sales are good
    4.Estimated rent is also okey for 1st ranked city