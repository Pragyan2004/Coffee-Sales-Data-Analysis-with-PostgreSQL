
select * from sales;
select * from customers;
select * from products;
select * from city;

select 
city_name,
round((population*0.25)/1000000,2) as coffee_consumers_in_millions,
city_rank from city
order by 2 desc


SELECT 
    ci.city_name,
    ROUND(SUM(s.total)::numeric, 2) AS total_revenue
FROM sales AS s 
JOIN customers AS c ON s.customer_id = c.customer_id
JOIN city AS ci ON c.city_id = ci.city_id
GROUP BY ci.city_name
ORDER BY total_revenue DESC;

SELECT 
    p.product_name,
    COUNT(s.sale_id) AS units_sold
FROM products p
JOIN sales s ON p.product_id = s.product_id
GROUP BY p.product_name
ORDER BY units_sold DESC;

SELECT 
    ci.city_name,
    ROUND(AVG(s.total)::numeric, 2) AS avg_sales_per_customer
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON c.city_id = ci.city_id
GROUP BY ci.city_name
ORDER BY avg_sales_per_customer DESC;

SELECT 
    ci.city_name,
    ROUND(AVG(s.total)::numeric, 2) AS avg_sales_per_customer
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON c.city_id = ci.city_id
GROUP BY ci.city_name
ORDER BY avg_sales_per_customer DESC;

SELECT 
    city_name,
    population,
    ROUND(population * 0.25) AS estimated_coffee_consumers
FROM city
ORDER BY estimated_coffee_consumers DESC;

SELECT *
FROM (
    SELECT 
        ci.city_name,
        p.product_name,
        COUNT(s.sale_id) AS units_sold,
        RANK() OVER (PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) AS product_rank
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN city ci ON c.city_id = ci.city_id
    JOIN products p ON s.product_id = p.product_id
    GROUP BY ci.city_name, p.product_name
) ranked_products
WHERE product_rank <= 3
ORDER BY city_name, product_rank;

SELECT 
    ci.city_name,
    COUNT(DISTINCT c.customer_id) AS unique_customers
FROM customers c
JOIN city ci ON c.city_id = ci.city_id
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY ci.city_name
ORDER BY unique_customers DESC;


SELECT 
    ci.city_name,
    ROUND((SUM(s.total) / COUNT(DISTINCT c.customer_id))::numeric, 2) AS avg_sale_per_customer,
    ROUND(ci.estimated_rent::numeric, 2) AS avg_rent_per_customer
FROM city ci
JOIN customers c ON ci.city_id = c.city_id
JOIN sales s ON s.customer_id = c.customer_id
GROUP BY ci.city_name, ci.estimated_rent
ORDER BY avg_sale_per_customer DESC;

SELECT 
    TO_CHAR(sale_date, 'YYYY-MM') AS month,
    ROUND(SUM(total)::numeric, 2) AS total_sales,
    ROUND((
        (SUM(total) - LAG(SUM(total)) OVER (ORDER BY TO_CHAR(sale_date, 'YYYY-MM')))
        / NULLIF(LAG(SUM(total)) OVER (ORDER BY TO_CHAR(sale_date, 'YYYY-MM')), 0)
    )::numeric * 100, 2) AS sales_growth_percent
FROM sales
GROUP BY TO_CHAR(sale_date, 'YYYY-MM')
ORDER BY month;


SELECT *
FROM (
    SELECT 
        ci.city_name,
        ROUND(SUM(s.total)::numeric, 2) AS total_sales,
        ROUND((ci.estimated_rent * COUNT(DISTINCT c.customer_id))::numeric, 2) AS total_rent,
        COUNT(DISTINCT c.customer_id) AS total_customers,
        ROUND((ci.population * 0.25)::numeric, 0) AS estimated_coffee_consumers,
        RANK() OVER (ORDER BY SUM(s.total) DESC) AS city_rank
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN city ci ON c.city_id = ci.city_id
    GROUP BY ci.city_name, ci.estimated_rent, ci.population
) top_cities
WHERE city_rank <= 3
ORDER BY city_rank;
