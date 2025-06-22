#  Coffee Sales Data Analysis with PostgreSQL

This project presents an in-depth **data analysis on coffee product sales** across multiple cities using **PostgreSQL**. It involves schema design, data modeling, and writing complex SQL queries to derive business insights.


## Overview

The dataset is modeled with four main entities:
- `city`: Information about different cities, including population and rent estimates.
- `customers`: Customers located in specific cities.
- `products`: Coffee product listings with pricing.
- `sales`: Detailed records of sales transactions, including date, product, customer, amount, and rating.

# Schema

    DROP TABLE IF EXISTS sales;
    DROP TABLE IF EXISTS customers;
    DROP TABLE IF EXISTS products;
    DROP TABLE IF EXISTS city;
    
    
    CREATE TABLE city
    (
    	city_id	INT PRIMARY KEY,
    	city_name VARCHAR(15),	
    	population BIGINT,
    	estimated_rent FLOAT,
    	city_rank INT
    );
    
    CREATE TABLE customers
    (
    	customer_id INT PRIMARY KEY,	
    	customer_name VARCHAR(25),	
    	city_id INT,
    	CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id)
    );
    
    
    CREATE TABLE products
    (
    	product_id	INT PRIMARY KEY,
    	product_name VARCHAR(35),	
    	Price float
    );
    
    
    CREATE TABLE sales
    (
    	sale_id	INT PRIMARY KEY,
    	sale_date date,
    	product_id INT,
    	customer_id INT,
    	total FLOAT,
    	rating INT,
    	CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),
    	CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
    );
    

 # How many people in each city are estimated to consume coffee?

        SELECT 
            city_name,
            ROUND((population * 0.25) / 1000000, 2) AS coffee_consumers_in_millions,
            city_rank 
        FROM city
        ORDER BY coffee_consumers_in_millions DESC;

# What is the total revenue generated from coffee sales per city?

        SELECT 
            ci.city_name,
            ROUND(SUM(s.total)::numeric, 2) AS total_revenue
        FROM sales s 
        JOIN customers c ON s.customer_id = c.customer_id
        JOIN city ci ON c.city_id = ci.city_id
        GROUP BY ci.city_name
        ORDER BY total_revenue DESC;


 # How many units of each coffee product have been sold?

        SELECT 
            p.product_name,
            COUNT(s.sale_id) AS units_sold
        FROM products p
        JOIN sales s ON p.product_id = s.product_id
        GROUP BY p.product_name
        ORDER BY units_sold DESC;

# What is the average sales amount per customer in each city?

    SELECT 
        ci.city_name,
        ROUND(AVG(s.total)::numeric, 2) AS avg_sales_per_customer
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN city ci ON c.city_id = ci.city_id
    GROUP BY ci.city_name
    ORDER BY avg_sales_per_customer DESC;

# City Population and Coffee Consumers

    SELECT 
        city_name,
        population,
        ROUND(population * 0.25) AS estimated_coffee_consumers
    FROM city
    ORDER BY estimated_coffee_consumers DESC;


# What are the top 3 selling products in each city?
    
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

# How many unique customers are there in each city who have purchased coffee products?
    
    SELECT 
        ci.city_name,
        COUNT(DISTINCT c.customer_id) AS unique_customers
    FROM customers c
    JOIN city ci ON c.city_id = ci.city_id
    JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY ci.city_name
    ORDER BY unique_customers DESC;

# What’s the average sale and average rent per customer by city?
    
    SELECT 
        ci.city_name,
        ROUND((SUM(s.total) / COUNT(DISTINCT c.customer_id))::numeric, 2) AS avg_sale_per_customer,
        ROUND(ci.estimated_rent::numeric, 2) AS avg_rent_per_customer
    FROM city ci
    JOIN customers c ON ci.city_id = c.city_id
    JOIN sales s ON s.customer_id = c.customer_id
    GROUP BY ci.city_name, ci.estimated_rent
    ORDER BY avg_sale_per_customer DESC;
    

# What is the monthly sales trend and growth rate?
    
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


 # Market Potential: Top 3 Cities by Revenue with Rent, Customers & Coffee Consumers

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

## Screenshot

![Screenshot 2025-06-22 201033](https://github.com/user-attachments/assets/b03ef2e5-3c86-4030-810d-4dacdd52cf11)

