-- EXPLORATORY DATA ANALYSIS

SELECT *
FROM retail_staging2
;

-- Monthly Sales Revenue Trend
SELECT monthname(`date`),
round(sum(`Quantity` * `UnitPrice`), 2) AS sales
FROM retail_staging2
GROUP BY monthname(`date`)
ORDER BY sales
;

-- Top International Markets (Excluding UK)
SELECT Country, count(DISTINCT `CustomerID`) AS customer,
round(sum(`Quantity` * `UnitPrice`), 2) AS sales
FROM retail_staging2
WHERE Country != 'United Kingdom'
GROUP BY Country
ORDER BY sales DESC
;

-- Top 10 High-Value Customers (Revenue & Frequency)
SELECT `CustomerID`,
count(DISTINCT `InvoiceNo`) AS `transaction`,
round(sum(`Quantity` * `UnitPrice`), 2) AS sales
FROM retail_staging2
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY sales DESC
LIMIT 10
;

-- Peak Transaction Hours Analysis
SELECT hour(`time`) AS hour_of_day,
count(DISTINCT `InvoiceNo`) AS 'orders'
FROM retail_staging2
GROUP BY hour_of_day
ORDER BY orders DESC
;

-- Best-Selling Products by Volume and Revenue
SELECT `Description`,
sum(`Quantity`) AS pcs,
round(sum(`Quantity` * `UnitPrice`), 2) AS sales
FROM retail_staging2
GROUP BY `Description`
ORDER BY pcs DESC
;


