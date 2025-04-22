--LESSON 13
--1.Learn independently (search the web) how to create a new table from query results.
--With select into command, that allows to select data from existing tables and insert it into new table in a single operation.
	--SELECT column1, column2, ...
	--INTO new_table
	--FROM existing_table
	--WHERE condition

--2.Write a query that creates a new table named panel_EDA1, which contains the following data: (Select the data from the tables that seem appropriate.)
--SalesOrderID, OrderDate, ShipToAddressID, ShipDate, CustomerID, OrderQty,ProductID, LineTotal
select soh.SalesOrderID, soh.OrderDate, soh.ShipToAddressID, soh.ShipDate, soh.CustomerID, sod.OrderQty, sod.ProductID, sod.LineTotal
into #Panel_EDA1
from Sales.SalesOrderHeader soh join Sales.SalesOrderDetail sod on soh.SalesOrderID=sod.SalesOrderID

--Check the panel results
select *
from #Panel_EDA1

--3.Write 5 business questions (only the questions, not the answers) that can be answered from the data in the panel_EDA1 table.
		--1. What are the top-selling products based on total sales revenue (`LineTotal`)?  
		--2. How has the number of orders (`SalesOrderID`) changed over time (`OrderDate`)? 
		--3. What is the average order quantity (`OrderQty`) per product (`ProductID`)?  
		--4. What is the average time between order date (`OrderDate`) and shipping date (`ShipDate`)?  
		--5. Which customers (`CustomerID`) generate the highest total sales (`LineTotal`)?  
		--6. What are the peak sales months based on `OrderDate`?  
		--7. Which shipping locations (`ShipToAddressID`) receive the highest number of orders?  
		--8. What is the distribution of order quantities (`OrderQty`) across different products (`ProductID`)?  
		--9. How many orders are shipped on the same day as the order date (`OrderDate = ShipDate`)?  
		--10. What is the total revenue contribution of each customer (`CustomerID`) over time?  