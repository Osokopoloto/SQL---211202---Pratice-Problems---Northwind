-- 1. WHICH SHIPPERS DO WE HAVE?
SELECT *
FROM Northwind.dbo.Shippers

-- 2. CERTAIN FIELDS FROM CATEGORIES
SELECT CategoryName
	   , Description
FROM Northwind.dbo.Categories

-- 3. SALES REPRESENTATIVES
SELECT FirstName
	   , LastName
	   , HireDate
FROM Northwind.dbo.Employees
WHERE Title LIKE 'Sales Representative'

-- 4. SALES REPRESENTATIVES IN THE UNITED STATES
SELECT FirstName
	   , LastName
	   , HireDate
FROM Northwind.dbo.Employees
WHERE Title LIKE 'Sales Representative' 
	AND Country LIKE 'USA'

-- 5. ORDERS PLACED BY SPECIFIC EMPLOYEEID
SELECT *
FROM Northwind.dbo.Orders
WHERE EmployeeID = 5

-- 6. SUPPLIERS AND CONTACTTITLES
SELECT SupplierID
	   , ContactName
	   , ContactTitle
FROM Northwind.dbo.Suppliers
WHERE ContactTitle != 'Marketing Manager'

-- 7. PRODUCT WITH "QUESO" IN PRODUCTNAME
SELECT ProductID
	   , ProductName
FROM Northwind.dbo.Products
WHERE ProductName LIKE '%queso%'

-- 8. ORDERS SHIPPING TO FRANCE OR BELGIUM
SELECT OrderID
	   , CustomerID
	   , ShipCountry
FROM Northwind.dbo.Orders
WHERE ShipCountry = 'France' OR ShipCountry = 'Belgium'

-- 9. ORDERS SHIPPING TO ANY COUNTRY IN LATIN AMERICA
SELECT OrderID
	   , CustomerID
	   , ShipCountry
FROM Northwind.dbo.Orders
WHERE ShipCountry IN ('Brazil','Mexico','Argentina','Venezuela')

-- 10. EMPLOYEES, IN ORDER OF AGE
SELECT FirstName
	   , LastName
	   , Title
	   , BirthDate
FROM Northwind.dbo.Employees
ORDER BY BirthDate

-- 11. SHOWING ONLY THE DATE WITH A DATETIME FIELD
SELECT FirstName
	   , LastName
	   , Title
	   , CONVERT(Date,BirthDate)
FROM Northwind.dbo.Employees
ORDER BY BirthDate

-- 12. EMPLOYEES FULL NAME
SELECT FirstName
	   , LastName
	   , CONCAT(FirstName,' ',LastName) AS FullName
FROM Northwind.dbo.Employees

-- 13. ORDERDETAILS AMOUNT PER ITEM
SELECT OrderID
	   , ProductID
	   , UnitPrice
	   , Quantity
	   , UnitPrice * Quantity AS TotalPrice
FROM Northwind.dbo.[Order Details]
ORDER BY OrderID, ProductID

-- 14. HOW MANY CUSTOMERS?
SELECT COUNT(*)
FROM Northwind.dbo.Customers

-- 15. WHERE WAS THE FIRST ORDER?
SELECT TOP 1 OrderDate
FROM Northwind.dbo.Orders
ORDER BY OrderDate

-- 16. COUNTRIES WHERE THERE ARE CUSTOMERS
SELECT DISTINCT(Country)
FROM Northwind.dbo.Customers

-- 17. CONTACT TITLES FOR CUSTOMERS
SELECT ContactTitle
	   , COUNT(ContactTitle) AS CountContactTitle
FROM Northwind.dbo.Customers
GROUP BY ContactTitle
ORDER BY COUNT(ContactTitle) DESC


-- 18. PRODUCTS WITH ASSOCIATED SUPPLIER NAMES
SELECT p.ProductID
	   , p. ProductName
	   , s. CompanyName
FROM Northwind.dbo.Products p
LEFT JOIN Northwind.dbo.Suppliers s ON p.SupplierID = s.SupplierID

-- 19. ORDERS AND THE SHIPPER THAT WAS USED
SELECT o.OrderID
	   , CONVERT(date,o.OrderDate)
	   , sh.CompanyName
FROM Northwind.dbo.Orders o
LEFT JOIN Northwind.dbo.Shippers sh ON o.ShipVia = sh.ShipperID
WHERE o.OrderID < 10300
ORDER BY o.OrderID
