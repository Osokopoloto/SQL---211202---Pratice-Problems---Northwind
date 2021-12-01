-- 32. HIGH-VALUE CUSTOMERS
SELECT c.CustomerID
	   , c.CompanyName
	   , o.OrderID
	   , o.OrderDate
	   , od.UnitPrice * od.Quantity AS OrderValue
FROM Northwind.dbo.Customers c
JOIN Northwind.dbo.Orders o ON c.CustomerID = o.CustomerID
JOIN Northwind.dbo.[Order Details] od ON o.OrderID = od.OrderID
WHERE (od.UnitPrice * od.Quantity) >= 10000
	  AND YEAR(OrderDate) = 1998
ORDER BY OrderValue DESC

-- 33. HIGH-VALUE CUSTOMERS - TOTAL ORDERS
SELECT c.CustomerID
	   , c.CompanyName
	   , SUM(od.UnitPrice * od.Quantity) AS ToTalOrderValue
FROM Northwind.dbo.Customers c
JOIN Northwind.dbo.Orders o ON c.CustomerID = o.CustomerID
JOIN Northwind.dbo.[Order Details] od ON o.OrderID = od.OrderID
WHERE YEAR(OrderDate) = 1998
GROUP BY c.CustomerID, c.CompanyName
HAVING SUM(od.UnitPrice * od.Quantity) >= 15000
ORDER BY ToTalOrderValue DESC

-- 34. HIGH-VALUE CUSTOMERS - WITH DISCOUNT
SELECT c.CustomerID
	   , c.CompanyName
	   , SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS ToTalOrderValue
FROM Northwind.dbo.Customers c
JOIN Northwind.dbo.Orders o ON c.CustomerID = o.CustomerID
JOIN Northwind.dbo.[Order Details] od ON o.OrderID = od.OrderID
WHERE YEAR(OrderDate) = 1998
GROUP BY c.CustomerID, c.CompanyName
HAVING SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) >= 10000
ORDER BY ToTalOrderValue DESC

-- 35. MONTH-END ORDERS
SELECT OrderID
	   , EmployeeID
	   , OrderDate
	   , CASE WHEN OrderDate = EOMONTH(OrderDate) THEN 'x' END AS EndOfMonth
FROM Northwind.dbo.Orders
WHERE CASE WHEN OrderDate = EOMONTH(OrderDate) THEN 'x' END = 'x'
ORDER BY EmployeeID, OrderID

-- 36. ORDERS WITH MANY LINE ITEMS
SELECT TOP 10 OrderID
	   , COUNT(*) AS TotalOrderDetails
FROM Northwind.dbo.[Order Details]
GROUP BY OrderID
ORDER BY TotalOrderDetails  DESC, OrderID DESC

-- 37. ORDERS - RANDOM ASSORTMENT
SELECT TOP 2 PERCENT OrderID
	   , NEWID() AS RandomValue
FROM Northwind.dbo.Orders
ORDER BY NEWID()

-- 38. ORDERS - ACCIDENTAL DOUBLE-ENTRY
SELECT OrderID
FROM Northwind.dbo.[Order Details]
WHERE Quantity >= 60
GROUP BY OrderID, Quantity
HAVING COUNT(OrderID) > 1
ORDER BY OrderID

-- 39. ORDERS - ACCIDENTAL DOUBLE-ENTRY DETAILS
WITH sub AS(
	SELECT OrderID
	FROM Northwind.dbo.[Order Details]
	WHERE Quantity >= 60
	GROUP BY OrderID, Quantity
	HAVING COUNT(OrderID) > 1
	)

SELECT sub.OrderID
	   , od.ProductID
	   , od.Quantity
FROM sub
JOIN Northwind.dbo.[Order Details] od ON sub.OrderID = od.OrderID
ORDER BY od.Quantity DESC

-- 41. LATE ORDERS
SELECT OrderID
	   , CONVERT(date,OrderDate) AS OrderDate
	   , CONVERT(date,RequiredDate) AS RequiredDate
	   , CONVERT(date,ShippedDate) AS ShippedDate
FROM Northwind.dbo.Orders
WHERE RequiredDate <= ShippedDate

-- 42. LATE ORDERS - WHICH EMPLOYEES
WITH LateOrders AS(
	SELECT OrderID
		   , CONVERT(date,OrderDate) AS OrderDate
		   , CONVERT(date,RequiredDate) AS RequiredDate
		   , CONVERT(date,ShippedDate) AS ShippedDate
		   , EmployeeID
	FROM Northwind.dbo.Orders
	WHERE RequiredDate <= ShippedDate
	)
SELECT lo.EmployeeID
	   , e.LastName
	   , COUNT(*) AS LateOrderNo
FROM LateOrders lo
JOIN Northwind.dbo.Employees e ON lo.EmployeeID = e.EmployeeID
GROUP BY lo.EmployeeID, e.LastName
ORDER BY COUNT(*) DESC

-- 43 + 44 + 45. LATE ORDERS VS TOTAL ORDERS
WITH LateOrders AS(
	SELECT OrderID
		   , CONVERT(date,OrderDate) AS OrderDate
		   , CONVERT(date,RequiredDate) AS RequiredDate
		   , CONVERT(date,ShippedDate) AS ShippedDate
		   , EmployeeID
	FROM Northwind.dbo.Orders
	WHERE RequiredDate <= ShippedDate
	),
LateOrdersByEmployee AS(
	SELECT lo.EmployeeID
		   , e.LastName
		   , COUNT(*) AS LateOrderNo
	FROM LateOrders lo
	JOIN Northwind.dbo.Employees e ON lo.EmployeeID = e.EmployeeID
	GROUP BY lo.EmployeeID, e.LastName
	),
OrderNoByEmployee AS(
	SELECT EmployeeID
		   , COUNT(*) AS TotalOrderNo
	FROM Northwind.dbo.Orders
	GROUP BY EmployeeID
	)

SELECT loe.EmployeeID
	   , loe.LastName
	   , oe.TotalOrderNo
	   , loe.LateOrderNo
FROM LateOrdersByEmployee loe
JOIN OrderNoByEmployee oe ON loe.EmployeeID = oe.EmployeeID 

-- 46. LATE ORDERS VS TOTAL ORDERS - PERCENTAGE
WITH LateOrders AS(
	SELECT OrderID
		   , CONVERT(date,OrderDate) AS OrderDate
		   , CONVERT(date,RequiredDate) AS RequiredDate
		   , CONVERT(date,ShippedDate) AS ShippedDate
		   , EmployeeID
	FROM Northwind.dbo.Orders
	WHERE RequiredDate <= ShippedDate
	),
LateOrdersByEmployee AS(
	SELECT lo.EmployeeID
		   , e.LastName
		   , COUNT(*) AS LateOrderNo
	FROM LateOrders lo
	JOIN Northwind.dbo.Employees e ON lo.EmployeeID = e.EmployeeID
	GROUP BY lo.EmployeeID, e.LastName
	),
OrderNoByEmployee AS(
	SELECT EmployeeID
		   , COUNT(*) AS TotalOrderNo
	FROM Northwind.dbo.Orders
	GROUP BY EmployeeID
	)

SELECT loe.EmployeeID
	   , loe.LastName
	   , oe.TotalOrderNo
	   , loe.LateOrderNo
	   , CONVERT(float,loe.LateOrderNo)/CONVERT(float,oe.TotalOrderNo) AS "%Late"
FROM LateOrdersByEmployee loe
JOIN OrderNoByEmployee oe ON loe.EmployeeID = oe.EmployeeID 

-- 48 + 49. CUSTOMER GROUPING
SELECT c.CustomerID
	   , c.CompanyName
	   , SUM(od.UnitPrice * od.Quantity) AS ToTalOrderValue
	   , CASE WHEN SUM(od.UnitPrice * od.Quantity) >= 10000 THEN 'Very High'
			  WHEN SUM(od.UnitPrice * od.Quantity) >= 5000 THEN 'High'
			  WHEN SUM(od.UnitPrice * od.Quantity) >= 1000 THEN 'Medium'
			  WHEN SUM(od.UnitPrice * od.Quantity) < 1000 THEN 'Low'
			  ELSE 'Error' END
			  AS Category
FROM Northwind.dbo.Customers c
JOIN Northwind.dbo.Orders o ON c.CustomerID = o.CustomerID
JOIN Northwind.dbo.[Order Details] od ON o.OrderID = od.OrderID
WHERE YEAR(OrderDate) = 1998
GROUP BY c.CustomerID, c.CompanyName
ORDER BY c.CustomerID

-- 50. CUSTOMER GROUPING WITH PERCENTAGE
WITH CusGroup AS(
	SELECT c.CustomerID
		   , c.CompanyName
		   , SUM(od.UnitPrice * od.Quantity) AS ToTalOrderValue
		   , CASE WHEN SUM(od.UnitPrice * od.Quantity) >= 10000 THEN 'Very High'
				  WHEN SUM(od.UnitPrice * od.Quantity) >= 5000 THEN 'High'
				  WHEN SUM(od.UnitPrice * od.Quantity) >= 1000 THEN 'Medium'
				  WHEN SUM(od.UnitPrice * od.Quantity) < 1000 THEN 'Low'
				  ELSE 'Error' END
				  AS Category
	FROM Northwind.dbo.Customers c
	JOIN Northwind.dbo.Orders o ON c.CustomerID = o.CustomerID
	JOIN Northwind.dbo.[Order Details] od ON o.OrderID = od.OrderID
	WHERE YEAR(OrderDate) = 1998
	GROUP BY c.CustomerID, c.CompanyName
	),
CusGroup2 as(
SELECT Category 
	   , COUNT(*) As NumberInGroup
FROM CusGroup
GROUP BY Category
)

SELECT *
	   , CONVERT(float,NumberInGroup)/SUM(CONVERT(float,NumberInGroup)) OVER () AS PrcntTotal
FROM Cusgroup2
ORDER BY NumberInGroup DESC

-- 51. CUSTOMER GROUPING - FLEXIBLE
----- Unable to do because there is a missing table

-- 52. COUNTRIES WITH SUPPLIERS OR CUSTOMERS
SELECT DISTINCT Country
FROM Northwind.dbo.Customers
UNION
SELECT DISTINCT Country
FROM Northwind.dbo.Suppliers

-- 53. COUNTRIES WITH SUPPLIERS OR CUSTOMERS, VERSION 2
WITH Country_Customers AS(
	SELECT DISTINCT Country
	FROM Northwind.dbo.Customers
	),
Country_Suppliers AS(
	SELECT DISTINCT Country
	FROM Northwind.dbo.Suppliers
	)
SELECT *
FROM Country_Customers c
FULL JOIN Country_Suppliers s ON c.Country = s.Country

-- 54. COUNTRIES WITH SUPPLIERS OR CUSTOMERS, VERSION 3
WITH Country_Customers AS(
	SELECT Country
		   , COUNT(*) NumOfCustomers
	FROM Northwind.dbo.Customers
	GROUP BY Country
	),
Country_Suppliers AS(
	SELECT Country
		   , COUNT(*) NumOfSuppliers
	FROM Northwind.dbo.Suppliers
	GROUP BY Country
	),
UniqueCountry AS(
	SELECT DISTINCT Country
	FROM Northwind.dbo.Customers
	UNION
	SELECT DISTINCT Country
	FROM Northwind.dbo.Suppliers
	)
SELECT uc.Country
	   , c_sup.NumOfSuppliers
	   , c_cus.NumOfCustomers  
FROM UniqueCountry uc
LEFT JOIN Country_Customers c_cus ON uc.Country = c_cus.Country
LEFT JOIN Country_Suppliers c_sup ON uc.Country = c_sup.Country

-- 55. FIRST ORDER IN EACH COUNTRY
WITH OrdersByCountry AS(
	SELECT ShipCountry
		   , CustomerID
		   , OrderID
		   , CONVERT(date,OrderDate) AS OrderDate
		   , ROW_NUMBER() OVER (PARTITION BY ShipCountry ORDER BY ShipCountry, OrderID) AS OrderNoByCountry
	FROM Northwind.dbo.Orders
	)
SELECT ShipCountry
	   , CustomerID
	   , OrderID
	   , OrderDate
FROM OrdersByCountry
WHERE OrderNoByCountry = 1

-- 56 + 57. CUSTOMERS WITH MULTIPLE ORDERS IN 5 DAY PERIOD
WITH  OrderDateDiff AS(
	SELECT CustomerID
		   , OrderID AS InitialOrderID
		   , CONVERT(date,OrderDate) AS InitialOrderDate
		   , LEAD(OrderID) OVER (PARTITION BY CustomerID ORDER BY OrderID) AS NextOrderID
		   , LEAD(CONVERT(date,OrderDate)) OVER (PARTITION BY CustomerID ORDER BY OrderID) AS NextOrderDate
	FROM Northwind.dbo.Orders
	)
SELECT *
	   , DATEDIFF(day,InitialOrderDate,NextOrderDate) AS DateInBetweenOrders
FROM OrderDateDiff
WHERE DATEDIFF(day,InitialOrderDate,NextOrderDate) <= 5