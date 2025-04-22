select SalesOrderID, OrderDate, CustomerID
into #mySales
from Sales.SalesOrderHeader

select *
from #mySales

alter table #mySales
add CustomerName nvarchar(50)

update #mySales
set customerName=(select concat_ws(' ', FirstName, MiddleName, LastName)
					from Sales.Customer join Person.Person on Sales.Customer.PersonID=Person.Person.BusinessEntityID
					where Sales.Customer.CustomerID=#MySales.CustomerID)
--LESSON 17
--1.Set up a temporary table named #tmpProduct, and input the data of all the products with a ProductNumber that begins with BK.
select *
into #tmpProduct
from Production.Product
where ProductNumber like 'BK%'

--2. Check that a temporary table has been created within the temporary database (tempdb), and write a query that displays all the data from this table.
select *
from #tmpProduct

--3. Open a new query window and try to run the query from the previous question. Did it succeed? Why? 
		--Result: Fails, because its temporary and runs temporarely under the same query

--4. Input the following data from the Products table into the new temporary table, #tmpNewProduct: Product ID, catalog number, color, product name, weight and list price.
select ProductID, ProductNumber, Color, Name, Weight, ListPrice
into #tmpNewProduct
from Production.Product

select *
from #tmpNewProduct

--5. Use the temporary table to calculate how many items there are of each color. Sort in ascending order.
select Color, count(*) as QTYColor
from #tmpNewProduct
group by Color
order by QTYColor asc

--PART 2
--1.Create a procedure named spProductList that runs the following query:
select ProductID,
ProductNumber,
[Name]
from Production.Product

--2. Continue on from the previous question. In order to check the accuracy of the procedure, check that the procedure was created in the "stored procedures" folder.
--(If you do not remember the full path, refer to the presentation from the lesson.) In addition, run the procedure, and check that the desired result was obtained.
--If you have a long running query, you can use a permanent table instead of a procedure
create or alter procedure spProductList
as
begin
	select ProductID, ProductNumber, Name
	from Production.Product
end

execute spProductList

--3. Following on from the previous question, delete the spProductList procedure.
drop procedure spProductList

--4.Create a procedure called spRankYears that displays the following data for each year: year, order quantity, total order amount (SubTotal) for that year.
--Call the procedure to check its integrity.
--STEP1: 1st the query
select YEAR(OrderDate) as Year, sum(OrderQTY) as OrderQTY, sum(LineTotal) as TotalAmount
from Sales.SalesOrderHeader soh join Sales.SalesOrderDetail sod on soh.SalesOrderID=sod.SalesOrderID
group by year(OrderDate)
--STEP2: convert it into procedure
create or alter procedure spRankYears
as
begin
	select YEAR(OrderDate) as Year, sum(OrderQTY) as OrderQTY, sum(LineTotal) as TotalAmount
	from Sales.SalesOrderHeader soh join Sales.SalesOrderDetail sod on soh.SalesOrderID=sod.SalesOrderID
	group by year(OrderDate)
end
--STEP3: Review
exec spRankYears

--5. Create a procedure called spBestSeller that displays the following data for each item ordered: the item code, the total quantity of the item ordered and total
--amount for ordering this item. Filter the query results to show only 2013 data. Sort the results by the total amount for the item in descending order.
--Call the procedure and check that it is correct.
create or alter procedure spBestSeller
as
begin
	select ProductID, sum(OrderQTY) as OrderQTY, sum(LineTotal) as TotalAmount
	from Sales.SalesOrderHeader soh join Sales.SalesOrderDetail sod on soh.SalesOrderID=sod.SalesOrderID
	where year(OrderDate)=2013
	group by ProductID
	order by TotalAmount desc
end
exec spBestSeller

--6.Continuing on from the previous question, modify the spBestSeller procedure to add a column in which the product is ranked according to the value in the Total
--amount column. Display only the 20 best-selling items, and sort the results by the ranking. Call the procedure and check that it is correct.
create or alter procedure spBestSeller
as
begin
	with myCTE
	as (
		select ProductID, sum(OrderQTY) as OrderQTY, sum(LineTotal) as TotalAmount, rank() over (Order by sum(LineTotal)) as RankbyAmount
		from Sales.SalesOrderHeader soh join Sales.SalesOrderDetail sod on soh.SalesOrderID=sod.SalesOrderID
		where year(OrderDate)=2013
		group by ProductID
		) 
	select * 
	from myCTE 
	where RankbyAmount<=20
	order by RankbyAmount asc
end
exec spBestSeller

--7.Erase the spBestSeller procedure.
drop procedure spBestSeller

--PART3
--1.Create a procedure named spSalesPerYear that takes a year number (data type: int) as a parameter and displays all the data from that year's Order header table.
--Call the procedure and check that it is correct by running the following code: exec spSalesPerYear 2013 and exec spSalesPerYear 2014
create or alter procedure spSalesPerYear
@year int
as
begin
	select *
	from Sales.SalesOrderHeader
	where year(OrderDate)=@year
end

exec spSalesPerYear 2013
exec spSalesPerYear 2014

--2. Continuing on from the previous question, modify the spSalesPerYear procedure so it takes two parameters: year and customer number (data type: int) and returns all
--the data from the Order header table for the specified year and customer. Call the procedure and check that it is correct by running the following code:
--exec spSalesPerYear 2013, 17767 and exec spSalesPerYear 2014, 27386
create or alter procedure spSalesPerYear
@year int, @CustumerNumber int
as
begin
	select *
	from Sales.SalesOrderHeader
	where year(OrderDate)=@year and CustomerID=@CustumerNumber
end

exec spSalesPerYear 2013, 17767  
exec spSalesPerYear 2014, 27386

--3.Create a procedure called spProductList that takes the parameters detailed below and returns all products from the Product table that meet the requirements.
--The purpose of the parameters is to specify the desired data ranges for the types of products and their list prices.
		--a. The parameters that the procedure takes:
				--A 2-character string: Check against the two left-hand characters in the ProductNumber column
				--From-list price: the minimum list price (inclusive) that will be included in the query results
				--Until- list price: the maximum list price (inclusive) that will be included in the query results
		--b. The procedure will display the following columns: ProductID, ProductNumber, Name, ListPrice
		--c. Call the procedure and check that it is correct by running the following code: Exec spProductList 'bk', 200, 1500
--STEP 1: Create the query
select ProductID, ProductNumber, Name, ListPrice
	from Production.Product
	where ProductNumber like 'BK%' and ListPrice between 200 and 1500
--STEP2: Modify into procedure
create or alter procedure spProductList
@StartsWith nvarchar(2), @FromPrice decimal(10,2), @UntilPrice decimal(10,2)
as
begin
	select ProductID, ProductNumber, Name, ListPrice
	from Production.Product
	where ProductNumber like @StartsWith + '%' and ListPrice between @FromPrice and @UntilPrice
end

exec spProductList 'BK', 200, 1500