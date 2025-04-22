--EXAMPLE
create or alter procedure spAdd2Numbers
@Number1 int, @Number2 int, @Number3 int out
as
begin
set @Number3=@Number1*@Number2
end

--How to call this?
declare  @varA int, @varB int, @varC int
set @varA=5
set @varB=8

--exec spAdd2Numbers @varA, @varB, @varC out
--select @varC

exec spAdd2Numbers 10, 7, @varC out
select @varC

--EXAMPLE
create or alter procedure spgetNoOrders
	@CustID int, @NoOfOrders int out
as
begin
	select @NoOfOrders=count(*)
	from Sales.SalesOrderHeader
	where CustomerID=@CustID
end

--test
declare @HowmanyOrders int
exec spgetNoOrders 11000, @HowmanyOrders out
select @HowmanyOrders


--LESSON 18
--1.Create a procedure called spCustSalesPerYear that takes a customer number and year as parameters, and returns as output variables: the amount of orders placed
--and the total orders for that year
--Step1: Create the query
select CustomerID, year(OrderDate) as Year, count(*) as TotalAmount

from Sales.SalesOrderHeader

--Step2: Create it a procedure
create or alter procedure spCustSalesPerYear
		@CustomerNumber int, @Year int, @TotalAmount decimal (18,2) out, @TotalOrders int out
as
begin
	select @TotalOrders=count(*), 
			@TotalAmount=sum(subTotal)
	from Sales.SalesOrderHeader
	where CustomerID=@CustomerNumber and year(OrderDate)=@Year
end

--2. To check if the procedure is correct, write the instructions defined in the following sections, and then mark and run all the code you wrote:
		--a. Define two variables: @vTotalOrders (data type: int) and @vTotalAmount (data type: decimal (10,2))
		--b. Call the procedure and send it the following parameters: Customer number – 29890, Year – 2011, The two parameters you defined in the previous section.
--Note that the last two parameters will function as output variables, so when sending them to the procedure you must add the code word: out
		--c. Write a query showing the value of the two variables returned as output variables from the procedure
declare @vTotalOrders int, @vTotalAmount decimal(10,2)
exec spCustSalesPerYear 29890, 2011, @vTotalOrders out, @vTotalAmount out
select @vTotalOrders as TotalOders, @vTotalAmount as TotalAmount

--3.Create a procedure called spOrdersRangeAmount that takes parameters (detailed below) that produce a data range, and returns as an output variable the total
--amount of all incoming orders in the data range e. Parameters for creating the data range:
		--@inFromDate - The start date (inclusive) of the data range
		--@inToDate - The final (inclusive) date of the data range
		--@inFromSubCategory - The minimum (including) subcategory code in the data range
		--@inToSubCategory - The maximum (including) subcategory code in the data range
		--@inColor - The color of the items that will fit into the data range
create or alter procedure spOrdersRangeAmount
	@inFromDate date, @inToDate date, @inFromSubCategory int, @inToSubCategory int, @inColor nvarchar(10),
	@TotalAmount decimal (18,2) out
as
begin
	select @TotalAmount=sum(Subtotal) --Output
	from Sales.SalesOrderHeader soh join Sales.SalesOrderDetail sod on soh.SalesOrderID=sod.SalesOrderID
									join Production.Product p on sod.ProductID=p.ProductID --1.Unir tablas
	where OrderDate between @inFromDate and @inToDate and
		ProductSubcategoryID between @inFromSubCategory and @inToSubCategory and
		Color=@inColor
end

--4. To check if the procedure is correct, write the instructions defined in the following sections, and then mark and run all the code you wrote:
		--a. Define a variable named @vTotalAmount (given type: decimal (10,2))
		--b. Call the procedure and send it the appropriate parameters so that it will run over the following ranges: 
				--Date: 01/01/2012 to 31/12/2012
				--Subcategory code: 1 to 5
				--Product color: Yellow
		--c. Write a query that shows the value of the variable returned as an output variable from the procedure
declare @vTotalAmount decimal (18,2)
exec spOrdersRangeAmount '2012/01/01', '2012/12/31', 1, 5, 'Yellow', @vTotalAmount out
select @vTotalAmount as TotalAmount