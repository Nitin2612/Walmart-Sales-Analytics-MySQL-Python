# Walmart-Sales-Analytics-MySQL-Python
-- ============================================================================
-- WALMART SALES DATA ANALYSIS - SQL QUERIES
-- ============================================================================
-- Author: [Your Name]
-- Created: October 2025
-- Database: MySQL
-- Purpose: Business intelligence queries for Walmart retail analytics
-- Dataset: 10,000+ sales transactions across multiple branches
-- ============================================================================


-- ============================================================================
-- Q1: PAYMENT METHOD ANALYSIS
-- Business Question: Which payment methods generate the most revenue?
-- Business Impact: Optimize payment processing fees and customer preferences
-- ============================================================================

SELECT 
    payment_method,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT invoice_id) AS unique_invoices,
    ROUND(SUM(total), 2) AS total_revenue,
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


-- ============================================================================
-- Q2: HIGHEST-RATED CATEGORY BY BRANCH
-- Business Question: Which product categories have best customer satisfaction?
-- Business Impact: Guide inventory and marketing strategies per location
-- ============================================================================

SELECT 
    branch,
    city,
    category,
    ROUND(AVG(rating), 2) AS avg_rating,
    COUNT(*) AS total_transactions,
    ROUND(SUM(total), 2) AS total_revenue
FROM 
    walmart
GROUP BY 
    branch, city, category
HAVING 
    AVG(rating) IS NOT NULL
ORDER BY 
    branch, avg_rating DESC;


-- ============================================================================
-- Q3: BUSIEST DAY ANALYSIS
-- Business Question: Which day has the most customer traffic per branch?
-- Business Impact: Optimize staffing schedules and inventory planning
-- ============================================================================

SELECT 
    branch,
    city,
    DAYNAME(date) AS day_of_week,
    COUNT(invoice_id) AS total_transactions,
    ROUND(SUM(total), 2) AS total_revenue,
    ROUND(AVG(total), 2) AS avg_transaction_value
FROM 
    walmart
GROUP BY 
    branch, city, day_of_week
ORDER BY 
    branch, total_transactions DESC;


-- ============================================================================
-- Q4: SHIFT PERFORMANCE ANALYSIS
-- Business Question: When are customers most active (Morning/Afternoon/Evening)?
-- Business Impact: Optimize staff scheduling and resource allocation
-- ============================================================================

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


-- ============================================================================
-- Q5: PROFITABILITY BY CATEGORY
-- Business Question: Which product categories generate the highest profit?
-- Business Impact: Focus on high-margin products and optimize pricing
-- ============================================================================

SELECT 
    category,
    ROUND(SUM(total * profit_margin / 100), 2) AS total_profit,
    ROUND(AVG(profit_margin), 2) AS avg_profit_margin_pct,
    ROUND(SUM(total), 2) AS total_revenue,
    SUM(quantity) AS total_quantity_sold,
    ROUND((SUM(total * profit_margin / 100) / SUM(total) * 100), 2) AS overall_profit_margin_pct
FROM 
    walmart
GROUP BY 
    category
ORDER BY 
    total_profit DESC;


-- ============================================================================
-- Q6: RATING ANALYSIS BY CITY
-- Business Question: Do customer ratings vary across different cities?
-- Business Impact: Identify regional preferences and quality issues
-- ============================================================================

SELECT 
    city,
    category,
    ROUND(AVG(rating), 2) AS avg_rating,
    COUNT(*) AS total_reviews,
    ROUND(MIN(rating), 2) AS min_rating,
    ROUND(MAX(rating), 2) AS max_rating
FROM 
    walmart
GROUP BY 
    city, category
ORDER BY 
    city, avg_rating DESC;


-- ============================================================================
-- Q7: YEAR-OVER-YEAR REVENUE DECLINE
-- Business Question: Which locations show declining sales trends?
-- Business Impact: Identify underperforming branches for intervention
-- ============================================================================

SELECT 
    city,
    branch,
    ROUND(SUM(CASE WHEN YEAR(date) = YEAR(CURDATE()) - 1 THEN total ELSE 0 END), 2) AS sales_last_year,
    ROUND(SUM(CASE WHEN YEAR(date) = YEAR(CURDATE()) THEN total ELSE 0 END), 2) AS sales_this_year,
    ROUND(
        (SUM(CASE WHEN YEAR(date) = YEAR(CURDATE()) THEN total ELSE 0 END) - 
         SUM(CASE WHEN YEAR(date) = YEAR(CURDATE()) - 1 THEN total ELSE 0 END)) /
        NULLIF(SUM(CASE WHEN YEAR(date) = YEAR(CURDATE()) - 1 THEN total ELSE 0 END), 0) * 100, 
    2) AS pct_change,
    ROUND(
        SUM(CASE WHEN YEAR(date) = YEAR(CURDATE()) THEN total ELSE 0 END) - 
        SUM(CASE WHEN YEAR(date) = YEAR(CURDATE()) - 1 THEN total ELSE 0 END), 
    2) AS revenue_difference
FROM 
    walmart
GROUP BY 
    city, branch
HAVING revenue_difference < 0
ORDER BY 
    pct_change ASC;


-- ============================================================================
-- Q8: HOLIDAY SEASON PERFORMANCE
-- Business Question: Which products/stores performed best during holidays?
-- Business Impact: Plan inventory and promotions for upcoming holiday season
-- ============================================================================

SELECT 
    branch,
    city,
    category,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(total), 2) AS total_revenue,
    ROUND(AVG(total), 2) AS avg_transaction_value,
    ROUND(SUM(total * profit_margin / 100), 2) AS total_profit
FROM 
    walmart
WHERE 
    YEAR(date) = YEAR(CURDATE()) - 1  -- Last year
    AND MONTH(date) BETWEEN 11 AND 12  -- November & December (holiday season)
GROUP BY 
    branch, city, category
ORDER BY 
    total_revenue DESC, total_units_sold DESC
LIMIT 20;


-- ============================================================================
-- BONUS: ADVANCED ANALYTICS QUERIES
-- ============================================================================

-- Customer Satisfaction by Payment Method
SELECT 
    payment_method,
    ROUND(AVG(rating), 2) AS avg_rating,
    COUNT(CASE WHEN rating >= 4.0 THEN 1 END) AS satisfied_customers,
    COUNT(CASE WHEN rating < 3.0 THEN 1 END) AS dissatisfied_customers,
    ROUND((COUNT(CASE WHEN rating >= 4.0 THEN 1 END) * 100.0 / COUNT(*)), 2) AS satisfaction_rate_pct
FROM 
    walmart
GROUP BY 
    payment_method
ORDER BY 
    avg_rating DESC;


-- ============================================================================
-- END OF SQL QUERIES
-- ============================================================================
```

---

## **Commit Message for GitHub:**

**Commit summary:**
```
Add comprehensive SQL business intelligence queries
```

**Extended description:**
```
- 8 business-focused SQL queries for Walmart sales analysis
- Payment method performance and customer preferences (Q1)
- Category ratings by branch location (Q2)
- Weekly traffic patterns and busiest days (Q3)
- Shift-based performance analysis (Q4)
- Profitability analysis by category (Q5)
- Regional rating variations (Q6)
- Year-over-year revenue decline detection (Q7)
- Holiday season performance insights (Q8)
- Added business context and impact statements
- Includes bonus query for satisfaction analysis
