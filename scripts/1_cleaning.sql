SELECT *
FROM online_retail
;

-- duplicate
-- standardize
-- nulls & blanks 
-- remove column

-- DEDUPLICATE
CREATE TABLE staging
LIKE online_retail
;

INSERT staging
SELECT *
FROM online_retail
;
SELECT *,
ROW_NUMBER() OVER(PARTITION BY `InvoiceNo`, `StockCode`, `Description`, 
`Quantity`, `InvoiceDate`, `UnitPrice`, `CustomerID`, `Country`) AS row_num
FROM staging
;
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY `InvoiceNo`, `StockCode`, `Description`, 
`Quantity`, `InvoiceDate`, `UnitPrice`, `CustomerID`, `Country`) AS row_num
FROM staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1
;
CREATE TABLE `staging2` (
  `index` int DEFAULT NULL,
  `InvoiceNo` int DEFAULT NULL,
  `StockCode` text,
  `Description` text,
  `Quantity` int DEFAULT NULL,
  `InvoiceDate` text,
  `UnitPrice` double DEFAULT NULL,
  `CustomerID` double DEFAULT NULL,
  `Country` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY `InvoiceNo`, `StockCode`, `Description`, 
`Quantity`, `InvoiceDate`, `UnitPrice`, `CustomerID`, `Country`) AS row_num
FROM staging
;
DELETE
FROM staging2
WHERE row_num > 1
;
SELECT *
FROM staging2
WHERE row_num > 1
;

-- STANDARDIZATION
SELECT DISTINCT `country`
FROM staging2
;
SELECT `country`, trim(`country`)
FROM staging2
;
UPDATE staging2
SET `country` = trim(`country`)
;
UPDATE staging2
SET `description` = upper(trim(`description`))
;
SELECT `InvoiceDate`,
str_to_date(`InvoiceDate`, '%m/%d/%Y %H:%i')
FROM staging2
;
UPDATE staging2
SET `InvoiceDate` = str_to_date(`InvoiceDate`, '%m/%d/%Y %H:%i')
;
ALTER TABLE staging2
MODIFY COLUMN `InvoiceDate` DATETIME
;
ALTER TABLE staging2
ADD COLUMN `date` DATE,
ADD COLUMN `time` TIME
;
SELECT *
FROM staging2
;
UPDATE staging2
SET `date` = DATE(`InvoiceDate`),
`time` = TIME(`InvoiceDate`)
;

SELECT *
FROM staging2
WHERE `UnitPrice` = ''
;
SELECT *
FROM staging2
WHERE `Description` = 'ORGANISER WOOD ANTIQUE WHITE'
;
SELECT `unitprice`, count(*)
FROM staging2
WHERE `Description` = 'PAPER BUNTING RETROSPOT'
GROUP BY UnitPrice
;

UPDATE staging2
SET `unitprice` = '7.95'
WHERE `description` = 'ROUND CAKE TIN VINTAGE GREEN' AND `unitprice` = 6.95
;
UPDATE staging2
SET `unitprice` = '5.95'
WHERE `description` = 'ADVENT CALENDAR GINGHAM SACK' AND `unitprice` = 0
;
UPDATE staging2
SET `unitprice` = '12.75'
WHERE `description` = 'REGENCY CAKESTAND 3 TIER'
;
UPDATE staging2
SET `unitprice` = '2.95'
WHERE `description` = 'PAPER BUNTING RETROSPOT'
;
UPDATE staging2
SET `unitprice` = '1.65'
WHERE `description` = 'PLASTERS IN TIN SKULLS'
;
UPDATE staging2
SET `unitprice` = '8.50'
WHERE `description` = 'ORGANISER WOOD ANTIQUE WHITE'
;
ALTER TABLE staging2
DROP COLUMN row_num
;

-- OR

WITH RefPrice AS (
    SELECT `Customer ID`, `Category`
    FROM (
        SELECT `Customer ID`, `Category`, 
               ROW_NUMBER() OVER(PARTITION BY `Customer ID` ORDER BY COUNT(*) DESC) as ranking
        FROM superstore_staging2
        WHERE `Category` != '0'
        GROUP BY `Customer ID`, `Category`
    ) as sub
    WHERE ranking = 1
)
UPDATE superstore_staging2 AS t1
JOIN RefPrice AS t2 ON t1.`Customer ID` = t2.`Customer ID`
SET t1.`Category` = t2.`Category`
WHERE t1.`Category` = '0'
;

