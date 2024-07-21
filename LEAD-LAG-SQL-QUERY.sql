How can you use LEAD and LAG functions to calculate a running total or moving average?

1. Query calculates the number of days between consecutive orders by using the LAG function to access the date of the previous order.

SELECT
    order_id,
    order_date,
    LAG(order_date, 1) OVER (ORDER BY order_date) AS previous_order_date,
    DATEDIFF(day, LAG(order_date, 1) OVER (ORDER BY order_date), order_date) AS days_between_orders
FROM
    orders;

2. calculates the difference between the current transaction amount and the previous transaction amount using the LAG function.

SELECT
    transaction_id,
    amount,
    LAG(amount, 1) OVER (ORDER BY transaction_date) AS previous_amount,
    amount - LAG(amount, 1) OVER (ORDER BY transaction_date) AS amount_difference
FROM
    transactions;
	
3. compare total sales from the last quarter to the current quarter using SQL.

WITH quarterly_sales AS (
    SELECT
        CASE
            WHEN DATEPART(QUARTER, sale_date) = DATEPART(QUARTER, GETDATE()) 
                 AND DATEPART(YEAR, sale_date) = DATEPART(YEAR, GETDATE()) THEN 'Current Quarter'
            WHEN DATEPART(QUARTER, sale_date) = DATEPART(QUARTER, DATEADD(QUARTER, -1, GETDATE())) 
                 AND DATEPART(YEAR, sale_date) = DATEPART(YEAR, DATEADD(QUARTER, -1, GETDATE())) THEN 'Last Quarter'
            ELSE 'Other'
        END AS quarter,
        SUM(amount) AS total_sales
    FROM sales
    WHERE sale_date >= DATEADD(QUARTER, -1, GETDATE()) -- Ensuring we only get data from the last two quarters
    GROUP BY 
        CASE
            WHEN DATEPART(QUARTER, sale_date) = DATEPART(QUARTER, GETDATE()) 
                 AND DATEPART(YEAR, sale_date) = DATEPART(YEAR, GETDATE()) THEN 'Current Quarter'
            WHEN DATEPART(QUARTER, sale_date) = DATEPART(QUARTER, DATEADD(QUARTER, -1, GETDATE())) 
                 AND DATEPART(YEAR, sale_date) = DATEPART(YEAR, DATEADD(QUARTER, -1, GETDATE())) THEN 'Last Quarter'
    )
SELECT
    quarter,
    total_sales
FROM quarterly_sales
WHERE quarter IN ('Current Quarter', 'Last Quarter');

4. compare total sales from the last year to the current year using SQL.

WITH yearly_sales AS (
    SELECT
        CASE
            WHEN DATEPART(YEAR, sale_date) = DATEPART(YEAR, GETDATE()) THEN 'Current Year'
            WHEN DATEPART(YEAR, sale_date) = DATEPART(YEAR, DATEADD(YEAR, -1, GETDATE())) THEN 'Last Year'
            ELSE 'Other'
        END AS year,
        SUM(amount) AS total_sales
    FROM sales
    WHERE sale_date >= DATEADD(YEAR, -1, GETDATE()) -- Ensuring we only get data from the last two years
    GROUP BY 
        CASE
            WHEN DATEPART(YEAR, sale_date) = DATEPART(YEAR, GETDATE()) THEN 'Current Year'
            WHEN DATEPART(YEAR, sale_date) = DATEPART(YEAR, DATEADD(YEAR, -1, GETDATE())) THEN 'Last Year'
    )
SELECT
    year,
    total_sales
FROM yearly_sales
WHERE year IN ('Current Year', 'Last Year');

5. sql query to Compare the revenue of a company month-over-month :

WITH MonthlyRevenue AS (
    SELECT
        DATEPART(MONTH, sale_date) AS month,
        SUM(revenue) AS total_revenue
    FROM
        sales
    GROUP BY
        DATEPART(MONTH, sale_date)
)
SELECT
    month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY month) AS previous_month_revenue,
    (total_revenue - LAG(total_revenue) OVER (ORDER BY month)) AS revenue_change,
    ROUND(((total_revenue - LAG(total_revenue) OVER (ORDER BY month)) / NULLIF(LAG(total_revenue) OVER (ORDER BY month), 0)) * 100, 2) AS percent_change
FROM
    MonthlyRevenue
ORDER BY
    month;
	
6. Year-over-Year (YoY) Comparison :

WITH YearlyRevenue AS (
    SELECT
        DATEPART('year', sale_date) AS year,
        SUM(revenue) AS total_revenue
    FROM
        sales
    GROUP BY
        DATEPART('year', sale_date)
)
SELECT
    year,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY year) AS previous_year_revenue,
    (total_revenue - LAG(total_revenue) OVER (ORDER BY year)) AS revenue_change,
    ROUND(((total_revenue - LAG(total_revenue) OVER (ORDER BY year)) / NULLIF(LAG(total_revenue) OVER (ORDER BY year), 0)) * 100, 2) AS percent_change
FROM
    YearlyRevenue
ORDER BY
    year;
	
Explanation : 
WITH Clause: Creates a Common Table Expression (CTE) to calculate the total revenue for each month/year.
DATEPART Function: Truncates the date to the specified precision (month or year).
SUM Function: Sums up the revenue for each truncated date.
LAG Function: Accesses data from the previous row in the result set without the need for a self-join, making it efficient.
NULLIF Function: Ensures division by zero is avoided when calculating the percentage change.
ROUND Function: Rounds the percentage change to two decimal places for better readability.

Example Data : Assume we have the following sales table data:

sale_date	revenue
2023-01-15	1000
2023-02-15	1500
2023-03-15	2000
2024-01-15	1100
2024-02-15	1600
2024-03-15	2100

Month-Over-Month Output Example :

month	    total_revenue	previous_month_revenue	revenue_change	percent_change
2023-01-01	1000	        NULL					NULL			NULL
2023-02-01	1500			1000					500				50.00
2023-03-01	2000			1500					500				33.33
2024-01-01	1100			2000					-900			-45.00
2024-02-01	1600			1100					500				45.45
2024-03-01	2100			1600					500				31.25

Year-Over-Year Output Example :
year	    total_revenue	previous_year_revenue	revenue_change	percent_change
2023-01-01	4500	        NULL	                NULL	        NULL
2024-01-01	4800	        4500	                300	            6.67

7. SQL queries to compare expense data across different time frames such as months, quarters, or years.

Expenses (table) -> id (integer), date (date), amount (decimal), category (varchar) (e.g., 'Travel', 'Food', 'Supplies')

Query compares the total expenses month-over-month:

SELECT
    DATEPART(MONTH, date) AS month,
    SUM(amount) AS total_expenses,
    LAG(SUM(amount)) OVER (ORDER BY DATEPART(MONTH, date)) AS previous_month_expenses,
    SUM(amount) - LAG(SUM(amount)) OVER (ORDER BY DATEPART(MONTH, date)) AS change_in_expenses
FROM
    expenses
GROUP BY
    DATEPART(MONTH, date)
ORDER BY
    DATEPART(MONTH, date);
	
Explanation: 

DATEPART(MONTH, date): Truncates the date to the first day of the month, grouping expenses by month.
SUM(amount): Calculates the total expenses for each month.
LAG(SUM(amount)) OVER (ORDER BY DATEPART(MONTH, date)): Retrieves the total expenses of the previous month.
SUM(amount) - LAG(SUM(amount)) OVER (ORDER BY DATEPART(MONTH, date)): Calculates the change in expenses from the previous month.

Sample Output :- Assuming the expenses table contains the following data:

id	date	    amount	category
1	2024-01-15	500	    Travel
2	2024-01-20	200	    Food
3	2024-02-10	300	    Supplies
4	2024-02-15	700	    Travel
5	2024-03-05	400	    Food
6	2024-03-20	600	    Supplies

The query would output:

month	    total_expenses	 previous_month_expenses	change_in_expenses
2024-01-01	700	             NULL	                    NULL
2024-02-01	1000	         700	                    300
2024-03-01	1000	         1000	                    0

In this output:
The total expenses for January 2024 are 700.
The total expenses for February 2024 are 1000, with a change of 300 from January 2024.
The total expenses for March 2024 are 1000, with no change from February 2024.


8. Query to Compare current stock levels with previous periods to optimize inventory control with example :

To compare current stock levels with previous periods and optimize inventory control, you can use SQL queries to analyze inventory data over time. Inventory table -> product_id, product_name, stock_level, date

Let's assume you want to compare the stock levels of each product between the current period (e.g., the latest date) and the previous period (e.g., the previous month).

WITH CurrentPeriod AS (
    SELECT 
        product_id,
        product_name,
        stock_level,
        date AS current_date
    FROM 
        inventory
    WHERE 
        date = (SELECT MAX(date) FROM inventory)
),
PreviousPeriod AS (
    SELECT 
        product_id,
        product_name,
        stock_level,
        date AS previous_date
    FROM 
        inventory
    WHERE 
        date = (
            SELECT MAX(date) 
            FROM inventory 
            WHERE date < (SELECT MAX(date) FROM inventory)
        )
)
SELECT 
    cp.product_id,
    cp.product_name,
    cp.stock_level AS current_stock_level,
    pp.stock_level AS previous_stock_level,
    (cp.stock_level - pp.stock_level) AS stock_change
FROM 
    CurrentPeriod cp
JOIN 
    PreviousPeriod pp
ON 
    cp.product_id = pp.product_id;

Running Total
9. A running total can be calculated using the SUM function with the OVER clause in SQL.

SELECT
    transaction_date,
    amount,
    SUM(amount) OVER (ORDER BY transaction_date) AS running_total
FROM
    transactions;
	
10. Moving Average

A moving average can be calculated using the AVG function with the OVER clause. You can specify a window frame to calculate the moving average. Here’s an example for a 3-day moving average:

SELECT
    transaction_date,
    amount,
    AVG(amount) OVER (ORDER BY transaction_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_average
FROM
    transactions;