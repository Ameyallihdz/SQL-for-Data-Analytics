--LESSON 14
--After each section, be sure to check that what you did works, and that the data has changed!
--You will work as an analyst. Checking your work is necessary and critical for your professional credibility.

--1. Check that you have a database called Test_DML. (It was created during the class practice.) If not, copy and run the following line of code:
create database Test_DML

--2.In the Test_DML database, create a table with the same format as the Order header table, with all the data about the orders in 2011. Name the table SalesOrderHeader2011.
--Step1: Review SSOHeader
select *
from Sales.SalesOrderHeader
where OrderDate between '2011-01-01' and '2011-12-31'
--where year(OrderDate)='2011'
--Step2: Create the new table
select * 
into SalesOrderHeader2011
from Sales.SalesOrderHeader
where OrderDate between '2011-01-01' and '2011-12-31'

--3. In the Test_DML database, create a table with the same format as the Order details table, with all the order records for 2011. Name the table SalesOrderDetail2011.
--Step 1: Check the columns from SODetail Table
select *
from Sales.SalesOrderDetail
--Step 2: Join tables to meet the conditions and just display columns from SODetail Table
select sod.SalesOrderID, soh.Orderdate, sod.SalesOrderDetailID, sod.CarrierTrackingNumber, sod.OrderQty, sod.ProductID, sod.SpecialOfferID, sod.UnitPrice, 
		sod.UnitPriceDiscount, sod.LineTotal, sod.rowguid, sod.ModifiedDate
from Sales.SalesOrderDetail sod left join Sales.SalesOrderHeader soh on sod.SalesOrderID=soh.SalesOrderID
where soh.OrderDate between '2011-01-01' and '2011-12-31'
--Step 3: Create the table in the new data base
use Test_DML
select sod.SalesOrderID, soh.Orderdate, sod.SalesOrderDetailID, sod.CarrierTrackingNumber, sod.OrderQty, sod.ProductID, sod.SpecialOfferID, sod.UnitPrice, 
		sod.UnitPriceDiscount, sod.LineTotal, sod.rowguid, sod.ModifiedDate
into Test_DML.dbo.SalesOrderDetail2011
from Sales.SalesOrderDetail sod left join Sales.SalesOrderHeader soh on sod.SalesOrderID=soh.SalesOrderID
where soh.OrderDate between '2011-01-01' and '2011-12-31'

--4. Now begin to work on the new DB: Test_DML
use Test_DML

--5. Change the date of all the orders from the month of May to the date 31-01-2011.
--Step 1: Modify the last query created (4): by first drop table and then, Add the column OrderDate from Sales.SalesOrderHeader
--Step 2: Review results from just January 2011 and May 2011 to see how many results must be in total at the end
select *
from Test_DML.dbo.SalesOrderDetail2011
--where OrderDate between '2011-01-01' and '2011-01-31' --No results for January 2011
where OrderDate between '2011-05-01' and '2011-05-31'
--Step3: Change values
update Test_DML.dbo.SalesOrderDetail2011
set OrderDate='2011-01-31'
where OrderDate between '2011-05-01' and '2011-05-31'

--6. Check that section 5 worked properly. How can this be checked?
select *
from Test_DML.dbo.SalesOrderDetail2011
where OrderDate between '2011-01-01' and '2011-01-31' 
--where OrderDate between '2011-05-01' and '2011-05-31' --No data for May 2011