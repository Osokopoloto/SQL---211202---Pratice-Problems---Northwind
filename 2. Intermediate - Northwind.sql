-- 20. CATEGORIES, AND THE TOTAL PRODUCTS IN EACH CATEGORY
SELECT c.CategoryID
	   , c.CategoryName
	   , COUNT(p.ProductID) AS "Number of products"
FROM Northwind.dbo.Categories c
LEFT JOIN Northwind.dbo.Products p ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryID, c.CategoryName
ORDER BY COUNT(p.ProductID) DESC

-- 21. TOTAL CUSTOMERS PER COUNTRY/CITY
SELECT Country
	   , City
	   , COUNT(*) AS "Number of customers"
FROM Northwind.dbo.Customers
GROUP BY Country, City
ORDER BY COUNT(*) DESC

-- 22. PRODUCTS THAT NEED REORDERING
SELECT ProductID
	   , ProductName
	   , UnitsInStock
	   , ReorderLevel
FROM Northwind.dbo.Products
WHERE UnitsInStock < ReorderLevel
ORDER BY ProductID

-- 23. PRODUCTS THAT NEED REORDERING, CONTINUED
SELECT ProductID
	   , ProductName
	   , UnitsInStock
	   , UnitsOnOrder
	   , ReorderLevel
	   , Discontinued
FROM Northwind.dbo.Products
WHERE (UnitsInStock + UnitsOnOrder) <= ReorderLevel
	  AND Discontinued = 0
ORDER BY ProductID

-- 24. CUSTOMER LIST BY REGION
SELECT CustomerID
	   , CompanyName
	   , Region
	   , CASE WHEN Region IS NULL THEN 'x' END AS "IsNull"
FROM Northwind.dbo.Customers
ORDER BY IsNull, Region, CustomerID

-- 25. HIGH FREIGHT CHARGES
SELECT TOP 3 ShipCountry
	   , AVG(Freight) AS AvgFreight
FROM Northwind.dbo.Orders
GROUP BY ShipCountry
ORDER BY AVG(Freight) DESC

-- 26. HIGH FREIGHT CHARGES - 1997
SELECT TOP 3 ShipCountry
	   , YEAR(OrderDate) AS OrderYear
	   , AVG(Freight) AS AvgFreight
FROM Northwind.dbo.Orders
WHERE YEAR(OrderDate) = 1997
GROUP BY ShipCountry, YEAR(OrderDate)
ORDER BY AVG(Freight) DESC

-- 27. HIGH FREIGHT CHARGES WITH BETWEEN
SELECT TOP 3 ShipCountry
	   , AVG(Freight) AS AvgFreight
FROM Northwind.dbo.Orders
WHERE OrderDate BETWEEN '1997-01-01 00:00:00.000' AND '1997-12-31 00:00:00.000'
GROUP BY ShipCountry 
ORDER BY AVG(Freight) DESC

-- 28. HIGH FREIGHT CHARGES LAST YEAR
SELECT TOP 3 ShipCountry
	   , AVG(Freight) AS AvgFreight
FROM Northwind.dbo.Orders
WHERE OrderDate >= DATEADD(year,-1,(SELECT MAX(OrderDate) FROM Northwind.dbo.Orders))
GROUP BY ShipCountry 
ORDER BY AVG(Freight) DESC

-- 29. INVENTORY LIST
SELECT e.EmployeeID
	   , e.LastName
	   , o.OrderID
	   , p.ProductName
	   , od.Quantity
FROM Northwind.dbo.Employees e
JOIN Northwind.dbo.Orders o ON e.EmployeeID = o.EmployeeID
JOIN Northwind.dbo.[Order Details] od ON o.OrderID = od.OrderID
JOIN Northwind.dbo.Products p ON od.ProductID = p.ProductID
ORDER BY o.OrderID, p.ProductID

-- 30. CUSTOMERS WITH NO ORDERS
SELECT c.CustomerID
	   , c.CompanyName
FROM Northwind.dbo.Customers c
LEFT JOIN Northwind.dbo.Orders o ON c.CustomerID = o.CustomerID 
WHERE o.OrderID IS NULL

-- 31. CUSTOMERS WITH NO ORDERS FOR EMPLOYEEID 4
SELECT c.CustomerID
	   , o.OrderID
FROM Northwind.dbo.Customers c
LEFT JOIN Northwind.dbo.Orders o ON c.CustomerID = o.CustomerID 
		  AND o.EmployeeID = 4
WHERE o.OrderID IS NULL
