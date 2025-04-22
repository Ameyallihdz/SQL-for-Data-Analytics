create or alter function fPowerby2 (@mynumber int)
returns int
as
begin
	return @mynumber*@mynumber
end

select dbo.fPowerby2 (2) as Result

--Example2
create or alter function fDeliveryDays (@ShippedDate date, @ArrivedDate date)
returns int
as
begin
	return datediff (DAY, @ArrivedDate, @ShippedDate)
end

--select dbo.fDeliveryDays('2025-03-01', getdate()) as DeliveryDays
select SalesOrderID, dbo.fDeliveryDays(OrderDate, Shipdate) as FromOrderToShipped
from Sales.SalesOrderHeader


--LESSON 16
--1.Create a function called fnFuncLearning that does not take parameters and returns integer values (type int). Set the function to always return the number 2.
--Call the function and check that it returns the correct value.
create or alter function  fnFuncLearning ()
returns int
as
begin
	return 2
end

select dbo.fnFuncLearning () as Result

--2.Modify the fnFuncLearning function so that it returns the result of the following formula (Do not calculate the result yourself. Let the function do the calculation.):
--6 + 2 * (4-2 * 3) Call the function, and check the accuracy
create or alter function  fnFuncLearning ()
returns int
as
begin
	return 6 + 2 * (4-2 * 3) 
end

select dbo.fnFuncLearning () as Result

--3.Modify the fnFuncLearning function so that it takes a parameter of type int. Decide on a parameter name. Modify the function's operation so that the result  it returns
--is the parameter (the value sent to the function in the parameter) multiplied (*) by 10. Call the function and send a parameter. Check that the result is correct.
--Call the function and send a parameter. Check that the result is correct. Reminder: When calling a function with a parameter, write the parameter inside
--parentheses. For example: selectdbo.fnFuncLearning(5)as Result
create or alter function  fnFuncLearning (@Param1 int)
returns int
as
begin
	return @Param1*10
end

select dbo.fnFuncLearning (7) as Result

--4.Modify the fnFuncLearning function so it takes two parameters of type int, and returns the product of the first parameter multiplied by the second.
--Call the function and send a parameter. Check that the result is correct Reminder: To call a function with more than one parameter, separate the parameters
--with a comma. For example: selectdbo.fnFuncLearning(12, 5)as Result
create or alter function  fnFuncLearning (@Param1 int, @Param2 int)
returns int
as
begin
	return @Param1*@Param2
end

select dbo.fnFuncLearning (7, 3) as Result

--Declare used to storage it as a variable and use it later (como si lo escribieramos en un post it)
create or alter function  fnFuncLearning (@Param1 int, @Param2 int)
returns int
as
begin
	declare @Result int
	set @Result=@Param1*@Param2
	return @Result
end

select dbo.fnFuncLearning (7, 3) as Result

--5.The preliminary practice is complete, so there is no further need for the fnFuncLearning function. Delete the function.
drop function dbo.fnFuncLearning

--6. Create a new function called fnGetProfit that takes 3 parameters: price, cost and quantity (more details below), and calculates the profit for all items.
		--a. Parameter Details: Parameter Name: @Price; Data Type: decimal (8,2), Parameter Name: @Cost; Data Type: decimal (8,2), Parameter name: @Qty; Data type: int
		--b. Think how to calculate profit. Hint: (Price - Cost) * Qty
		--c. Check your answer
create or alter function fnGetProfit (@Price decimal(8,2), @Cost decimal (8,2), @Qty int)
returns decimal (8,2)
as
begin 
	return @Qty*(@Price - @Cost)
end

select  dbo.fnGetProfit (100,250,5) as Result

--7. Continuing from the previous section, the function will be used in 3 different queries. Write a query for each of the following sections:
		--a. In order to check the accuracy of the function, run it with fixed parameters and, at the same time, calculate the expected result manually, to make sure
			--that the results are identical. Send the following values to the function: Price = 100, Cost = 30, Qty = 10
			--Calculate the answer manually, and check to be sure that the query returns the correct answer.
		--b. Explore the theoretical profit from each of the products in the product table. Send the function the following values: list price, item cost, and quantity = 1.
			--Run the query only on products that have a value for price (price higher than 0).
		--c. In order to check the real profit from the Order details table, write a query that displays the following columns:
		--d. Order number, item number, price after discount (calculated column. There are two ways to calculate this value.), item cost (from the Product table), 
			--profit per	sales record (by calling the function and sending the appropriate parameters). Examine the results. Are there any strange results? 
			--If so, what might be the reason for this?

--a
select  dbo.fnGetProfit (100,30,10) as Result
--b
--select  dbo.fnGetProfit (100,300,10) as Result
select ProductID, dbo.fnGetProfit(ListPrice, StandardCost, 1) as Profit
from Production.Product
where ListPrice>0
--c
select SalesOrderID, p.ProductID, (1-UnitPriceDiscount)*UnitPrice as PriceAfterDiscount, StandardCost, 
		dbo.fnGetProfit ((1-UnitPriceDiscount)*UnitPrice, StandardCost, OrderQty) as ProfitSales
from Sales.SalesOrderDetail sod join Production.Product p on sod.ProductID=p.ProductID

--PART2
--Step1: Create query: Get fullname with CustomerID = Returned as a table!!!
select CONCAT_WS('', FirstName, MiddleName, LastName) as FullName
from Sales.Customer c join Person.Person p on c.PersonID=p.BusinessEntityID
where CustomerID='11000'
--Step2: CXId is the parameter > CRETE IT AS A FUNCTION
create or alter function fnGetFullName (@CustID int)
returns nvarchar(50)
as
begin
	select CONCAT_WS(' ', FirstName, MiddleName, LastName) as FullName
	from Sales.Customer c join Person.Person p on c.PersonID=p.BusinessEntityID
	where CustomerID=@CustID --Change it to the parameter!
	--Now save it into a variable
end
--Step3: Now save it into a variable
create or alter function dbo.fnGetFullName (@CustID int)
returns nvarchar(50)
as
begin
	declare @Result nvarchar (50) --Variable
	select @Result = CONCAT_WS(' ', FirstName, MiddleName, LastName) --Make it as an operation that equals the variable
	from Sales.Customer c join Person.Person p on c.PersonID=p.BusinessEntityID
	where CustomerID=@CustID --Change it to the parameter!
	return @Result --Now return it
end

select dbo.fnGetFullName (11000) as FullName --Returned as a variable!!!

--Use this function
select CustomerID, dbo.fnGetFullName(CustomerID) as FullName, sum(subTotal) as Total
from Sales.SalesOrderHeader soh
group by CustomerID --dont put functions in group

--1.For the purpose of learning, create a function called fnFuncLearning and follow the instructions in the following sections: 
--(If the function was not deleted in the previous part of the exercise, update the function using "alter").
		--a. The function will take two parameters of data type int.
		--b. Within the function, define a variable of type integer (int) and give it a name of your choice.
		--c. The function will insert the result of the product of the two received parameters into the variable.
		--d. The function will returnsthe variable that has been defined as the returned value.
--Call the function and send a parameter to it. Check that the result is correct.
create or alter function fnFuncLearning (@Param1 int, @Param2 int)
returns int
as
begin
	declare @Result int
	set @Result=@Param1*@Param2
	--select @Result=@Param1*@Param2 --You can use Select or Set!
	return @Result
end

select dbo.fnFuncLearning(10,3) as Result


--2.Create a function called fnGetOrderCustomer that takes a parameter, Order number (int data type), and returns the customer number from that order (int data type).
--Think of a way to check that the function is working properly, and verify that the result is accurate.


--3.Continue on from the previous question. In order to check the accuracy of the function, run the two queries below and compare the results. One query uses the function
--The other query performs the same calculation as the function. When the two queries are run, the answers obtained in both should be identical. 
--(If the answer is not the same, there is an error in one of the queries)
		--a. Select dbo.fnGetOrderCustomer(43767) as CustID
		--b. Select SalesOrderID, CustomerID from sales.SalesOrderHeader where SalesOrderID = 43767
--Step1: build query
select CustomerID
from Sales.SalesOrderHeader
where SalesOrderID=43767
--Step2: Add function elements
create or alter function fnGetOrderCustomer (@OrderNumber int)
returns int
as
begin
	select CustomerID
	from Sales.SalesOrderHeader
	where SalesOrderID=43767
end
--Step3: Modify what is wrong or needs to be altered
create or alter function fnGetOrderCustomer (@OrderNumber int)
returns int
as
begin
	declare @Result int --2.Declare variable para ahi drop resultado
	select @Result=CustomerID --3.Asignarle operacion
	from Sales.SalesOrderHeader
	where SalesOrderID=@OrderNumber --1.Link parameter to query
	return @Result --4.Drop the result
end
--Step 4: Try it
select dbo.fnGetOrderCustomer (43767) as CXIDasFunction

--4.Create a new function called fnGetProductOrderAmount, which takes a ProductID and a year, and returns the SubTotal for that product in that year.
--Think what data type the function returns. Call the function and send a parameter. Check that the result is correct.
--Step1: Query
select sum(LineTotal) as SubtotalperProduct
from Sales.SalesOrderDetail sod join Sales.SalesOrderHeader soh on sod.SalesOrderID=soh.SalesOrderID
where year(OrderDate)=2013 and ProductID=712
--Step2: Convert it into a function
create or alter function fnGetProductOrderAmount (@Year int, @ProductID int)
returns decimal (38,6)
as
begin
	declare @Result as decimal (38,6)
	select @Result=sum(LineTotal)
	from Sales.SalesOrderDetail sod join Sales.SalesOrderHeader soh on sod.SalesOrderID=soh.SalesOrderID
	where year(OrderDate)=@Year and ProductID=@ProductID
	return @Result 
end

select dbo.fnGetProductOrderAmount(2013,712) as 'SubtotalperProduct as Function'

--5.In the same way as in the previous question, create a new function called fnGetProductOrderQty that takes a ProductID and a year, and returns the OrderQty 
--for that product in that year. Think what data type the function returns. Call the function and send a parameter. Check that the result is correct.
create or alter function fnGetProductOrderQTY (@Year int, @ProductID int)
returns int
as
begin
	declare @Result int
	select @Result=sum(OrderQty)
	from Sales.SalesOrderDetail sod join Sales.SalesOrderHeader soh on sod.SalesOrderID=soh.SalesOrderID
	where year(OrderDate)=@Year and ProductID=@ProductID
	return @Result 
end

select dbo.fnGetProductOrderAmount(2013,712) as 'QTYperProduct as Function'

--6.Write a query based on the product table that uses the functions from the previous two questions and displays the product code, product name, SubTotal in 2012 
--and OrderQty in 2012 for each product in the product table. Do you think it is necessary to filter the results so that only products that were actually ordered in 2012 
--are displayed, or is there also significance to the information in the unsold rows?
select ProductID, Name,
		dbo.fnGetProductOrderAmount(2012, ProductID) as OrderAmount2012, 
		dbo.fnGetProductOrderQTY(2012, ProductID) as OrderQTY2012
from Production.Product

--7.Create a new function called fnSalesPerYear that takes a year as a parameter (e.g., 2013, 2014 ... What type of variable is this?), and returns the SubTotal in 
--that year from the Order header file. Call the function and send it a parameter. Check that the result is correct
		--a. Parameter: an integer (int) that represents a year
		--b. Value returned from the function: a decimal number: decimal (10,2), i.e., a total of 10 digits, two of which are after the decimal point.
		--c. Hint 1: A variable should be used.
		--d. Hint 2: Think how you could write a query that does this.
create  or alter function fnSalesperYear (@year int)
returns decimal (38,6)
as
begin
	declare @Result decimal (38,6)
	select @Result=sum(Subtotal)
	from Sales.SalesOrderHeader
	where year(OrderDate)=@year
	return @Result
end

select dbo.fnSalesperYear (2013) as SalesPerYear


--CORRECT THIS ONE!!!!!
--8.Following on from the previous question, modify the fnSalesPerYear function so it takes two parameters: year and BusinessEntityID. The function will return the 
--order amount for that BusinessEntityID in the specified year. Detailed instructions:
		--a. The function will take two parameters of data type int (for entity number and year).
		--b. Recall the relationships between the Sales.SalesOrderHeader table and the Person.Person table, and how to filter orders by BusinessEntityID.
			--Refer to the ERD file.
create  or alter function fnSalesperYear (@year int, @BusinessEntityID int)
returns decimal (38,6)
as
begin
	declare @Result decimal (38,6)
	select  @Result=sum(Subtotal)
	from Sales.SalesOrderHeader soh join Sales.Customer c on soh.CustomerID=C.CustomerID
	where year(OrderDate)=@year and c.PersonID=@BusinessEntityID
	return @Result
end
select dbo.fnSalesperYear (2010, 285) as 'SalesperYear for CX44 in 2010'

select *
from Sales.Customer


--9.Continuing on from the previous question, write a query based on the Persons table, that displays the BusinessEntityID, first name, last name and total of orders by
--that person in 2013. Filter the results to display only the people who ordered products in 2013. A point to consider:
--Note that running a function from a query requires system resources, so there is a price to pays in run time. 
--It is, therefore, important to decide when there is an advantage to using a function and when it is worthwhile to write a standard query.
select BusinessEntityID, FirstName, LastName,
	dbo.fnSalesperYear(2010, BusinessEntityID)
from Person.Person