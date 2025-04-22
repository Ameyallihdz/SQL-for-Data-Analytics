--IS THE REVENUE SEASONAL?
select SalesOrderID, count(SalesOrderID)
from Sales.SalesOrderHeader
group 
--1.What is the total revenue/profit? (per month & per year)
SELECT 
    ISNULL(FORMAT(H.OrderDate, 'yyyy-MM'), 'TOTAL') AS YearMonth,
    SUM((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) AS Revenue,
    SUM(P.StandardCost * D.OrderQty) AS Cost,
    SUM(((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) AS Profit
FROM 
    Sales.SalesOrderHeader H 
JOIN 
    Sales.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
JOIN 
    Production.Product P ON D.ProductID = P.ProductID

GROUP BY 
    GROUPING SETS ((FORMAT(H.OrderDate, 'yyyy-MM')), ())
ORDER BY 
    CASE 
        WHEN FORMAT(H.OrderDate, 'yyyy-MM') IS NULL THEN 1 
        ELSE 0 
    END,
    YearMonth;

--Just Individual Customer
SELECT 
    ISNULL(FORMAT(H.OrderDate, 'yyyy-MM'), 'TOTAL') AS YearMonth,
    SUM((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) AS Revenue,
    SUM(P.StandardCost * D.OrderQty) AS Cost,
    SUM(((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) AS Profit
FROM 
    Sales.SalesOrderHeader H 
JOIN 
    Sales.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
JOIN 
    Production.Product P ON D.ProductID = P.ProductID
JOIN 
    Sales.Customer C ON H.CustomerID = C.CustomerID
JOIN 
    Person.Person Pe ON C.PersonID = Pe.BusinessEntityID
WHERE
    Pe.PersonType = 'IN'  -- Individual (retail) customers only
GROUP BY 
    GROUPING SETS ((FORMAT(H.OrderDate, 'yyyy-MM')), ())
ORDER BY 
    CASE 
        WHEN FORMAT(H.OrderDate, 'yyyy-MM') IS NULL THEN 1 
        ELSE 0 
    END,
    YearMonth;

--Revenue&Profitability with PersonID & StoreID FINAL 1
SELECT 
    YEAR(H.OrderDate) AS OrderYear,
    DATENAME(MONTH, H.OrderDate) AS OrderMonth,
    MONTH(H.OrderDate) AS OrderMonthNumber,  -- Add this for correct ordering
    C.CustomerID,
    C.StoreID,
    SUM((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) AS Revenue,
    SUM(P.StandardCost * D.OrderQty) AS Cost,
    SUM(((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) AS Profit,
	 CASE 
        WHEN C.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END AS CustomerType
FROM 
    Sales.SalesOrderHeader H
JOIN 
    Sales.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
JOIN 
    Production.Product P ON D.ProductID = P.ProductID
JOIN 
    Sales.Customer C ON H.CustomerID = C.CustomerID
GROUP BY 
    YEAR(H.OrderDate),
    DATENAME(MONTH, H.OrderDate),
    MONTH(H.OrderDate),
    C.CustomerID,
    C.StoreID
ORDER BY 
    OrderYear,
    OrderMonthNumber,
    C.CustomerID;


--2.What is the average of the discounts on a single item?
SELECT 
    YEAR(h.OrderDate) AS OrderYear,
    DATENAME(MONTH, h.OrderDate) AS OrderMonth,
    AVG(d.UnitPriceDiscount) AS AverageDiscount
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader h ON d.SalesOrderID = h.SalesOrderID
GROUP BY YEAR(h.OrderDate), DATENAME(MONTH, h.OrderDate), MONTH(h.OrderDate)
ORDER BY OrderYear, MONTH(h.OrderDate);
--Filtrado
SELECT 
    YEAR(h.OrderDate) AS OrderYear,
    DATENAME(MONTH, h.OrderDate) AS OrderMonth,
    p.PersonType,
    AVG(d.UnitPriceDiscount) AS AverageDiscount
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader h ON d.SalesOrderID = h.SalesOrderID
JOIN Sales.Customer c ON h.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE p.PersonType IN ('IN', 'SC')
GROUP BY YEAR(h.OrderDate), DATENAME(MONTH, h.OrderDate), MONTH(h.OrderDate), p.PersonType
ORDER BY OrderYear, MONTH(h.OrderDate), p.PersonType;
--Average discount on single items by CustomerID/StoreID FINAL
SELECT  
    YEAR(h.OrderDate) AS OrderYear,
    DATENAME(MONTH, h.OrderDate) AS OrderMonth,
    MONTH(h.OrderDate) AS OrderMonthNumber,
    c.CustomerID,
    c.StoreID,
    CASE 
        WHEN c.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END AS CustomerType,
    AVG(d.UnitPriceDiscount) AS AverageDiscount
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader h ON d.SalesOrderID = h.SalesOrderID
JOIN Sales.Customer c ON h.CustomerID = c.CustomerID
GROUP BY 
    YEAR(h.OrderDate),
    DATENAME(MONTH, h.OrderDate),
    MONTH(h.OrderDate),
    c.CustomerID,
    c.StoreID,
    CASE 
        WHEN c.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END
ORDER BY 
    OrderYear,
    OrderMonthNumber,
    c.CustomerID;

--3.What is the quantity of items purchased?
SELECT
    YEAR(h.OrderDate) AS OrderYear,
    DATENAME(MONTH, h.OrderDate) AS OrderMonth,
    SUM(d.OrderQty) AS TotalQuantity,
    p.PersonType -- Corrected PersonType column
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader h ON d.SalesOrderID = h.SalesOrderID
JOIN Sales.Customer c ON h.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
GROUP BY YEAR(h.OrderDate), DATENAME(MONTH, h.OrderDate), MONTH(h.OrderDate), p.PersonType -- Grouping by PersonType
ORDER BY OrderYear, MONTH(h.OrderDate);
--Per item
SELECT
    YEAR(h.OrderDate) AS OrderYear,
    DATENAME(MONTH, h.OrderDate) AS OrderMonth,
    SUM(d.OrderQty) AS TotalQuantity,
    prod.Name AS ProductName -- Replacing PersonType with ProductName
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader h ON d.SalesOrderID = h.SalesOrderID
JOIN Production.Product prod ON d.ProductID = prod.ProductID -- Joining Product table
GROUP BY YEAR(h.OrderDate), DATENAME(MONTH, h.OrderDate), MONTH(h.OrderDate), prod.Name -- Grouping by ProductName
ORDER BY OrderYear, MONTH(h.OrderDate);
--Per item grouped by StoreID/CustomerID FINAL ONE
SELECT
    YEAR(soh.OrderDate) AS OrderYear,
    DATENAME(MONTH, soh.OrderDate) AS OrderMonth,
    c.CustomerID,
    c.StoreID,
    CASE 
        WHEN c.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END AS CustomerType,
    prod.Name AS ProductName,
    SUM(sod.OrderQty) AS TotalQuantity
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product AS prod ON sod.ProductID = prod.ProductID
JOIN Sales.Customer AS c ON soh.CustomerID = c.CustomerID
GROUP BY
    YEAR(soh.OrderDate),
    DATENAME(MONTH, soh.OrderDate),
    MONTH(soh.OrderDate),
    c.CustomerID,
    c.StoreID,
    CASE 
        WHEN c.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END,
    prod.Name
ORDER BY OrderYear, MONTH(soh.OrderDate), CustomerType, c.CustomerID, prod.Name;

--4.How much is the margin (sale price less cost)?
SELECT
    YEAR(soh.OrderDate) AS OrderYear,
    MONTH(soh.OrderDate) AS OrderMonth,
    CASE 
        WHEN c.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END AS CustomerType,
    p.Name AS ProductName,
    SUM((sod.UnitPrice - (sod.UnitPrice * sod.UnitPriceDiscount)) * sod.OrderQty) - SUM(p.StandardCost * sod.OrderQty) AS TotalMargin
FROM
    Sales.SalesOrderDetail AS sod
JOIN
    Production.Product AS p ON sod.ProductID = p.ProductID
JOIN
    Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN
    Sales.Customer AS c ON soh.CustomerID = c.CustomerID
GROUP BY
    YEAR(soh.OrderDate),
    MONTH(soh.OrderDate),
    CASE 
        WHEN c.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END,
    p.Name
ORDER BY
    OrderYear,
    OrderMonth,
    CustomerType,
    ProductName;

--5.What is the average margin (sale price less cost)?
SELECT 
    YEAR(soh.OrderDate) AS OrderYear,
    MONTH(soh.OrderDate) AS OrderMonth,
    CASE 
        WHEN c.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END AS CustomerType,
    p.Name AS ProductName,
    AVG(
        ((sod.UnitPrice - (sod.UnitPrice * sod.UnitPriceDiscount)) * sod.OrderQty) 
        - (p.StandardCost * sod.OrderQty)
    ) AS AverageMargin
FROM 
    Sales.SalesOrderDetail AS sod
JOIN 
    Production.Product AS p ON sod.ProductID = p.ProductID
JOIN
    Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN
    Sales.Customer AS c ON soh.CustomerID = c.CustomerID
GROUP BY 
    YEAR(soh.OrderDate),
    MONTH(soh.OrderDate),
    CASE WHEN c.StoreID IS NULL THEN 'B2C' ELSE 'B2B' END,
    p.Name
ORDER BY
    OrderYear,
    OrderMonth,
    CustomerType,
    ProductName;

--6.What are the monthly and quarterly rankings for the year according to the margin (sale less cost)?
--Monthly sin rankear
SELECT 
    ISNULL(FORMAT(H.OrderDate, 'yyyy-MM'), 'TOTAL') AS YearMonth,
    SUM((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) AS Revenue,
    SUM(P.StandardCost * D.OrderQty) AS Cost,
    SUM(((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) AS Profit,
    CASE 
        WHEN SUM((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) = 0 THEN NULL
        ELSE 
            (SUM(((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) * 100.0) / 
            SUM((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount))
    END AS ProfitMarginPct
FROM 
    Sales.SalesOrderHeader H 
JOIN 
    Sales.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
JOIN 
    Production.Product P ON D.ProductID = P.ProductID
GROUP BY 
    GROUPING SETS ((FORMAT(H.OrderDate, 'yyyy-MM')), ())
ORDER BY 
    CASE 
        WHEN FORMAT(H.OrderDate, 'yyyy-MM') IS NULL THEN 1 
        ELSE 0 
    END,
    YearMonth;
--Monthly rankeando
WITH MonthlyMargins AS (
    SELECT 
        FORMAT(H.OrderDate, 'yyyy-MM') AS YearMonth,
        SUM((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) AS Revenue,
        SUM(P.StandardCost * D.OrderQty) AS Cost,
        SUM(((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) AS Profit,
        CASE 
            WHEN SUM((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) = 0 THEN NULL
            ELSE 
                (SUM(((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) * 100.0) / 
                SUM((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount))
        END AS ProfitMarginPct
    FROM 
        Sales.SalesOrderHeader H 
    JOIN 
        Sales.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
    JOIN 
        Production.Product P ON D.ProductID = P.ProductID
    GROUP BY 
        FORMAT(H.OrderDate, 'yyyy-MM')
)
SELECT 
    *,
    RANK() OVER (ORDER BY ProfitMarginPct DESC) AS MonthlyRank
FROM 
    MonthlyMargins
ORDER BY 
    MonthlyRank;

--Quarterly
WITH QuarterlyMargins AS (
    SELECT 
        CONCAT(YEAR(H.OrderDate), '-Q', DATEPART(QUARTER, H.OrderDate)) AS YearQuarter,
        SUM((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) AS Revenue,
        SUM(P.StandardCost * D.OrderQty) AS Cost,
        SUM(((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) AS Profit,
        CASE 
            WHEN SUM((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) = 0 THEN NULL
            ELSE 
                (SUM(((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) * 100.0) / 
                SUM((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount))
        END AS ProfitMarginPct
    FROM 
        Sales.SalesOrderHeader H 
    JOIN 
        Sales.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
    JOIN 
        Production.Product P ON D.ProductID = P.ProductID
    GROUP BY 
        YEAR(H.OrderDate), DATEPART(QUARTER, H.OrderDate)
)

SELECT 
    *,
    RANK() OVER (ORDER BY ProfitMarginPct DESC) AS QuarterlyRank
FROM 
    QuarterlyMargins
ORDER BY 
    QuarterlyRank;

--Montlhy rankeado & filtrado B2C&B2B
SELECT 
    YEAR(H.OrderDate) AS OrderYear,
    DATENAME(MONTH, H.OrderDate) AS OrderMonth,
    MONTH(H.OrderDate) AS OrderMonthNumber,
    C.CustomerID,
    C.StoreID,
    CASE 
        WHEN C.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END AS CustomerType,
    SUM((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) AS Revenue,
    SUM(P.StandardCost * D.OrderQty) AS Cost,
    SUM(((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) AS Profit,
    CASE 
        WHEN SUM((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) = 0 THEN NULL
        ELSE 
            (SUM(((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) * 100.0) / 
            SUM((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount))
    END AS ProfitMarginPct,
    RANK() OVER (
        PARTITION BY YEAR(H.OrderDate), MONTH(H.OrderDate)
        ORDER BY 
            (SUM(((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) * 100.0) / 
            NULLIF(SUM((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)), 0) DESC
    ) AS MonthlyProfitMarginRank
FROM 
    Sales.SalesOrderHeader H
JOIN 
    Sales.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
JOIN 
    Production.Product P ON D.ProductID = P.ProductID
JOIN 
    Sales.Customer C ON H.CustomerID = C.CustomerID
-- Filtra por tipo de cliente aquí: B2C (retail) o B2B (store)
-- Para B2C: WHERE C.StoreID IS NULL
-- Para B2B: WHERE C.StoreID IS NOT NULL
WHERE 
    C.StoreID IS NULL  -- Cambia esto a NOT NULL si quieres solo B2B
GROUP BY 
    YEAR(H.OrderDate),
    DATENAME(MONTH, H.OrderDate),
    MONTH(H.OrderDate),
    C.CustomerID,
    C.StoreID
ORDER BY 
    OrderYear,
    OrderMonthNumber,
    MonthlyProfitMarginRank;



-- 6. Monthly Ranking by product
With Margin as
				(SELECT
					ISNULL(FORMAT(soh.OrderDate, 'yyyy-MM'), 'TOTAL') AS YearMonth,
					CASE 
						WHEN c.StoreID IS NULL THEN 'B2C'
						ELSE 'B2B'
					END AS CustomerType,
					p.Name AS ProductName,
					SUM((sod.UnitPrice - (sod.UnitPrice * sod.UnitPriceDiscount)) * sod.OrderQty) - SUM(p.StandardCost * sod.OrderQty) AS TotalMargin
				FROM
					Sales.SalesOrderDetail AS sod
				JOIN
					Production.Product AS p ON sod.ProductID = p.ProductID
				JOIN
					Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
				JOIN
					Sales.Customer AS c ON soh.CustomerID = c.CustomerID
				GROUP BY
					soh.OrderDate,
					CASE 
						WHEN c.StoreID IS NULL THEN 'B2C'
						ELSE 'B2B'
					END,
					p.Name)
Select YearMonth,
		ProductName,
		CustomerType,
		TotalMargin,
		Rank () over (partition by YearMonth
					order by TotalMargin) as MonthRank
From Margin

--Quarterly Ranking
With Margin as
				(SELECT
					DATEFROMPARTS(YEAR(soh.OrderDate), ((DATEPART(QUARTER, soh.OrderDate) - 1) * 3 + 1), 1) AS YearQuarter,
					CASE 
						WHEN c.StoreID IS NULL THEN 'B2C'
						ELSE 'B2B'
					END AS CustomerType,
					p.Name AS ProductName,
					SUM((sod.UnitPrice - (sod.UnitPrice * sod.UnitPriceDiscount)) * sod.OrderQty) - SUM(p.StandardCost * sod.OrderQty) AS TotalMargin
				FROM
					Sales.SalesOrderDetail AS sod
				JOIN
					Production.Product AS p ON sod.ProductID = p.ProductID
				JOIN
					Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
				JOIN
					Sales.Customer AS c ON soh.CustomerID = c.CustomerID
				GROUP BY
					DATEFROMPARTS(YEAR(soh.OrderDate), ((DATEPART(QUARTER, soh.OrderDate) - 1) * 3 + 1), 1),
					CASE 
						WHEN c.StoreID IS NULL THEN 'B2C'
						ELSE 'B2B'
					END,
					p.Name)
Select YearQuarter,
		ProductName,
		CustomerType,
		TotalMargin,
		Rank () over (partition by YearQuarter
					order by TotalMargin) as QuarterRank
From Margin


--6.
WITH MarginData AS (
    SELECT
        YEAR(soh.OrderDate) AS OrderYear,
        MONTH(soh.OrderDate) AS OrderMonth,
        DATEPART(QUARTER, soh.OrderDate) AS OrderQuarter,
        CASE 
            WHEN c.StoreID IS NULL THEN 'B2C'
            ELSE 'B2B'
        END AS CustomerType,
        p.Name AS ProductName,
        SUM((sod.UnitPrice - (sod.UnitPrice * sod.UnitPriceDiscount)) * sod.OrderQty) 
            - SUM(p.StandardCost * sod.OrderQty) AS TotalMargin
    FROM
        Sales.SalesOrderDetail AS sod
    JOIN
        Production.Product AS p ON sod.ProductID = p.ProductID
    JOIN
        Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
    JOIN
        Sales.Customer AS c ON soh.CustomerID = c.CustomerID
    GROUP BY
        YEAR(soh.OrderDate),
        MONTH(soh.OrderDate),
        DATEPART(QUARTER, soh.OrderDate),
        CASE 
            WHEN c.StoreID IS NULL THEN 'B2C'
            ELSE 'B2B'
        END,
        p.Name
),
RankedMargins AS (
    SELECT *,
        RANK() OVER (PARTITION BY OrderYear, OrderMonth, CustomerType ORDER BY TotalMargin DESC) AS MonthlyRank,
        RANK() OVER (PARTITION BY OrderYear, OrderQuarter, CustomerType ORDER BY TotalMargin DESC) AS QuarterlyRank
    FROM MarginData
)
SELECT
    OrderYear,
    OrderMonth,
    OrderQuarter,
    CustomerType,
    ProductName,
    TotalMargin,
    MonthlyRank,
    QuarterlyRank
FROM RankedMargins
ORDER BY
    OrderYear,
    OrderMonth,
    CustomerType,
    MonthlyRank;

--7.Examine the results obtained, and formulate at least 3 business conclusions based on those results.

 --Sales
 select *
 from Production.Product pp
 where Name in (select Description from Sales.SpecialOffer so where pp.Name=so.Description)

 select *
 from Sales.SpecialOffer

--Cantidad de ventas por genero
SELECT 
    p.Style AS ProductStyle,
    SUM(sod.OrderQty) AS TotalQuantitySold
FROM 
    Production.Product p
JOIN 
    Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
GROUP BY 
    p.Style
ORDER BY 
    TotalQuantitySold DESC;

--Cantidad de ventas por subcategoria
	SELECT 
    pc.Name AS CategoryName,
    SUM(sod.OrderQty) AS TotalQuantitySold
FROM 
    Sales.SalesOrderDetail sod
JOIN 
    Production.Product p ON sod.ProductID = p.ProductID
JOIN 
    Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN 
    Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY 
    pc.Name
ORDER BY 
    TotalQuantitySold DESC


--Qty de ventas (count) filtrado por StoreID/CXID
SELECT 
    CASE 
        WHEN StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END AS CustomerType,
    COUNT(DISTINCT CustomerID) AS TotalCustomers
FROM 
    Sales.Customer
GROUP BY 
    CASE 
        WHEN StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END;

--Per month and year
SELECT 
    YEAR(soh.OrderDate) AS Year,
    MONTH(soh.OrderDate) AS Month,
    CASE 
        WHEN c.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END AS CustomerType,
    COUNT(DISTINCT soh.CustomerID) AS TotalCustomers
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Sales.Customer c ON soh.CustomerID = c.CustomerID
GROUP BY 
    YEAR(soh.OrderDate),
    MONTH(soh.OrderDate),
    CASE 
        WHEN c.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END
ORDER BY 
    Year, Month, CustomerType;

--Per month and year separated into columns (B2B, B2C)
	SELECT 
    YEAR(soh.OrderDate) AS Year,
    MONTH(soh.OrderDate) AS Month,
    COUNT(DISTINCT CASE WHEN c.StoreID IS NULL THEN soh.CustomerID END) AS B2C_Customers,
    COUNT(DISTINCT CASE WHEN c.StoreID IS NOT NULL THEN soh.CustomerID END) AS B2B_Customers
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Sales.Customer c ON soh.CustomerID = c.CustomerID
GROUP BY 
    YEAR(soh.OrderDate),
    MONTH(soh.OrderDate)
ORDER BY 
    Year, Month;

--Qty of products sold (specified by product) per month&year
SELECT 
    YEAR(soh.OrderDate) AS Year,
    MONTH(soh.OrderDate) AS Month,
    CASE 
        WHEN c.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END AS CustomerType,
    p.Name AS ProductName,
    SUM(sod.OrderQty) AS TotalQuantitySold
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN 
    Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN 
    Production.Product p ON sod.ProductID = p.ProductID
GROUP BY 
    YEAR(soh.OrderDate),
    MONTH(soh.OrderDate),
    CASE 
        WHEN c.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END,
    p.Name
ORDER BY 
    Year,
    Month,
    CustomerType,
    ProductName;

--QTY of products sold
SELECT 
    YEAR(soh.OrderDate) AS Year,
    MONTH(soh.OrderDate) AS Month,
    CASE 
        WHEN c.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END AS CustomerType,
    SUM(sod.OrderQty) AS TotalQuantitySold
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN 
    Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN 
    Production.Product p ON sod.ProductID = p.ProductID
GROUP BY 
    YEAR(soh.OrderDate),
    MONTH(soh.OrderDate),
    CASE 
        WHEN c.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END
ORDER BY 
    Year,
    Month,
    CustomerType;


--How discounts or promotions influenced product sales in April 2012?
SELECT  
    P.Name AS ProductName,
    SO.Description AS SpecialOffer,
    CASE 
        WHEN C.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END AS CustomerType,
    SUM(SD.OrderQty) AS TotalQuantitySold,
    SUM(SD.LineTotal) AS TotalSalesAmount
FROM 
    Sales.SalesOrderHeader AS SOH
JOIN 
    Sales.SalesOrderDetail AS SD ON SOH.SalesOrderID = SD.SalesOrderID
JOIN 
    Production.Product AS P ON SD.ProductID = P.ProductID
JOIN 
    Sales.SpecialOfferProduct AS SOP ON P.ProductID = SOP.ProductID 
    AND SD.SpecialOfferID = SOP.SpecialOfferID
JOIN 
    Sales.SpecialOffer AS SO ON SOP.SpecialOfferID = SO.SpecialOfferID
JOIN 
    Sales.Customer AS C ON SOH.CustomerID = C.CustomerID
WHERE 
    SOH.OrderDate >= '2012-04-01' AND SOH.OrderDate < '2012-05-01'
GROUP BY 
    P.Name, SO.Description,
    CASE 
        WHEN C.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END
ORDER BY 
    TotalQuantitySold DESC;

--How discounts or promotions influenced product sales in Mar 2014?
SELECT  
    P.Name AS ProductName,
    SO.Description AS SpecialOffer,
    CASE 
        WHEN C.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END AS CustomerType,
    SUM(SD.OrderQty) AS TotalQuantitySold,
    SUM(SD.LineTotal) AS TotalSalesAmount
FROM 
    Sales.SalesOrderHeader AS SOH
JOIN 
    Sales.SalesOrderDetail AS SD ON SOH.SalesOrderID = SD.SalesOrderID
JOIN 
    Production.Product AS P ON SD.ProductID = P.ProductID
JOIN 
    Sales.SpecialOfferProduct AS SOP ON P.ProductID = SOP.ProductID 
    AND SD.SpecialOfferID = SOP.SpecialOfferID
JOIN 
    Sales.SpecialOffer AS SO ON SOP.SpecialOfferID = SO.SpecialOfferID
JOIN 
    Sales.Customer AS C ON SOH.CustomerID = C.CustomerID
WHERE 
    SOH.OrderDate >= '2014-03-01' AND SOH.OrderDate < '2014-03-30'
GROUP BY 
    P.Name, SO.Description,
    CASE 
        WHEN C.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END
ORDER BY 
    TotalQuantitySold DESC;

--Why we had a lot of sales in May 2014?
SELECT  
    P.Name AS ProductName,
    SO.Description AS SpecialOffer,
    CASE 
        WHEN C.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END AS CustomerType,
    SUM(SD.OrderQty) AS TotalQuantitySold,
    SUM(SD.LineTotal) AS TotalSalesAmount
FROM 
    Sales.SalesOrderHeader AS SOH
JOIN 
    Sales.SalesOrderDetail AS SD ON SOH.SalesOrderID = SD.SalesOrderID
JOIN 
    Production.Product AS P ON SD.ProductID = P.ProductID
JOIN 
    Sales.SpecialOfferProduct AS SOP ON P.ProductID = SOP.ProductID 
    AND SD.SpecialOfferID = SOP.SpecialOfferID
JOIN 
    Sales.SpecialOffer AS SO ON SOP.SpecialOfferID = SO.SpecialOfferID
JOIN 
    Sales.Customer AS C ON SOH.CustomerID = C.CustomerID
WHERE 
    SOH.OrderDate >= '2014-05-01' AND SOH.OrderDate < '2014-05-31'
GROUP BY 
    P.Name, SO.Description,
    CASE 
        WHEN C.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END
ORDER BY 
    TotalQuantitySold DESC;

--QTY of discount per year and month
SELECT  
    P.Name AS ProductName,
    YEAR(H.OrderDate) AS Year,
    MONTH(H.OrderDate) AS Month,
    CASE 
        WHEN C.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END AS CustomerType,
    AVG(D.UnitPriceDiscount) AS AvgDiscount
FROM Sales.SalesOrderDetail D
JOIN Sales.SalesOrderHeader H ON D.SalesOrderID = H.SalesOrderID
JOIN Sales.Customer C ON H.CustomerID = C.CustomerID
JOIN Production.Product P ON D.ProductID = P.ProductID
GROUP BY P.Name, YEAR(H.OrderDate), MONTH(H.OrderDate), 
         CASE WHEN C.StoreID IS NULL THEN 'B2C' ELSE 'B2B' END
ORDER BY Year, Month, AvgDiscount DESC;

--VENTAS POR REGION, POR MES, POR AÑO POR B2B POR B2C, DE MAYOR A MENOR
SELECT 
    SOH.CustomerID,
    C.StoreID,
    CASE 
        WHEN C.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END AS CustomerType,
    ST.Name AS Region,
    YEAR(SOH.OrderDate) AS SalesYear,
    MONTH(SOH.OrderDate) AS SalesMonth,
    SUM(SOH.TotalDue) AS TotalSales
FROM 
    Sales.SalesOrderHeader AS SOH
JOIN 
    Sales.Customer AS C ON SOH.CustomerID = C.CustomerID
JOIN 
    Person.Address AS A ON SOH.ShipToAddressID = A.AddressID
JOIN 
    Person.StateProvince AS SP ON A.StateProvinceID = SP.StateProvinceID
JOIN 
    Sales.SalesTerritory AS ST ON SP.TerritoryID = ST.TerritoryID
WHERE 
    SOH.OrderDate IS NOT NULL
GROUP BY 
    SOH.CustomerID, 
    C.StoreID,
    CASE 
        WHEN C.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END,
    ST.Name,
    YEAR(SOH.OrderDate), 
    MONTH(SOH.OrderDate)
ORDER BY 
    TotalSales DESC;

--Sales(Revenue), Cost & Profit por region correguido
SELECT 
    YEAR(H.OrderDate) AS OrderYear,
    ST.Name AS Region,
    CASE 
        WHEN C.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END AS CustomerType,
    SUM((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) AS Revenue,
    SUM(P.StandardCost * D.OrderQty) AS Cost,
    SUM(((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) AS Profit
FROM 
    Sales.SalesOrderHeader H 
JOIN 
    Sales.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
JOIN 
    Production.Product P ON D.ProductID = P.ProductID
JOIN 
    Sales.Customer C ON H.CustomerID = C.CustomerID
JOIN 
    Person.Address A ON H.ShipToAddressID = A.AddressID
JOIN 
    Person.StateProvince SP ON A.StateProvinceID = SP.StateProvinceID
JOIN 
    Sales.SalesTerritory ST ON SP.TerritoryID = ST.TerritoryID
GROUP BY 
    YEAR(H.OrderDate),
    ST.Name,
    CASE 
        WHEN C.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END
ORDER BY 
    OrderYear,
    Region,
    CustomerType;

--Profit per region by year y customertype -- NOT USED
SELECT 
    SOH.CustomerID,
    C.StoreID,
    CASE 
        WHEN C.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END AS CustomerType,
    ST.Name AS Region,
    YEAR(SOH.OrderDate) AS SalesYear,
    SUM(SOH.TotalDue) AS TotalSales,
    SUM(SD.OrderQty * P.StandardCost) AS TotalStandardCost,
    SUM(SOH.TotalDue) - SUM(SD.OrderQty * P.StandardCost) AS Profit,
    ROUND(((SUM(SOH.TotalDue) - SUM(SD.OrderQty * P.StandardCost)) * 100.0) / SUM(SOH.TotalDue), 2) AS ProfitMarginPercent
FROM 
    Sales.SalesOrderHeader AS SOH
JOIN 
    Sales.SalesOrderDetail AS SD ON SOH.SalesOrderID = SD.SalesOrderID
JOIN 
    Sales.Customer AS C ON SOH.CustomerID = C.CustomerID
JOIN 
    Person.Address AS A ON SOH.ShipToAddressID = A.AddressID
JOIN 
    Person.StateProvince AS SP ON A.StateProvinceID = SP.StateProvinceID
JOIN 
    Sales.SalesTerritory AS ST ON SP.TerritoryID = ST.TerritoryID
JOIN 
    Production.Product AS P ON SD.ProductID = P.ProductID
WHERE 
    SOH.OrderDate IS NOT NULL
GROUP BY 
    SOH.CustomerID, 
    C.StoreID,
    CASE 
        WHEN C.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END,
    ST.Name,
    YEAR(SOH.OrderDate)
ORDER BY 
    Profit DESC;

--Profit per region per share (year)
WITH RegionalProfit AS (
    SELECT 
        ST.Name AS Region,
        YEAR(SOH.OrderDate) AS SalesYear,
        SUM(SOH.TotalDue) - SUM(SD.OrderQty * P.StandardCost) AS Profit
    FROM 
        Sales.SalesOrderHeader AS SOH
    JOIN 
        Sales.SalesOrderDetail AS SD ON SOH.SalesOrderID = SD.SalesOrderID
    JOIN 
        Sales.Customer AS C ON SOH.CustomerID = C.CustomerID
    JOIN 
        Person.Address AS A ON SOH.ShipToAddressID = A.AddressID
    JOIN 
        Person.StateProvince AS SP ON A.StateProvinceID = SP.StateProvinceID
    JOIN 
        Sales.SalesTerritory AS ST ON SP.TerritoryID = ST.TerritoryID
    JOIN 
        Production.Product AS P ON SD.ProductID = P.ProductID
    WHERE 
        SOH.OrderDate IS NOT NULL
    GROUP BY 
        ST.Name, YEAR(SOH.OrderDate)
),
TotalYearlyProfit AS (
    SELECT 
        SalesYear,
        SUM(Profit) AS TotalProfit
    FROM 
        RegionalProfit
    GROUP BY 
        SalesYear
)
SELECT 
    RP.Region,
    RP.SalesYear,
    RP.Profit,
    TYP.TotalProfit,
    ROUND((RP.Profit * 100.0) / TYP.TotalProfit, 2) AS ProfitMarketSharePercent
FROM 
    RegionalProfit RP
JOIN 
    TotalYearlyProfit TYP ON RP.SalesYear = TYP.SalesYear
ORDER BY 
    RP.SalesYear, RP.Profit DESC;

--Profit per region per share correguido
WITH RegionalProfit AS (
    SELECT 
        YEAR(H.OrderDate) AS OrderYear,
        ST.Name AS Region,
        SUM(((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) AS Profit
    FROM 
        Sales.SalesOrderHeader H 
    JOIN 
        Sales.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
    JOIN 
        Production.Product P ON D.ProductID = P.ProductID
    JOIN 
        Sales.Customer C ON H.CustomerID = C.CustomerID
    JOIN 
        Person.Address A ON H.ShipToAddressID = A.AddressID
    JOIN 
        Person.StateProvince SP ON A.StateProvinceID = SP.StateProvinceID
    JOIN 
        Sales.SalesTerritory ST ON SP.TerritoryID = ST.TerritoryID
    GROUP BY 
        YEAR(H.OrderDate),
        ST.Name
),
TotalProfitPerYear AS (
    SELECT 
        OrderYear,
        SUM(Profit) AS TotalProfit
    FROM 
        RegionalProfit
    GROUP BY 
        OrderYear
)
SELECT 
    RP.OrderYear,
    RP.Region,
    RP.Profit,
    TPY.TotalProfit,
    ROUND((RP.Profit * 100.0) / TPY.TotalProfit, 2) AS ProfitSharePercent
FROM 
    RegionalProfit RP
JOIN 
    TotalProfitPerYear TPY ON RP.OrderYear = TPY.OrderYear
ORDER BY 
    RP.OrderYear, RP.Profit DESC;

--Region per share filtered by B2B/B2C
WITH RegionalProfit AS (
    SELECT 
        YEAR(H.OrderDate) AS OrderYear,
        ST.Name AS Region,
        CASE 
            WHEN C.StoreID IS NULL THEN 'B2C'
            ELSE 'B2B'
        END AS CustomerType,
        SUM(((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) AS Profit
    FROM 
        Sales.SalesOrderHeader H 
    JOIN 
        Sales.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
    JOIN 
        Production.Product P ON D.ProductID = P.ProductID
    JOIN 
        Sales.Customer C ON H.CustomerID = C.CustomerID
    JOIN 
        Person.Address A ON H.ShipToAddressID = A.AddressID
    JOIN 
        Person.StateProvince SP ON A.StateProvinceID = SP.StateProvinceID
    JOIN 
        Sales.SalesTerritory ST ON SP.TerritoryID = ST.TerritoryID
    GROUP BY 
        YEAR(H.OrderDate),
        ST.Name,
        CASE 
            WHEN C.StoreID IS NULL THEN 'B2C'
            ELSE 'B2B'
        END
),
TotalProfitPerYearType AS (
    SELECT 
        OrderYear,
        CustomerType,
        SUM(Profit) AS TotalProfit
    FROM 
        RegionalProfit
    GROUP BY 
        OrderYear, CustomerType
)
SELECT 
    RP.OrderYear,
    RP.Region,
    RP.CustomerType,
    RP.Profit,
    TPY.TotalProfit,
    ROUND((RP.Profit * 100.0) / TPY.TotalProfit, 2) AS ProfitSharePercent
FROM 
    RegionalProfit RP
JOIN 
    TotalProfitPerYearType TPY 
    ON RP.OrderYear = TPY.OrderYear AND RP.CustomerType = TPY.CustomerType
ORDER BY 
    RP.OrderYear, RP.CustomerType, RP.Profit DESC;

-- Margin by product category
With Margin as
(SELECT ISNULL(FORMAT(soh.OrderDate, 'yyyy-MM'), 'TOTAL') AS YearMonth,
CASE 
WHEN c.StoreID IS NULL THEN 'B2C'
ELSE 'B2B'
END AS CustomerType,p.Name AS ProductName, pc.productcategoryid AS ProductCategory,
SUM((sod.UnitPrice - (sod.UnitPrice * sod.UnitPriceDiscount)) * sod.OrderQty) - SUM(p.StandardCost * sod.OrderQty) AS TotalMargin
FROM Sales.SalesOrderDetail AS sod JOIN Production.Product AS p ON sod.ProductID = p.ProductID
									JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
									JOIN Sales.Customer AS c ON soh.CustomerID = c.CustomerID
									JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
									JOIN Production.ProductCategory AS pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY soh.OrderDate,
CASE 
WHEN c.StoreID IS NULL THEN 'B2C'
ELSE 'B2B'
END, p.Name, pc.ProductCategoryID)

Select YearMonth, ProductName, ProductCategory,
CASE
WHEN ProductCategory = 1 THEN 'Bikes'
WHEN ProductCategory = 2 THEN 'Components'
WHEN ProductCategory = 3 THEN 'Clothing'
ELSE 'Accesories'
END,
CustomerType, TotalMargin,
Rank () over (partition by YearMonth
order by TotalMargin) as MonthRank
From Margin
SELECT P.Name AS ProductName, SUM(SD.OrderQty * P.StandardCost) AS TotalStandardCost
FROM Sales.SalesOrderDetail AS SD JOIN Production.Product AS P ON SD.ProductID = P.ProductID
GROUP BY  P.Name
ORDER BY TotalStandardCost DESC;
 
 --25,36,37Profit per share EN TODOS LOS AÑOS
 WITH RegionalProfit AS (
    SELECT 
        ST.Name AS Region,
        CASE 
            WHEN C.StoreID IS NULL THEN 'B2C'
            ELSE 'B2B'
        END AS CustomerType,
        SUM(((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) AS Profit
    FROM 
        Sales.SalesOrderHeader H 
    JOIN 
        Sales.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
    JOIN 
        Production.Product P ON D.ProductID = P.ProductID
    JOIN 
        Sales.Customer C ON H.CustomerID = C.CustomerID
    JOIN 
        Person.Address A ON H.ShipToAddressID = A.AddressID
    JOIN 
        Person.StateProvince SP ON A.StateProvinceID = SP.StateProvinceID
    JOIN 
        Sales.SalesTerritory ST ON SP.TerritoryID = ST.TerritoryID
    GROUP BY 
        ST.Name,
        CASE 
            WHEN C.StoreID IS NULL THEN 'B2C'
            ELSE 'B2B'
        END
),
TotalProfitByType AS (
    SELECT 
        CustomerType,
        SUM(Profit) AS TotalProfit
    FROM 
        RegionalProfit
    GROUP BY 
        CustomerType
)
SELECT 
    RP.Region,
    RP.CustomerType,
    RP.Profit,
    TP.TotalProfit,
    ROUND((RP.Profit * 100.0) / TP.TotalProfit, 2) AS ProfitSharePercent
FROM 
    RegionalProfit RP
JOIN 
    TotalProfitByType TP 
    ON RP.CustomerType = TP.CustomerType
ORDER BY 
    RP.CustomerType, RP.Profit DESC;


 --COGS vs profit per Producst WRONG  
 SELECT
    PC.Name AS ProductCategory,
    CASE 
        WHEN C.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END AS CustomerType,
    SUM(SD.OrderQty * P.StandardCost) AS TotalCOGS,
    SUM(SD.LineTotal) AS TotalRevenue,
    SUM(SD.LineTotal) - SUM(SD.OrderQty * P.StandardCost) AS GrossProfit,
    ROUND(((SUM(SD.LineTotal) - SUM(SD.OrderQty * P.StandardCost)) * 100.0) / SUM(SD.LineTotal), 2) AS GrossMarginPercent
FROM 
    Sales.SalesOrderHeader AS SOH
JOIN 
    Sales.SalesOrderDetail AS SD ON SOH.SalesOrderID = SD.SalesOrderID
JOIN 
    Sales.Customer AS C ON SOH.CustomerID = C.CustomerID
JOIN 
    Production.Product AS P ON SD.ProductID = P.ProductID
JOIN 
    Production.ProductSubcategory AS PSC ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
JOIN 
    Production.ProductCategory AS PC ON PSC.ProductCategoryID = PC.ProductCategoryID
GROUP BY 
    PC.Name,
    CASE 
        WHEN C.StoreID IS NULL THEN 'B2C'
        ELSE 'B2B'
    END
ORDER BY 
    TotalCOGS DESC;

--PPT32. CostOfGoods BUENA
SELECT  
    PC.Name AS ProductCategory,
    SUM(P.StandardCost * D.OrderQty) AS TotalStandardCost,
    SUM(D.UnitPrice * D.OrderQty * (1 - D.UnitPriceDiscount)) AS TotalRevenue,
    SUM((D.UnitPrice * D.OrderQty * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) AS TotalProfit,
    ROUND(
        SUM((D.UnitPrice * D.OrderQty * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) /
        NULLIF(SUM(D.UnitPrice * D.OrderQty * (1 - D.UnitPriceDiscount)), 0) * 100, 2
    ) AS ProfitMarginPercentage
FROM 
    Sales.SalesOrderDetail D
JOIN 
    Sales.SalesOrderHeader H ON D.SalesOrderID = H.SalesOrderID
JOIN 
    Production.Product P ON D.ProductID = P.ProductID
JOIN 
    Production.ProductSubcategory PSC ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
JOIN 
    Production.ProductCategory PC ON PSC.ProductCategoryID = PC.ProductCategoryID
-- Join to include customer type (optional, useful if you want to add a filter or breakdown)
JOIN 
    Sales.Customer C ON H.CustomerID = C.CustomerID
GROUP BY  
    PC.Name
ORDER BY  
    TotalProfit DESC;

--Incluyendo purchase cost

WITH SalesData AS (
    SELECT
        PC.ProductCategoryID,
        PC.Name AS ProductCategory,
        CASE 
            WHEN C.StoreID IS NULL THEN 'B2C'
            ELSE 'B2B'
        END AS CustomerType,
        SUM(SD.LineTotal) AS TotalRevenue,
        SUM(SD.OrderQty * P.StandardCost) AS COGS
    FROM Sales.SalesOrderHeader AS SOH
    JOIN Sales.SalesOrderDetail AS SD ON SOH.SalesOrderID = SD.SalesOrderID
    JOIN Sales.Customer AS C ON SOH.CustomerID = C.CustomerID
    JOIN Production.Product AS P ON SD.ProductID = P.ProductID
    JOIN Production.ProductSubcategory AS PSC ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
    JOIN Production.ProductCategory AS PC ON PSC.ProductCategoryID = PC.ProductCategoryID
    GROUP BY PC.ProductCategoryID, PC.Name,
             CASE WHEN C.StoreID IS NULL THEN 'B2C' ELSE 'B2B' END
),
PurchaseData AS (
    SELECT
        PC.ProductCategoryID,
        SUM(POD.LineTotal) AS TotalPurchaseCost
    FROM Purchasing.PurchaseOrderDetail AS POD
    JOIN Production.Product AS P ON POD.ProductID = P.ProductID
    JOIN Production.ProductSubcategory AS PSC ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
    JOIN Production.ProductCategory AS PC ON PSC.ProductCategoryID = PC.ProductCategoryID
    GROUP BY PC.ProductCategoryID
)
SELECT 
    S.ProductCategory,
    S.CustomerType,
    S.TotalRevenue,
    S.COGS,
    P.TotalPurchaseCost,
    S.TotalRevenue - S.COGS AS GrossProfit,
    ROUND(((S.TotalRevenue - S.COGS) * 100.0) / S.TotalRevenue, 2) AS GrossMarginPercent
FROM SalesData S
LEFT JOIN PurchaseData P ON S.ProductCategoryID = P.ProductCategoryID
ORDER BY S.ProductCategory, S.CustomerType

--Query that shows top 5 products with more profit besides the bicycle.
SELECT TOP 5 
    P.Name AS ProductName,
    PC.Name AS ProductCategory,
    SUM(SD.LineTotal - (SD.OrderQty * P.StandardCost)) AS TotalProfit,
    SUM(SD.LineTotal) AS TotalRevenue,
    SUM(SD.OrderQty * P.StandardCost) AS TotalCost,
    ROUND(SUM(SD.LineTotal - (SD.OrderQty * P.StandardCost)) * 100.0 / SUM(SD.LineTotal), 2) AS ProfitMarginPercent
FROM 
    Sales.SalesOrderDetail AS SD
JOIN 
    Production.Product AS P ON SD.ProductID = P.ProductID
JOIN 
    Production.ProductSubcategory AS PSC ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
JOIN 
    Production.ProductCategory AS PC ON PSC.ProductCategoryID = PC.ProductCategoryID
WHERE 
    PC.Name <> 'Bikes' -- Exclude bikes
GROUP BY 
    P.Name, PC.Name
ORDER BY 
    TotalProfit DESC;

--Descuento por producto mes/año per profit share
WITH ProductProfits AS (
    SELECT  
        P.Name AS ProductName,
        YEAR(H.OrderDate) AS Year,
        MONTH(H.OrderDate) AS Month,
        CASE 
            WHEN C.StoreID IS NULL THEN 'B2C'
            ELSE 'B2B'
        END AS CustomerType,
        SUM(((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) AS Profit
    FROM Sales.SalesOrderDetail D
    JOIN Sales.SalesOrderHeader H ON D.SalesOrderID = H.SalesOrderID
    JOIN Sales.Customer C ON H.CustomerID = C.CustomerID
    JOIN Production.Product P ON D.ProductID = P.ProductID
    WHERE D.UnitPriceDiscount > 0  -- Solo productos con descuento
    GROUP BY P.Name, YEAR(H.OrderDate), MONTH(H.OrderDate),
             CASE WHEN C.StoreID IS NULL THEN 'B2C' ELSE 'B2B' END
),
TotalProfits AS (
    SELECT 
        Year,
        Month,
        CustomerType,
        SUM(Profit) AS TotalProfit
    FROM ProductProfits
    GROUP BY Year, Month, CustomerType
)

SELECT 
    PP.Year,
    PP.Month,
    PP.CustomerType,
    PP.ProductName,
    PP.Profit,
    TP.TotalProfit,
    ROUND((PP.Profit * 1.0 / TP.TotalProfit) * 100, 2) AS ProfitSharePercent
FROM ProductProfits PP
JOIN TotalProfits TP
    ON PP.Year = TP.Year AND PP.Month = TP.Month AND PP.CustomerType = TP.CustomerType
ORDER BY 
    PP.Year, PP.Month, ProfitSharePercent DESC;


--Standard cost per month&year JUST B2B
SELECT
    YEAR(H.OrderDate) AS Year,
    MONTH(H.OrderDate) AS Month,
    SUM(P.StandardCost * D.OrderQty) AS TotalStandardCost
FROM 
    Sales.SalesOrderHeader H
JOIN 
    Sales.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
JOIN 
    Production.Product P ON D.ProductID = P.ProductID
JOIN 
    Sales.Customer C ON H.CustomerID = C.CustomerID
WHERE 
    C.StoreID IS NOT NULL  -- B2B customers only
GROUP BY 
    YEAR(H.OrderDate), 
    MONTH(H.OrderDate)
ORDER BY 
    Year, Month;

--Order volume B2B per month & year
SELECT  
    YEAR(H.OrderDate) AS OrderYear,
    MONTH(H.OrderDate) AS OrderMonth,
    'B2B' AS CustomerType,
    SUM(D.OrderQty) AS TotalQuantity,
    SUM(D.LineTotal) AS TotalRevenue,
    AVG(D.UnitPriceDiscount) AS AvgDiscount,
    COUNT(DISTINCT H.SalesOrderID) AS TotalOrders
FROM Sales.SalesOrderDetail D
JOIN Sales.SalesOrderHeader H ON D.SalesOrderID = H.SalesOrderID
JOIN Sales.Customer C ON H.CustomerID = C.CustomerID
WHERE C.StoreID IS NOT NULL  -- B2B customers only
GROUP BY 
    YEAR(H.OrderDate), MONTH(H.OrderDate)
ORDER BY 
    OrderYear, OrderMonth;