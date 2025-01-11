CREATE Database project2;
 SELECT * FROM df_orders;
 
 -- find top 10 highest reveue generating products 
SELECT product_id, ROUND(SUM(sale_price),2) AS total_revenue
FROM df_orders
GROUP BY product_id
ORDER BY total_revenue DESC
LIMIT 10;

-- find top 5 highest selling products in each region
WITH cte AS (
    SELECT region, product_id, SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY region, product_id
)
SELECT region, product_id, sales
FROM (
    SELECT region, product_id, sales,
           ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales DESC) AS rn
    FROM cte
) A
WHERE rn <= 5;

-- find month over month growth comparison for 2022 and 2023 sales 
WITH cte AS (
    SELECT 
        YEAR(order_date) AS order_year, 
        MONTH(order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    order_month,
    ROUND(SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END),2) AS sales_2022,
    ROUND(SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END),2) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;

-- for each category which month had highest sales 
WITH cte AS (
    SELECT 
        category, 
        DATE_FORMAT(order_date, '%Y%m') AS order_year_month,
        ROUND(SUM(sale_price),2) AS sales
    FROM df_orders
    GROUP BY category, DATE_FORMAT(order_date, '%Y%m')
)
SELECT category, order_year_month, sales
FROM (
    SELECT category, order_year_month, sales,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
    FROM cte
) a
WHERE rn = 1;

-- which sub category had highest growth by profit in 2023 compare to 2022
WITH cte AS (
    SELECT 
        sub_category, 
        YEAR(order_date) AS order_year,
        SUM(profit) AS total_profit
    FROM df_orders
    GROUP BY sub_category, YEAR(order_date)
)
, cte2 AS (
    SELECT 
        sub_category,
       ROUND( SUM(CASE WHEN order_year = 2022 THEN total_profit ELSE 0 END),2) AS profit_2022,
        ROUND(SUM(CASE WHEN order_year = 2023 THEN total_profit ELSE 0 END),2) AS profit_2023
    FROM cte
    GROUP BY sub_category
)
SELECT sub_category, profit_2022, profit_2023, 
       (profit_2023 - profit_2022) AS profit_growth
FROM cte2
ORDER BY profit_growth DESC
LIMIT 1;

