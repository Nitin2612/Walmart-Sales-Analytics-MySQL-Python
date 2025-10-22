-- Q1: Payment Method Analysis - Transaction Count, Total Spending, and Average Transaction Value

SELECT 
    payment_method,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT invoice_id) AS unique_invoices,
    SUM(total) AS total_revenue,
    ROUND(AVG(total), 2) AS avg_transaction_value,
    SUM(quantity) AS total_items_sold,
    ROUND(AVG(quantity), 2) AS avg_items_per_transaction,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM walmart)), 2) AS transaction_percentage
FROM 
    walmart
GROUP BY 
    payment_method
ORDER BY 
    total_revenue DESC;

-- Q2: Highest-Rated Product Category by Branch Location

SELECT 
    branch,
    city,
    category,
    ROUND(AVG(rating), 2) AS avg_rating
FROM 
    walmart
GROUP BY 
    branch, city, category
HAVING 
    AVG(rating) IS NOT NULL
ORDER BY 
    branch, avg_rating DESC;


-- Q3: Busiest Day of the Week for Each Branch

SELECT 
    branch,
    city,
    DAYNAME(date) AS day_of_week,
    COUNT(invoice_id) AS total_transactions
FROM 
    walmart
GROUP BY 
    branch, city, day_of_week
ORDER BY 
    branch, total_transactions DESC;

-- Q4 Simple: Basic Shift Analysis (No Window Functions)

SELECT 
    CASE 
        WHEN HOUR(time) >= 6 AND HOUR(time) < 12 THEN 'Morning (6AM-12PM)'
        WHEN HOUR(time) >= 12 AND HOUR(time) < 18 THEN 'Afternoon (12PM-6PM)'
        WHEN HOUR(time) >= 18 AND HOUR(time) < 24 THEN 'Evening (6PM-12AM)'
        ELSE 'Night (12AM-6AM)'
    END AS shift,
    
    COUNT(*) AS total_transactions,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM walmart)), 2) AS pct_of_total_transactions,
    
    SUM(quantity) AS total_items_sold,
    
    ROUND(SUM(total), 2) AS total_revenue,
    ROUND((SUM(total) * 100.0 / (SELECT SUM(total) FROM walmart)), 2) AS pct_of_total_revenue,
    ROUND(AVG(total), 2) AS avg_transaction_value,
    
    ROUND(SUM(total * profit_margin / 100), 2) AS total_profit,
    ROUND(AVG(profit_margin), 2) AS avg_profit_margin_pct,
    
    ROUND(AVG(rating), 2) AS avg_rating,
    COUNT(CASE WHEN rating >= 4.0 THEN 1 END) AS satisfied_customers
    
FROM 
    walmart
GROUP BY 
    shift
ORDER BY 
    FIELD(shift, 'Morning (6AM-12PM)', 'Afternoon (12PM-6PM)', 'Evening (6PM-12AM)', 'Night (12AM-6AM)');

-- Q5. Which product categories bring in the most profit?

SELECT 
    category,
    ROUND(SUM(profit_margin), 2) AS total_profit,
    ROUND(AVG(profit_margin), 2) AS avg_profit_per_item,
    SUM(quantity) AS total_quantity_sold
FROM 
    walmart
GROUP BY 
    category
ORDER BY 
    total_profit DESC;
    
-- Q6. Do product ratings differ from one city to another?

SELECT 
    city,
    category,
    ROUND(AVG(rating), 2) AS avg_rating
FROM 
    walmart
GROUP BY 
    city, category
ORDER BY 
    city, avg_rating DESC;

-- Q7. Which Walmart locations sold a lot less this year compared to last year?

SELECT 
    city,
    ROUND(SUM(CASE WHEN YEAR(date) = 2024 THEN total ELSE 0 END), 2) AS sales_last_year,
    ROUND(SUM(CASE WHEN YEAR(date) = 2025 THEN total ELSE 0 END), 2) AS sales_this_year,
    ROUND(
        SUM(CASE WHEN YEAR(date) = 2025 THEN total ELSE 0 END) - 
        SUM(CASE WHEN YEAR(date) = 2024 THEN total ELSE 0 END), 2
    ) AS difference
FROM 
    walmart
GROUP BY 
    city
HAVING difference < 0
ORDER BY 
    difference ASC;
    
-- Q8. Which products and stores sold the most during last year's holiday season?

SELECT 
    branch,
    city,
    category,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(total), 2) AS total_revenue
FROM 
    walmart
WHERE 
    YEAR(date) = 2024  -- 👈 last year
    AND MONTH(date) BETWEEN 11 AND 12  -- 👈 November & December (holiday season)
GROUP BY 
    branch, city, category
ORDER BY 
    total_units_sold DESC, total_revenue DESC
LIMIT 20;

