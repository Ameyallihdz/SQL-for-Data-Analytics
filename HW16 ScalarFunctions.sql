--LESSON 16
--1. Define a function that takes as parameters a year and a customer number, and returns the quantity of sales for that customer in that year.
--Call the function and check that it is working properly
--STEP1: Create the query that displays Qty of Sales per CX
select CustomerID, year(OrderDate) as Year, count(*) as QTYofSales
from sales.SalesOrderHeader
group by CustomerID, year(OrderDate)
--STEP2: Convert it into a function
create function fnSalesperCX (@Year int, @CustomerNumber int)
returns int --QTYSales count
as
begin
	declare @QTYSalesPerCX int --2.Declare variable
	select @QTYSalesPerCX=count(*) --3.Assign
	from sales.SalesOrderHeader
	where CustomerID=@CustomerNumber and year(OrderDate)=@Year --1.Link parameter a query
	return @QTYSalesPerCX
end
--STEP3: Try it with year 2014 with CustomerNumber 14676 and, 2012 with CustomerNumber 29753
select dbo.fnSalesperCX (2014, 14676) as QTYSalesPerCX
select dbo.fnSalesperCX (2012, 29753) as QTYSalesPerCX

--2.Make a list of 4 functions that could be useful in the day-to-day work of a data analyst. Describe what each function does.
--Function1: Sales per SalesPerson to review performance
--STEP1: Create the query that displays Qty of Sales per SalesPerson
select SalesPersonID, year(OrderDate) as Year, count(*) as QTYofSales
from sales.SalesOrderHeader
group by SalesPersonID, year(OrderDate)
--STEP2 - Create the function
create function fnSalesperPerson (@Year int, @SalesPersonID int)
returns int
as
begin
	declare @QTYSalesPerSP int --2.Declare variable
	select @QTYSalesPerSP=count(*) --3.Assign
	from sales.SalesOrderHeader
	where SalesPersonID=@SalesPersonID and year(OrderDate)=@Year --1.Link parameter a query
	return @QTYSalesPerSP
end
--STEP3: Check results with SPID=281, Year=2011 and 2014
select dbo.fnSalesperPerson (2011, 281) as QTYSalesPerCX
select dbo.fnSalesperPerson (2014, 281) as QTYSalesPerCX

--Function2: Shipping performance according to OrderID
select SalesOrderID, OrderDate, ShipDate
from Sales.SalesOrderHeader
----Function
create or alter function fnShippingPerformance (@OrderID int)
returns int
as
begin
	declare @ShippingPerformancePerOrder int
	select @ShippingPerformancePerOrder=datediff(day,OrderDate, ShipDate)
	from Sales.SalesOrderHeader
	where SalesOrderID=@OrderID
	return @ShippingPerformancePerOrder
end
--STEP3: Check results with OrderID= 43659 and 43660
select dbo.fnShippingPerformance (43659) as ShippingDays
select dbo.fnShippingPerformance (43660) as ShippingDays

--Function3: TotalQTY of orders by year and product
--Query
select sod.ProductID, year(soh.OrderDate) as Year, sum(sod.OrderQty) as TotalQTYperYear
from Sales.SalesOrderHeader soh join Sales.SalesOrderDetail sod on soh.SalesOrderID=sod.SalesOrderID
group by sod.ProductID, year(soh.OrderDate)
--Function3: TotalQTY of orders by year and product
create function fnTotalOrders (@year int, @ProductID int)
returns int --SumQTYperProduct
as
begin
	declare @TotalOrdersperYear int
	select @TotalOrdersperYear=sum(sod.OrderQty)
	from Sales.SalesOrderHeader soh join Sales.SalesOrderDetail sod on soh.SalesOrderID=sod.SalesOrderID	
	where @year= year(soh.OrderDate) and @ProductID=sod.ProductID
	return @TotalOrdersperYear
end
--STEP3: Check results with ProductID
select dbo.fnTotalOrders (2011,809) as QTYOrders2011
select dbo.fnTotalOrders (2012,809) as QTYOrders2012
select dbo.fnTotalOrders (2013,809) as QTYOrders2013
select dbo.fnTotalOrders (2014,809) as QTYOrders2014

--Function4: Sales generated per TerritoryID and compared by year
--Query
select TerritoryID, sum(SubTotal) as SalesperTerritoryID, year(OrderDate) as year
from Sales.SalesOrderHeader
group by TerritoryID, year(OrderDate)
order by TerritoryID,  year(OrderDate)
--STEP2: Function
create function dbo.fnSalesperLocation (@Location int, @Year int)
returns decimal (10,2) --SumSubtotal
as
begin
	declare @Sales decimal (10,2)
	select @Sales=sum(SubTotal)
	from Sales.SalesOrderHeader
	where @Location=TerritoryID and @Year=year(OrderDate)
	return @Sales
end

--STEP3: Check results with ProductID
select dbo.fnSalesperLocation (1,2011) as Sales2011Territory1
select dbo.fnSalesperLocation (1,2012) as Sales2012Territory1
select dbo.fnSalesperLocation (1,2013) as Sales2013Territory1
select dbo.fnSalesperLocation (1,2014) as Sales2014Territory1
