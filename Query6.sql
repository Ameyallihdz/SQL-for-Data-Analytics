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


WITH MonthlySales AS (
    SELECT
        YEAR(soh.OrderDate) AS SaleYear,
        MONTH(soh.OrderDate) AS SaleMonth,
        p.Name AS ProductName,
        SUM(sod.OrderQty) AS TotalQuantitySold,
        -- B2C if StoreID is NULL, else B2B
        CASE 
            WHEN c.StoreID IS NULL THEN 'B2C'
            ELSE 'B2B'
        END AS CustomerType,
        ROW_NUMBER() OVER (
            PARTITION BY YEAR(soh.OrderDate), MONTH(soh.OrderDate), 
                         CASE WHEN c.StoreID IS NULL THEN 'B2C' ELSE 'B2B' END
            ORDER BY SUM(sod.OrderQty) DESC
        ) AS Rank
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
    GROUP BY 
        YEAR(soh.OrderDate), 
        MONTH(soh.OrderDate), 
        p.Name,
        CASE WHEN c.StoreID IS NULL THEN 'B2C' ELSE 'B2B' END
)
SELECT
    SaleYear,
    SaleMonth,
    ProductName,
    TotalQuantitySold,
    CustomerType
FROM MonthlySales
WHERE Rank = 1
ORDER BY SaleYear, SaleMonth, CustomerType;
