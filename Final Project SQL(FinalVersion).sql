--PPT9,10,14. Revenue&Profitability Grouped by B2B/B2C
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

--PPT11. B2B Quantity Sold
SELECT
YEAR(H.OrderDate) AS OrderYear,
MONTH(H.OrderDate) AS OrderMonth,
'B2C' AS CustomerType,
SUM(D.OrderQty) AS TotalQuantity
FROM Sales.SalesOrderDetail D
JOIN Sales.SalesOrderHeader H ON D.SalesOrderID = H.SalesOrderID
JOIN Sales.Customer C ON H.CustomerID = C.CustomerID
WHERE C.StoreID IS NULL  -- B2C only
GROUP BY
YEAR(H.OrderDate), MONTH(H.OrderDate)
ORDER BY
OrderYear, OrderMonth;

--PPT12. Why we had a lot of sales in May 2014?
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

--PPT15. QTY of products sold
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
    CustomerType

--PPT16. B2B Profit Tendency
SELECT
YEAR(H.OrderDate) AS Year,
MONTH(H.OrderDate) AS Month,
SUM(D.UnitPrice * D.OrderQty * (1 - D.UnitPriceDiscount)) AS Revenue,
SUM(P.StandardCost * D.OrderQty) AS Cost,
SUM((D.UnitPrice * D.OrderQty * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) AS Profit
FROM
Sales.SalesOrderHeader H
JOIN
Sales.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
JOIN
Sales.Customer C ON H.CustomerID = C.CustomerID
JOIN
Production.Product P ON D.ProductID = P.ProductID
WHERE
C.StoreID IS NOT NULL -- B2B only
AND YEAR(H.OrderDate) BETWEEN 2011 AND 2014
GROUP BY
YEAR(H.OrderDate), MONTH(H.OrderDate)
ORDER BY
Year, Month;

--PPT17. --QTY of discount per year and month
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

--PPT18. Standard cost per month&year JUST B2B
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

--PPT19. QTY of products sold
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

--PPT35,36,37. Sales(Revenue), Cost & Profit por region correguido
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

--PPT24. Profit per Category B2B&B2C
With Margin as
				(SELECT
					ISNULL(FORMAT(soh.OrderDate, 'yyyy-MM'), 'TOTAL') AS YearMonth,
					CASE 
						WHEN c.StoreID IS NULL THEN 'B2C'
						ELSE 'B2B'
					END AS CustomerType,
					p.Name AS ProductName,
					pc.productcategoryid AS ProductCategory,
					SUM((sod.UnitPrice - (sod.UnitPrice * sod.UnitPriceDiscount)) * sod.OrderQty) - SUM(p.StandardCost * sod.OrderQty) AS TotalMargin
				FROM
					Sales.SalesOrderDetail AS sod
				JOIN
					Production.Product AS p ON sod.ProductID = p.ProductID
				JOIN
					Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
				JOIN
					Sales.Customer AS c ON soh.CustomerID = c.CustomerID
				JOIN 
					Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
				JOIN
					Production.ProductCategory AS pc ON ps.ProductCategoryID = pc.ProductCategoryID
				GROUP BY
					soh.OrderDate,
					CASE 
						WHEN c.StoreID IS NULL THEN 'B2C'
						ELSE 'B2B'
					END,
					p.Name,
					pc.ProductCategoryID)
Select YearMonth,
		ProductName,
		ProductCategory,
		CASE
			WHEN ProductCategory = 1 THEN 'Bikes'
			WHEN ProductCategory = 2 THEN 'Components'
			WHEN ProductCategory = 3 THEN 'Clothing'
			ELSE 'Accesories'
		END,
		CustomerType,
		TotalMargin,
		Rank () over (partition by YearMonth
					order by TotalMargin) as MonthRank
From Margin

--PPT25. Category per Year
With Margin as
				(SELECT
					ISNULL(FORMAT(soh.OrderDate, 'yyyy-MM'), 'TOTAL') AS YearMonth,
					CASE 
						WHEN c.StoreID IS NULL THEN 'B2C'
						ELSE 'B2B'
					END AS CustomerType,
					p.Name AS ProductName,
					pc.productcategoryid AS ProductCategory,
					SUM((sod.UnitPrice - (sod.UnitPrice * sod.UnitPriceDiscount)) * sod.OrderQty) - SUM(p.StandardCost * sod.OrderQty) AS TotalMargin
				FROM
					Sales.SalesOrderDetail AS sod
				JOIN
					Production.Product AS p ON sod.ProductID = p.ProductID
				JOIN
					Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
				JOIN
					Sales.Customer AS c ON soh.CustomerID = c.CustomerID
				JOIN 
					Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
				JOIN
					Production.ProductCategory AS pc ON ps.ProductCategoryID = pc.ProductCategoryID
				GROUP BY
					soh.OrderDate,
					CASE 
						WHEN c.StoreID IS NULL THEN 'B2C'
						ELSE 'B2B'
					END,
					p.Name,
					pc.ProductCategoryID)
Select YearMonth,
		ProductName,
		ProductCategory,
		CASE
			WHEN ProductCategory = 1 THEN 'Bikes'
			WHEN ProductCategory = 2 THEN 'Components'
			WHEN ProductCategory = 3 THEN 'Clothing'
			ELSE 'Accesories'
		END,
		CustomerType,
		TotalMargin,
		Rank () over (partition by YearMonth
					order by TotalMargin) as MonthRank
From Margin

--PPT27. Profit per category
SELECT 
    PC.Name AS ProductCategory,
    SUM(D.OrderQty) AS TotalOrderQuantity,
    SUM(D.OrderQty * P.StandardCost) AS TotalStandardCost,
    SUM((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) AS TotalRevenue,
    SUM(((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) AS TotalProfit,
    ROUND(
        SUM(((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) / 
        NULLIF(SUM((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)), 0) * 100, 2
    ) AS ProfitMarginPercentage,
    CASE 
        WHEN SUM(D.OrderQty) > 10000 AND 
             ROUND(
                SUM(((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) / 
                NULLIF(SUM((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)), 0) * 100, 2
             ) < 20 THEN 'High Volume, Low Margin'
        WHEN SUM(D.OrderQty) < 3000 AND 
             ROUND(
                SUM(((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)) - (P.StandardCost * D.OrderQty)) / 
                NULLIF(SUM((D.UnitPrice * D.OrderQty) * (1 - D.UnitPriceDiscount)), 0) * 100, 2
             ) > 30 THEN 'Low Volume, High Margin'
        ELSE 'Balanced or Moderate'
    END AS PerformanceCategory
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
GROUP BY 
    PC.Name
ORDER BY 
    TotalStandardCost DESC;

--PPT32. Cost by Products
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

--PPT28. Accesories with best profit
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

--PPT31. Cost vs Revenue B2C&B2B
SELECT
'B2B' AS CustomerType,
SUM(sod.UnitPrice * sod.OrderQty * (1 - sod.UnitPriceDiscount)) AS [Total Revenue],
SUM(p.StandardCost * sod.OrderQty) AS [Total Cost],
SUM((sod.UnitPrice * sod.OrderQty * (1 - sod.UnitPriceDiscount)) - (p.StandardCost * sod.OrderQty)) AS [Total Profit]
FROM
Sales.SalesOrderHeader soh
INNER JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
INNER JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE
c.StoreID IS NOT NULL
UNION ALL
--B2C
SELECT
'B2C' AS CustomerType,
SUM(sod.UnitPrice * sod.OrderQty * (1 - sod.UnitPriceDiscount)) AS [Total Revenue],
SUM(p.StandardCost * sod.OrderQty) AS [Total Cost],
SUM((sod.UnitPrice * sod.OrderQty * (1 - sod.UnitPriceDiscount)) - (p.StandardCost * sod.OrderQty)) AS [Total Profit]
FROM
Sales.SalesOrderHeader soh
INNER JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
INNER JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE
c.StoreID IS NULL
UNION ALL
--Total
SELECT
'Total' AS CustomerType,
SUM(sod.UnitPrice * sod.OrderQty * (1 - sod.UnitPriceDiscount)) AS [Total Revenue],
SUM(p.StandardCost * sod.OrderQty) AS [Total Cost],
SUM((sod.UnitPrice * sod.OrderQty * (1 - sod.UnitPriceDiscount)) - (p.StandardCost * sod.OrderQty)) AS [Total Profit]
FROM
Sales.SalesOrderHeader soh
INNER JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
INNER JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product p ON sod.ProductID = p.ProductID;

--PPT32. Most Expensive Products. Cost by products
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

 --PPT35,36,37. Profit per share EN TODOS LOS AÑOS
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