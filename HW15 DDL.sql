--LESSON 15
--1.Check that you have a database called Test_DML. (It was created during the class practice.) If not, copy and run the following line of code:
Create database Test_DML

--2. Now begin to work on the new DB: Test_DML
use Test_DML

--3. Create a new table named "student" (with commands or with the UI) that contains 3 fields:
		--a. Student number (int) - primary key
		--b. First name - string 15
		--c. Last name - string 15
create table Student (StudentNumber int Primary Key, 
						FirstName nvarchar (15), 
						LastName nvarchar (15))
select *
from Student

--4. Add a nonclustered index to the student table. The index will be on the First name and then on the Last name.
create index StudentIndex on Student (FirstName, LastName)

--5. Add another field called "Email", a string 255 type, to the new Student table.
alter table Student add Email nvarchar (255)

select *
from Student

--6. Add two records to the student table: the first with your details, and the second with another student's details.
insert into Student
values (1, 'AmeyallI', 'Hernandez', 'ameyallihdz@hotmail.com'),
		(2, 'Marisol', 'LastName', 'solgreystine@gmail.com')

select *
from Student

--7. Change the second student's last name to a new last name.
update Student
set LastName='Cortes'
where LastName='LastName'

select *
from Student

--8. Change the other student's email to his or her email address.
update Student
set Email='solcortes@gmail.com'
where Email='solgreystine@gmail.com'

select *
from Student

--9.After reexamining the table structure, it was decided that there is no need for the Email column, so please remove the Email column from the Student table.
alter table Student
drop column Email

select *
from Student

--10. Go back to the AdventureWorks database we usually work with, and create a VIEW called vSaleItemDetails that contains the detailed order data, i.e., a combination of
--the data from Order details, Order header, Customer data and Product details, as follows:
		--a. Order details: Order number, Discounted item price (calculated), Total payment per order.
		--b. Order header: Order Date, Customer ID.
		--c. Persons table: First name, Last name.
		--d. Items table: Item name, Item color.
--Step 1: create query
select
    sod.SalesOrderID AS OrderNumber,  
    (sod.UnitPrice - sod.UnitPriceDiscount) AS DiscountedItemPrice,  
    sod.LineTotal AS TotalPaymentPerOrder,  
    soh.OrderDate,  
    soh.CustomerID,  
    p.FirstName,  
    p.LastName,  
    pr.Name AS ItemName,  
    pr.Color AS ItemColor  
from Sales.SalesOrderDetail sod  join Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID  
								join Sales.Customer c ON soh.CustomerID = c.CustomerID  
								join Person.Person p ON c.PersonID = p.BusinessEntityID  
								join Production.Product pr ON sod.ProductID = pr.ProductID;

--Step 2: create view
create view vSaleItemDetails AS  
select
    sod.SalesOrderID AS OrderNumber,  
    (sod.UnitPrice - sod.UnitPriceDiscount) AS DiscountedItemPrice,  
    sod.LineTotal AS TotalPaymentPerOrder,  
    soh.OrderDate,  
    soh.CustomerID,  
    p.FirstName,  
    p.LastName,  
    pr.Name AS ItemName,  
    pr.Color AS ItemColor  
from Sales.SalesOrderDetail sod  join Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID  
								join Sales.Customer c ON soh.CustomerID = c.CustomerID  
								join Person.Person p ON c.PersonID = p.BusinessEntityID  
								join Production.Product pr ON sod.ProductID = pr.ProductID;


--11. Such a VIEW can make which calculations, reports or statistics easier?
			--Yes. Creating the vSaleItemDetails view can simplify several calculations, reports, and statistics related to sales, customer behavior, and product performance. 
--12. Prepare a list of 3 Views that you think will be useful in your regular work as an analyst. Describe in general terms what the purpose of the VIEW is, what it should
--contain and what can be deduced from it.