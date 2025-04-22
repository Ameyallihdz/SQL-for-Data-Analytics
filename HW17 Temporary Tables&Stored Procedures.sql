--LESSON 17
--1. Challenge Question. Create a procedure called spSubcategoryMinMax that executes a query based on the Products table, 
--and displays the following data for each subcategory (ProductSubcategoryID):
		--the ProductSubcategoryID, the ProductID with the lowest ListPrice in this subcategory, and the ProductID with the highest ListPrice in this sub-category.
--Hint 1: Subquery. Hint 2: Related sub query + additional operations for retrieving data
--PreStep: Preview
select ProductSubcategoryID, ProductID, ListPrice
from Production.Product
--STEP1: Query that gives me just categories
select ProductSubcategoryID
from Production.Product 
where ProductSubcategoryID is not null
group by ProductSubcategoryID
--STEP 1.1: Verify Results MAX & MIN
select ProductSubcategoryID, ProductID, ListPrice
from Production.Product
where ProductSubcategoryID=3
order by ListPrice desc
--STEP2: Include max and min values
select pp.ProductSubcategoryID, (select top 1 pmax.ProductID
								from Production.Product	pmax
								where pmax.ProductSubcategoryID=pp.ProductSubcategoryID
								order by ListPrice asc) as MinID, --Give me the top 1 depending on the ProductSubcategory from outside
								(select top 1 pmin.ProductID
								from Production.Product	pmin
								where pmin.ProductSubcategoryID=pp.ProductSubcategoryID
								order by ListPrice desc) as MaxID
from Production.Product pp
where ProductSubcategoryID is not null
group by ProductSubcategoryID
--STEP3: Convert it into procedure
create or alter procedure spSubcategoryMinMax
as
begin
	select pp.ProductSubcategoryID, (select top 1 pmax.ProductID
								from Production.Product	pmax
								where pmax.ProductSubcategoryID=pp.ProductSubcategoryID
								order by ListPrice asc) as MinID, --Give me the top 1 depending on the ProductSubcategory from outside
								(select top 1 pmin.ProductID
								from Production.Product	pmin
								where pmin.ProductSubcategoryID=pp.ProductSubcategoryID
								order by ListPrice desc) as MaxID
	from Production.Product pp
	where ProductSubcategoryID is not null
	group by ProductSubcategoryID
end


--2. Call the procedure and check the correctness of the results by running the following code: Exec spSubcategoryMinMax
Exec spSubcategoryMinMax


--OPTIONA WRONG
--STEP1: Query that gives me the MaxID
with CTE
as(
	select ProductSubcategoryID, FIRST_VALUE(ProductID) over(partition by ProductSubCategoryID order by ListPrice desc) as MaxID
	from Production.Product
	where ProductSubcategoryID is not null)
select distinct ProductSubcategoryID, MaxID
from CTE

--STEP 1.1: Verify Results MAX & MIN
select ProductSubcategoryID, ProductID, ListPrice
from Production.Product
where ProductSubcategoryID=3
order by ListPrice desc

--STEP 1.2: Query that gives me the MaxID+MinID
with CTE
as(
	select ProductSubcategoryID, FIRST_VALUE(ProductID) over(partition by ProductSubCategoryID order by ListPrice asc) as MinProductID,
									FIRST_VALUE(ProductID) over(partition by ProductSubCategoryID order by ListPrice desc) as MaxProductID
	from Production.Product
	where ProductSubcategoryID is not null)
select distinct ProductSubcategoryID, MinProductID, MaxProductID
from CTE

--STEP2: Convert it to procedure
create or alter procedure spSubcategoryMinMax
as
begin
	with CTE
as(
	select ProductSubcategoryID, FIRST_VALUE(ProductID) over(partition by ProductSubCategoryID order by ListPrice asc) as MinProductID,
									FIRST_VALUE(ProductID) over(partition by ProductSubCategoryID order by ListPrice desc) as MaxProductID
	from Production.Product
	where ProductSubcategoryID is not null)
select distinct ProductSubcategoryID, MinProductID, MaxProductID
from CTE
end
