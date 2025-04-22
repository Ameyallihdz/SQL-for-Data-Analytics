--LESSON 13 PANESL
--Do the main programa and then make it as a temporary ptable
select soh.SalesOrderID,sod.OrderQty, sod.unitpricediscount, year(soh.OrderDate) as OrderYear, pp.color, sod.UnitPrice, pp.StandardCost, sod.LineTotal,
		(sod.LineTotal/sod.OrderQty)-pp.StandardCost as UnitProfit
into #PanelEDA
from production.Product pp join sales.SalesOrderDetail sod on pp.ProductID = sod.ProductID
							join sales.SalesOrderHeader soh on sod.SalesOrderID = soh.SalesOrderID

--If yoy make a mistake, you need to drop the table fists
drop table #PanelEDA

select *
from #PanelEDA

--LESSON 14
--1. Write a query that creates a new table called MarketingContacts with the following columns from the PersonPerson and Person.EmailAddress tables:
--BusinessEntityID, First name, Middle name, Last name, Email address. Display only people who are classified in PersonType as 'IN' and for whom the type
--of business promotion specified in their EmailPromotion details is 1.
select pp.BusinessEntityID, FirstName, MiddleName, LastName, EmailAddress	
from Person.Person pp join Person.EmailAddress pe on pp.BusinessEntityID=pe.BusinessEntityID
where pp.PersonType='IN' and pp.EmailPromotion=1

--2. Display all the data from the new table, MarketingContacts.
select pp.BusinessEntityID, FirstName, MiddleName, LastName, EmailAddress	
into MarketingContacts
from Person.Person pp join Person.EmailAddress pe on pp.BusinessEntityID=pe.BusinessEntityID
where pp.PersonType='IN' and pp.EmailPromotion=1

select *
from MarketingContacts

--3.The cashier made an error while typing the data and a line was omitted. Therefore, add the following data as one more row in the MarketingContacts table:
--BusinessEntityID = 30000, First name = Noam, Last name = Morchi, Email = noam811@adventure-works.com
insert into MarketingContacts (BusinessEntityID, FirstName, LastName, EmailAddress)
values (3000, 'Noam', 'Morchi', 'noam811@adventure-works.com')

--4. Continuing from the previous question, in order to check that the data was input to the MarketingContacts table correctly, write a query that displays only the input row.
select *
from MarketingContacts
where BusinessEntityID=3000

--5. Write a query that creates a new table called NewProductTable with the following columns from the tables we are working with: 
--a. Product ID, b. Category code c, Category name, d. Sub-category code, e. Sub-category name, f. List price, g. Item cost 
--Note: Consider from which table each field should be taken.
select ProductID, pc.ProductCategoryID as CategoryCode, pc.Name as CategoryName, psc.ProductCategoryID as SubCategoryCode, psc.Name as SubCategoryName, 
		pp.ListPrice, pp.StandardCost
into NewProductTable 
from Production.Product pp join Production.ProductSubcategory psc on pp.ProductSubcategoryID=psc.ProductSubcategoryID
							join Production.ProductCategory pc on psc.ProductCategoryID=pc.ProductCategoryID

drop table NewProductTable

--6. Continuing from the previous question, display the table you created.
select *
from NewProductTable

--7. Write a query that adds the following records:
insert into NewProductTable
values (100, 2, 'Components', 12, 'Mountain Frames', 500, 280),
		(101, 3, 'Components', 20, 'Gloves', 480, 110)

--8. Continuing from the previous question, write a query that displays only the two rows that were added to the table.
select *
from NewProductTable
where ProductID in ('100', '101')
where ProductID=100 or ProductID=101

--9. To prepare for the next section, create a new database . Choose from one of the two following methods
		--a. Right-click on the DataBases folder 🡪 NewDatabase Then, choose a new name for your database, and click OK.
		--b. Run the following command to create a new database called Test_DML: create database Test_DML. Once you have created the new database, 
		--go to the Databases folder and click Refresh (rounded arrow in blue)

create database test_DHL

--10.Write a query that creates a new table called SalesPerCustomer2012 in the new database (Test_DML) that displays the SubTotal of each customer for the orders they
--placed in 2012. The table should consist of the following columns: Customer ID, First name, Last name and SubTotal of the orders from 2012.
--Instruction: Write a query that displays the total payment for all orders in 2012 for each customer, and the other columns listed.
--Once the query displays the desired data, add a line of code to the query to make it a Select Into query to add the results to another database.
--If you do not remember how, consult the lesson presentation. Refer to the following question to see a preview of the resulting table.
select sc.CustomerID, pp.FirstName, pp.LastName, sum(soh.SubTotal) as TotalSales
into test_DHL.dbo.SalesPerCustomer2012 --NameofDatabase.DBO.Newtable
from Sales.SalesOrderHeader soh join Sales.Customer sc on soh.CustomerID=sc.CustomerID
								join Person.Person pp on sc.PersonID=pp.BusinessEntityID
--where year(soh.OrderDate)=2012 -->Could slow query
where soh.OrderDate between '2012/01/01' and '2012/12/31'
group by sc.CustomerID, pp.FirstName, pp.LastName

drop table test_DHL.dbo.SalesPerCustomer2012 --Por si te equivocas

--11.Write a query that displays the resulting table. Pay attention which database you are running the query on.
select *
from test_DHL.dbo.SalesPerCustomer2012
use test_DHL --ServesForSelectingTheDataBaseUsed

--PART2
--1.In the NewProductTable, delete the rows with a ListPrice equal to 0. How many lines were deleted?
select *
from NewProductTable
where ListPrice=0

select ProductID, pc.ProductCategoryID as CategoryCode, pc.Name as CategoryName, psc.ProductSubCategoryID as SubCategoryCode, psc.Name as SubCategoryName, 
		pp.ListPrice, pp.StandardCost
into NewProductTable 
from Production.Product pp join Production.ProductSubcategory psc on pp.ProductSubcategoryID=psc.ProductSubcategoryID
							join Production.ProductCategory pc on psc.ProductCategoryID=pc.ProductCategoryID

insert into NewProductTable
values (100, 2, 'Components', 12, 'Mountain Frames', 500, 280),
		(101, 3, 'Components', 20, 'Gloves', 480, 110)

--3.Update the SubCategoryName of product number 709 in the NewProductTable to read: Blue Socks. What was the value before the change?
select *
from NewProductTable
where ProductID=709

update NewProductTable
set SubcategoryName='Blue Socks'
where ProductID=709

--4.Update the SubCategoryName of all the products with the ProductSubcategoryID 24 in the NewProductTable table to read: Long tights. What was the value before the change?
drop table NewProductTable
select *
from NewProductTable
where SubCategoryCode = 24

update NewProductTable
set SubCategoryName='Long Thights'
where SubCategoryCode=24

--5.Write a query that displays the Product ID and ListPrice columns from the NewProductTable only for the items with ProductIDs 100 and 101. 
-- What is the list price of these two items?
select *
from NewProductTable
where ProductID in (100,101)

--6.The list prices of products number 100 and 101 in the NewProductTable table increased by 10%. Write a query that will update the new prices of these products in
--the NewProductTable. What is the list price after the price raise?

update NewProductTable
set ListPrice=ListPrice*1.1
where ProductID in (100,101)

--7.In the NewProductTable, delete all the rows with a product code between 700 and 850 (inclusive) and a ProductCategoryID of 2 or 3.
--How many rows were deleted?
delete from NewProductTable
where ProductID between 700 and 850 and (CategoryCode=2 or CategoryCode=3)

--8.Delete all the rows in the NewProductTable.
delete from NewProductTable
truncate TABLE newproducttable --Alternative to delete a whole table (make the table empty)