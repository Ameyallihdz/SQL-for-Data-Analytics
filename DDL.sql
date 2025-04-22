--1. Create a new database called Test_DD. From now on, in this practice, this is the only database that will be used.
create DATABASE Test_DDL
use Test_DDL --To change an use the new data base

--2. Add a new table called Departments to the database. The table will contain the following columns: a. DepartmentCode: an integer, Primary key
--b. Name: A string up to 10 characters long
create table Departments (DepartmentCode int primary key,
							Name nvarchar (10))

--3.Create another index for the Departments table that sorts the data according to the value in the Name column.
create index IX_Department_Name on Departments (Name asc)

--4.Add a new table called Employees to the database. The table will contain the following columns:
	--a. EmployeeNo : an integer, Primary key
	--b. FirstName: a tring up to 20 characters long
	--c. LastName: a string up to 20 characters long
	--d. PhoneNo : a string up to 15 characters long
	--e. Department: an integer, Foreign key to the DepartmentCode column in the
	--Departments table f. Country: a string up to 20 characters long, default is "USA"
create table employees (employees int primary key,
						FirstName nvarchar (20),
						LastNAme nvarchar (20),
						PhoneNo nvarchar (15),
						Department int Foreign key references Departments(DepartmentCode),
						Country nvarchar (20) default 'USA'
						)

--5.Create another index for the Employees table that sorts the data first according to the value in the Department column, in ascending order, and second according to
--the EmployeeNo column, in descending order
create index IX_Employees_Department_Employeeno on employees (Department asc,
																Employees desc)

--PART2
--1. Add a column called Location, a 50 character string, to the Departments table. Set the default value in the column as: Main Office
alter table Departments 
add Location nvarchar (50) default 'Main Office'
--Comprobar
select *
from Departments

--2.Add a column called BirthDate, which will contain date or date and time data, to the Employees table.
alter table Employees
add Birthdate  datetime 
--Comprobar
select *
from Employees

--3.After review, it appears that there is no need for the PhoneNo column in the Employees table. Delete this column from the table.
alter table Employees
drop column PhoneNo
--Comprobar
select *
from Employees

--4.After further review, it appears that there is no need for an Employees table. Delete this table.
drop table Employees --not Trunck because este solo borra el content

--5.Write a query based on the data in the AdventureWorks database, and insert the query results into a new table named Orders in the Test_DDL database.
--The query will display the following columns from the order data: SalesOrderID, OrderDate, CustomerID, ProductID, OrderQty and LineTotal.
select  soh.SalesOrderID, OrderDate, CustomerID, ProductID, OrderQty, LineTotal
into Orders
from AdventureWorks2016.Sales.SalesOrderHeader soh join AdventureWorks2016.Sales.SalesOrderDetail sod on soh.SalesOrderID=sod.SalesOrderID

--6.Continuing from the previous section, add a column called SpecialSale to the Orders table. The data type in this column will be an integer (int) and the default
--value 0. (Explanation: The reason for this field is to designate the special sales. 
--These will be defined according to criteria that will be specified in the following questions.)
alter table Orders
add SpecialSale int default 0 --int son numeros y no llega ''

select *
from Orders

--7.Display the data in the Orders table.
	--a. What are the values in the SpecialSale column? NULL
	--b. Why does the column not contain 0 values, even though the default value was set as 0? 
			--Because default only applies to new records, not to existing records (you select into orders), then you set SpecialSales

--8.Reset (update the value to 0) the SpecialSale field for all the rows in the Orders table.
update Orders
set SpecialSale=0

select *
from Orders

--9.Now, it has been decided that a special order record is any order row with a LineTotal over $ 10,000.
--Update the SpecialSale field to 1 only for the sales with a LineTotal over 10,000.
update Orders
set SpecialSale = 1
where LineTotal>10000

--10.Write a query that displays all the columns from the Orders table. Sort the data by LineTotal in descending order. 
--Use this query to check the results of the previous query.
select *
from Orders
order by LineTotal desc

--11. Delete all the rows in the Orders table that have an order date from 2012 and the value 1 in the SpecialSale column.
delete from Orders
where OrderDate between '2012/01/01' and '2012/12/31' and SpecialSale=1

select *
from Orders

--12. Delete all the data in the Orders table.
truncate table Orders

--13. Delete the Orders table.
drop table Orders


--PART 3
--1.Be sure to check after each section that the operation ran successfully. You will work as an analyst. Assessing your performance is necessary and critical for your
--professional integrity.
		--1. Create a new VIEW called vSaleFullDetails that will display data from an Order details table (to be defined in next paragraph), together with important 
		--fields from an Order header table. The fields to be displayed: 
		--Order number, Order date, Customer number, Quantity ordered, Item price after discount (calculated field – give it a name), total to be paid per row.
		--Note : Examine the columns, recognize the meaning of the values in the columns, and calculate the price after discount. There are several ways to calculate the value
		--in this column. Be sure that you are calculating correctly. It is best to take one line as an example and calculate it manually to check the result.
--1st check que el query funcione > 2.Hacerlo View (guardarlo en SQL saver con el nombre de VSaleFullDetails)
create view vSaleFullDetails as
select soh.SalesOrderID, OrderDate, CustomerID, OrderQTY, ProductID, (1-UnitPriceDiscount)*UnitPrice as UnitPriceAfterDiscount, LineTotal
from Sales.SalesOrderheader soh join Sales.SalesOrderDetail sod on soh.SalesOrderID=sod.SalesOrderID

--2.Continuing from the previous question, display the VIEW that was created (vSaleFullDetails).
select *
from vSaleFullDetails

--3.Continuing from the previous question, add the following data to the VIEW in the place that seems to be most correct column order: 
--First name of the customer, Last name of the customer. In addition, limit sales details to sales in 2013 only.
alter view VSaleFullDetails as
select soh.SalesOrderID, OrderDate, c.CustomerID, OrderQTY, ProductID, (1-UnitPriceDiscount)*UnitPrice as UnitPriceAfterDiscount, LineTotal, FirstName, LastName
from Sales.SalesOrderheader soh join Sales.SalesOrderDetail sod on soh.SalesOrderID=sod.SalesOrderID
								join Sales.Customer c on soh.CustomerID=c.CustomerID
								join Person.Person p on c.PersonID=p.BusinessEntityID
where OrderDate between '2013/01/01' and '2013/12/31'

--4.Continuing from the previous question, run the query from question 2 again and check that the changes were successfully done.
select *
from vSaleFullDetails

--5.Create a new VIEW called vSalePerYearSeller that will display the total quantity and value of sales for each SalesPersonID each year (i.e., record for seller 1 for 2011,
--record for seller 1 year 2012 ... record for seller 2 year 2011, etc.)
--The fields that to be displayed: Year, SalesPersonID, Total quantity of items sold and Total sales price, grouped by year and seller.
create or alter view vSalesPerYearSeller as
select year(OrderDate) as Year, SalesPersonID, sum(OrderQTY) as TotalQTY, sum(LineTotal) as TotalPrice
from Sales.SalesOrderHeader soh join Sales.SalesOrderDetail sod on soh.SalesOrderID=sod.SalesOrderID
group by year(OrderDate), SalesPersonID

select * 
from vSalesPerYearSeller
order by Year, SalesPersonID


--6. Display the records in the query sorted according to year and salesperson, to create an "Annual sales report by seller":
		--a. Try to find a way to sort the records as requested. Only after you have tried, move on to the next section – whether you succeeded and especially if you did not.
		--b. The ORDER BY phrase cannot be written into VIEW, so in order to sort data, a query must be written to retrieve the data and sort it. Do this.