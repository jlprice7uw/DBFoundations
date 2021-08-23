--*************************************************************************--
-- Title: Assignment06
-- Author: JPrice
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,JPrice,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_JPrice')
	 Begin 
	  Alter Database [Assignment06DB_JPrice] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_JPrice;
	 End
	Create Database Assignment06DB_JPrice;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_JPrice;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BASIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

--Select * from Products;
--Select * from Categories;
--Select * from Inventories;
--Select * from Employees;

/* No 'work' shown here,as it is just the Create view syntax with columns listed. 
Used Select view to check work */
go
Create View
	vProducts
	With SchemaBinding
	As
	Select
	 ProductID
	,ProductName
	,CategoryID
	,UnitPrice
	From dbo.Products;
go
--Select * from vProducts;
go
Create View
	vCategories
	With SchemaBinding
	As
	Select
	 CategoryID
	,CategoryName
	From dbo.Categories;
go
--Select * from vCategories;
--go
go
Create View
	vInventories
	With SchemaBinding
	As
	Select
	 InventoryID
	,InventoryDate
	,EmployeeID
	,ProductID
	,[Count]
	From dbo.Inventories;
go
--Select * from vInventories;
go
Create View
	vEmployees
	With SchemaBinding
	As
	Select
	 EmployeeID
	,EmployeeFirstName
	,EmployeeLastName
	,ManagerID
	From dbo.Employees;
go
--Select * from vEmployees;

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select on Products to Public;
Deny Select on Categories to Public;
Deny Select on Inventories to Public;
Deny Select on Employees to Public;
go

Grant Select on vProducts to Public;
Grant Select on vCategories to Public;
Grant Select on vInventories to Public;
Grant Select on vEmployees to Public;
go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

/* copy / pasted code from Assignment05 and changed table names to use BASIC Views created in Q1 */
--Select C.CategoryName, P.ProductName, P.UnitPrice
--	From vProducts as P Inner Join vCategories as C
--	On P.CategoryID = C.CategoryID
--	Order by C.CategoryName, P.ProductName;
--go

/* nesting above select statement into view creation */
--Create View
--	vCategoriesAndProductsWithPrices
--	As
--	Select C.CategoryName, P.ProductName, P.UnitPrice
--	From vProducts as P Inner Join vCategories as C
--	On P.CategoryID = C.CategoryID
--	Order by C.CategoryName, P.ProductName;
--go

/* have to insert 'top' clause for 'order by' to work */
/* FINAL ANSWER: */
go
Create View
	vCategoriesAndProductsWithPrices
	As
	Select Top 1000000 C.CategoryName, P.ProductName, P.UnitPrice
	From vProducts as P Inner Join vCategories as C
	On P.CategoryID = C.CategoryID
	Order by C.CategoryName, P.ProductName;
go

--Select * from vCategoriesAndProductsWithPrices;
--go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

/* code from assignment 05, changing to reference Basic Views rather than directly
selecting from tables: */
--Select P.ProductName, I.InventoryDate, I.Count as [Inventory Count]
--	From vProducts as P Inner Join  vInventories as I
--	On P.ProductID = I.ProductID
--	Order by InventoryDate, ProductName, Count;
--go

/* copying above into a Create View statement -- wil need to add a 'Top' to use 'order by' */
/* FINAL ANSWER: */
Create View
	vProductInventoriesByDate
	As
	Select Top 100000 P.ProductName, I.InventoryDate, I.Count as [Inventory Count]
	From vProducts as P Inner Join vInventories as I
	On P.ProductID = I.ProductID
	Order by I.InventoryDate, P.ProductName, I.Count;
go

--Select * from vProductInventoriesByDate;
--go

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

/* copying code from Assign05; changing direct table references
to basic views*/

--Select Distinct I.InventoryDate, 
--	EmployeeName = E.EmployeeFirstName + ' ' + E.EmployeeLastName
--	From vInventories as I Inner Join vEmployees as E
--	On I.EmployeeID = E.EmployeeID
--	Order by InventoryDate;
--go

/* copying above code into create view -- adding 'top' for 'order by'
to work */
/*final answer*/
go
Create View
	vInventoryDatesAndEmployees
	As
	Select Distinct Top 10000 I.InventoryDate, 
	EmployeeName = E.EmployeeFirstName + ' ' + E.EmployeeLastName
	From vInventories as I Inner Join vEmployees as E
	On I.EmployeeID = E.EmployeeID
	Order by InventoryDate;
go

--Select * from vInventoryDatesAndEmployees;
--go

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

/* code copied from assignment 05*/

--Select C.CategoryName, P.ProductName, I.InventoryDate, I.Count
--	From Products as P Inner Join Categories as C
--	On P.CategoryID = C.CategoryID
--	Join Inventories as I
--	On P.ProductID = I.ProductID
--	Order by CategoryName, ProductName, InventoryDate, Count;
--go

/*changing direct table refs to use basic views */
--Select C.CategoryName, P.ProductName, I.InventoryDate, I.Count
--	From vProducts as P Inner Join vCategories as C
--	On P.CategoryID = C.CategoryID
--	Join vInventories as I
--	On P.ProductID = I.ProductID
--	Order by CategoryName, ProductName, InventoryDate, Count;
--go
/* inserting into Create View with Top for Order By */
/* final answer */
go
Create View
	vProductInventoriesByCategoryAndDate
	As
	Select Top 100000 C.CategoryName, P.ProductName, I.InventoryDate, I.Count
	From vProducts as P Inner Join vCategories as C
	On P.CategoryID = C.CategoryID
	Join vInventories as I
	On P.ProductID = I.ProductID
	Order by CategoryName, ProductName, InventoryDate, Count;
go

--Select * from vProductInventoriesByCategoryAndDate;
--go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

/* copying code from Assignment 05 */
--Select C.CategoryName
--	,P.ProductName
--	,I.InventoryDate
--	,I.Count
--	,EmployeeName = E.EmployeeFirstName + ' ' + E.EmployeeLastName
--	From Products as P Inner Join Categories as C
--	On P.CategoryID = C.CategoryID
--	Join Inventories as I
--	On P.ProductID = I.ProductID
--	Join Employees as E
--	On I.EmployeeID = E.EmployeeID
--	Order by InventoryDate, CategoryName, ProductName, EmployeeName;
--go

/* change to basic view references */

--Select C.CategoryName
--	,P.ProductName
--	,I.InventoryDate
--	,I.Count
--	,EmployeeName = E.EmployeeFirstName + ' ' + E.EmployeeLastName
--	From vProducts as P Inner Join vCategories as C
--	On P.CategoryID = C.CategoryID
--	Join vInventories as I
--	On P.ProductID = I.ProductID
--	Join vEmployees as E
--	On I.EmployeeID = E.EmployeeID
--	Order by InventoryDate, CategoryName, ProductName, EmployeeName;
--go

/* copying select statement into Create View, adding Top for Order By to work */
/* final answer */
go
Create View
	vInventoriesWithEmployeeByDateCategoryProduct
	As
	Select Top 1000000 C.CategoryName
	,P.ProductName
	,I.InventoryDate
	,I.Count
	,EmployeeName = E.EmployeeFirstName + ' ' + E.EmployeeLastName
	From vProducts as P Inner Join vCategories as C
	On P.CategoryID = C.CategoryID
	Join vInventories as I
	On P.ProductID = I.ProductID
	Join vEmployees as E
	On I.EmployeeID = E.EmployeeID
	Order by InventoryDate, CategoryName, ProductName, EmployeeName;
go

--Select * from vInventoriesWithEmployeeByDateCategoryProduct;
--go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

/* copying from Assignment 05; changing to reference Basic Views */

--Select C.CategoryName, P.ProductName, I.InventoryDate, I.Count,
--	EmployeeName = E.EmployeeFirstName + ' ' + E.EmployeeLastName
--	From vCategories as C Inner Join vProducts as P
--		On C.CategoryID = P.CategoryID
--	Inner Join vInventories as I 
--		On P.ProductID = I.ProductID
--	Inner Join vEmployees as E
--		On I.EmployeeID = E.EmployeeID
--	Where P.ProductID in
--		(Select ProductID
--			From Products
--			Where ProductName in ('Chai','Chang')
--		)
--	Order by InventoryDate,CategoryName,ProductName;
--go

--/* inserting into Create View with Top for Order By to Work */
go
Create View
	vChaiChangInventoriesWithEmployee
	As
	Select Top 1000 C.CategoryName, P.ProductName, I.InventoryDate, I.Count,
	EmployeeName = E.EmployeeFirstName + ' ' + E.EmployeeLastName
	From vCategories as C Inner Join vProducts as P
		On C.CategoryID = P.CategoryID
	Inner Join vInventories as I 
		On P.ProductID = I.ProductID
	Inner Join vEmployees as E
		On I.EmployeeID = E.EmployeeID
	Where P.ProductID in
		(Select ProductID
			From vProducts
			Where ProductName in ('Chai','Chang')
		)
	Order by InventoryDate,CategoryName,ProductName;
go

--Select * from vChaiChangInventoriesWithEmployee;
--go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

/* copying from Assignment05 with references to basic views */
--Select
--	 Manager = M.EmployeeFirstName + ' ' + M.EmployeeLastName
--	,Employee = E.EmployeeFirstName + ' ' + E.EmployeeLastName
--	From vEmployees as E Inner Join vEmployees as M
--		On E.ManagerID = M.EmployeeID
--	Order by Manager, Employee;
--go

/*create view, with Top for Order By to work -- FINAL ANSWER*/
go
Create View
	vEmployeesAndManagers
	As
	Select Top 1000
	 Manager = M.EmployeeFirstName + ' ' + M.EmployeeLastName
	,Employee = E.EmployeeFirstName + ' ' + E.EmployeeLastName
	From Employees as E Inner Join Employees as M
		On E.ManagerID = M.EmployeeID
	Order by Manager, Employee;
go

--Select * from vEmployeesAndManagers;
--go

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

/* building select statement - listing columns and joining columns, referencing Basic Views.*/

--Select
--	C.CategoryID, C.CategoryName, P.ProductID, P.ProductName, P.UnitPrice, I.InventoryID, 
--	I.InventoryDate,I.Count, E.EmployeeID, Employee = E.EmployeeFirstName + ' ' + E.EmployeeLastName, 
--	Manager = M.EmployeeFirstName + ' ' + M.EmployeeLastName
--	From vCategories as C 
--		Join vProducts as P 
--		On C.CategoryID = P.CategoryID
--		Join vInventories as I
--		On P.ProductID = I.ProductID
--		Join vEmployees as E
--		On I.EmployeeID = E.EmployeeID
--		Join vEmployees as M
--		On E.ManagerID = M.EmployeeID;
--go

/* Ordering results. */

--Select
--	C.CategoryID, C.CategoryName, P.ProductID, P.ProductName, P.UnitPrice, I.InventoryID, 
--	I.InventoryDate,I.Count, E.EmployeeID, Employee = E.EmployeeFirstName + ' ' + E.EmployeeLastName, 
--	Manager = M.EmployeeFirstName + ' ' + M.EmployeeLastName
--	From vCategories as C 
--		Join vProducts as P 
--		On C.CategoryID = P.CategoryID
--		Join vInventories as I
--		On P.ProductID = I.ProductID
--		Join vEmployees as E
--		On I.EmployeeID = E.EmployeeID
--		Join vEmployees as M
--		On E.ManagerID = M.EmployeeID
--	Order by C.CategoryID,P.ProductName,I.InventoryID,Employee;
--go

/*	Creating View	*/
go
Create View 
	vInventoriesByProductsByCategoriesByEmployees
	As
	Select Top 100000
		 C.CategoryID
		,C.CategoryName
		,P.ProductID
		,P.ProductName
		,P.UnitPrice
		,I.InventoryID
		,I.InventoryDate
		,I.Count
		,E.EmployeeID
		,Employee = E.EmployeeFirstName + ' ' + E.EmployeeLastName
		,Manager = M.EmployeeFirstName + ' ' + M.EmployeeLastName
	From vCategories as C 
		Join vProducts as P 
		On C.CategoryID = P.CategoryID
		Join vInventories as I
		On P.ProductID = I.ProductID
		Join vEmployees as E
		On I.EmployeeID = E.EmployeeID
		Join vEmployees as M
		On E.ManagerID = M.EmployeeID
	Order by C.CategoryID,P.ProductName,I.InventoryID,Employee;
go

--Select * from vInventoriesByProductsByCategoriesByEmployees;
--go


-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
--1	Beverages	1	Chai	18.00	1	2017-01-01	19	5	Steven Buchanan	Andrew Fuller
--1	Beverages	1	Chai	18.00	78	2017-02-01	1	7	Robert King	Steven Buchanan
--1	Beverages	1	Chai	18.00	155	2017-03-01	94	9	Anne Dodsworth	Steven Buchanan
--1	Beverages	2	Chang	19.00	2	2017-01-01	17	5	Steven Buchanan	Andrew Fuller
--1	Beverages	2	Chang	19.00	79	2017-02-01	79	7	Robert King	Steven Buchanan
--1	Beverages	2	Chang	19.00	156	2017-03-01	37	9	Anne Dodsworth	Steven Buchanan
--1	Beverages	24	Guaraná Fantástica	4.50	24	2017-01-01	0	5	Steven Buchanan	Andrew Fuller
--1	Beverages	24	Guaraná Fantástica	4.50	101	2017-02-01	79	7	Robert King	Steven Buchanan
--1	Beverages	24	Guaraná Fantástica	4.50	178	2017-03-01	28	9	Anne Dodsworth	Steven Buchanan
--1	Beverages	34	Sasquatch Ale	14.00	34	2017-01-01	5	5	Steven Buchanan	Andrew Fuller
--1	Beverages	34	Sasquatch Ale	14.00	111	2017-02-01	64	7	Robert King	Steven Buchanan
--1	Beverages	34	Sasquatch Ale	14.00	188	2017-03-01	86	9	Anne Dodsworth	Steven Buchanan
--1	Beverages	35	Steeleye Stout	18.00	35	2017-01-01	81	5	Steven Buchanan	Andrew Fuller
--1	Beverages	35	Steeleye Stout	18.00	112	2017-02-01	41	7	Robert King	Steven Buchanan
--1	Beverages	35	Steeleye Stout	18.00	189	2017-03-01	3	9	Anne Dodsworth	Steven Buchanan
--1	Beverages	38	Côte de Blaye	263.50	38	2017-01-01	49	5	Steven Buchanan	Andrew Fuller
--1	Beverages	38	Côte de Blaye	263.50	115	2017-02-01	62	7	Robert King	Steven Buchanan
--1	Beverages	38	Côte de Blaye	263.50	192	2017-03-01	92	9	Anne Dodsworth	Steven Buchanan
--1	Beverages	39	Chartreuse verte	18.00	39	2017-01-01	11	5	Steven Buchanan	Andrew Fuller


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vCategoriesAndProductsWithPrices]
Select * From [dbo].[vProductInventoriesByDate]
Select * From [dbo].[vInventoryDatesAndEmployees]
Select * From [dbo].[vProductInventoriesByCategoryAndDate]
Select * From [dbo].[vInventoriesWithEmployeeByDateCategoryProduct]
Select * From [dbo].[vChaiChangInventoriesWithEmployee]
Select * From [dbo].[vEmployeesAndManagers]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
/***************************************************************************************/