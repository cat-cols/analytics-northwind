-- Step 2: Write 20 SQL Queries (2 days)

Here are the **exact 20 queries** you should write:


-- CATEGORY 2: Sales Trends (5 queries)

-- Query 6: Monthly Sales Trend
-- Business Question: What are our monthly sales trends?

SELECT
    strftime('%Y-%m', OrderDate) as Month,
    COUNT(DISTINCT OrderID) as OrderCount,
    SUM(od.Quantity * od.UnitPrice) as MonthlyRevenue,
    AVG(od.Quantity * od.UnitPrice) as AvgOrderValue
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY Month
ORDER BY Month;

-- Query 7: Year-Over-Year Growth
-- Business Question: How is our revenue growing year-over-year?

WITH YearlyRevenue AS (
    SELECT
        strftime('%Y', OrderDate) as Year,
        SUM(od.Quantity * od.UnitPrice) as Revenue
    FROM Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    GROUP BY Year
)
SELECT
    Year,
    Revenue,
    LAG(Revenue) OVER (ORDER BY Year) as PreviousYearRevenue,
    ROUND(100.0 * (Revenue - LAG(Revenue) OVER (ORDER BY Year)) /
          LAG(Revenue) OVER (ORDER BY Year), 2) as YoYGrowthPercent
FROM YearlyRevenue
ORDER BY Year;


-- Query 8: Seasonal Patterns
-- Business Question: Do we see seasonal patterns in sales?

SELECT
    CASE cast(strftime('%m', OrderDate) as integer)
        WHEN 1 THEN 'Q1' WHEN 2 THEN 'Q1' WHEN 3 THEN 'Q1'
        WHEN 4 THEN 'Q2' WHEN 5 THEN 'Q2' WHEN 6 THEN 'Q2'
        WHEN 7 THEN 'Q3' WHEN 8 THEN 'Q3' WHEN 9 THEN 'Q3'
        ELSE 'Q4'
    END AS Quarter,
    COUNT(DISTINCT o.OrderID) as Orders,
    SUM(od.Quantity * od.UnitPrice) as Revenue
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY Quarter
ORDER BY
    CASE Quarter
        WHEN 'Q1' THEN 1
        WHEN 'Q2' THEN 2
        WHEN 'Q3' THEN 3
        WHEN 'Q4' THEN 4
    END;


-- Query 9: Sales by Day of Week
-- Business Question: Which days of the week generate most sales?

SELECT
    CASE cast(strftime('%w', OrderDate) as integer)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END as DayOfWeek,
    COUNT(DISTINCT OrderID) as OrderCount,
    SUM(od.Quantity * od.UnitPrice) as Revenue
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY DayOfWeek
ORDER BY Revenue DESC;


-- Query 10: Sales Velocity
-- Business Question: What's the average time between orders?

WITH OrderDates AS (
    SELECT
        CustomerID,
        OrderDate,
        LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) as PreviousOrderDate
    FROM Orders
)
SELECT
    AVG(julianday(OrderDate) - julianday(PreviousOrderDate)) as AvgDaysBetweenOrders,
    MIN(julianday(OrderDate) - julianday(PreviousOrderDate)) as MinDaysBetweenOrders,
    MAX(julianday(OrderDate) - julianday(PreviousOrderDate)) as MaxDaysBetweenOrders
FROM OrderDates
WHERE PreviousOrderDate IS NOT NULL;

-- CATEGORY 3: Product Analysis (5 queries)

-- Query 11: Top Products by Revenue
-- Business Question: Which products generate the most revenue?

SELECT
    p.ProductName,
    p.CategoryID,
    SUM(od.Quantity) as UnitsSold,
    SUM(od.Quantity * od.UnitPrice) as TotalRevenue,
    AVG(od.UnitPrice) as AvgPrice
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY p.ProductID, p.ProductName, p.CategoryID
ORDER BY TotalRevenue DESC
LIMIT 15;

-- Query 12: Product Performance by Category
-- Business Question: Which product categories perform best?

SELECT
    c.CategoryName,
    COUNT(DISTINCT p.ProductID) as ProductCount,
    SUM(od.Quantity) as TotalUnitsSold,
    SUM(od.Quantity * od.UnitPrice) as CategoryRevenue,
    AVG(od.UnitPrice) as AvgPrice
FROM Categories c
JOIN Products p ON c.CategoryID = p.CategoryID
JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY c.CategoryID, c.CategoryName
ORDER BY CategoryRevenue DESC;

-- Query 13: Slow-Moving Inventory
-- Business Question: Which products are selling slowly?

SELECT
    p.ProductName,
    p.UnitsInStock,
    COALESCE(SUM(od.Quantity), 0) as TotalSold,
    p.UnitsInStock - COALESCE(SUM(od.Quantity), 0) as StockRemaining,
    CASE
        WHEN SUM(od.Quantity) IS NULL THEN 'Never Sold'
        WHEN SUM(od.Quantity) < 10 THEN 'Slow Moving'
        ELSE 'Normal'
    END as InventoryStatus
FROM Products p
LEFT JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY p.ProductID, p.ProductName, p.UnitsInStock
HAVING InventoryStatus IN ('Never Sold', 'Slow Moving')
ORDER BY TotalSold ASC;

-- Query 14: Product Pricing Analysis
-- Business Question: How do prices compare within categories?

WITH ProductStats AS (
    SELECT
        c.CategoryName,
        p.ProductName,
        p.UnitPrice,
        AVG(p.UnitPrice) OVER (PARTITION BY c.CategoryID) as AvgCategoryPrice
    FROM Products p
    JOIN Categories c ON p.CategoryID = c.CategoryID
)
SELECT
    CategoryName,
    ProductName,
    UnitPrice,
    AvgCategoryPrice,
    ROUND(100.0 * (UnitPrice - AvgCategoryPrice) / AvgCategoryPrice, 2) as PriceVsAvgPercent,
    CASE
        WHEN UnitPrice > AvgCategoryPrice * 1.2 THEN 'Premium'
        WHEN UnitPrice < AvgCategoryPrice * 0.8 THEN 'Budget'
        ELSE 'Standard'
    END as PriceTier
FROM ProductStats
ORDER BY CategoryName, UnitPrice DESC;


-- Query 15: Product Bundling Opportunities
-- Business Question: Which products are frequently bought together?

SELECT
    p1.ProductName as Product1,
    p2.ProductName as Product2,
    COUNT(*) as TimesBoughtTogether
FROM OrderDetails od1
JOIN OrderDetails od2 ON od1.OrderID = od2.OrderID AND od1.ProductID < od2.ProductID
JOIN Products p1 ON od1.ProductID = p1.ProductID
JOIN Products p2 ON od2.ProductID = p2.ProductID
GROUP BY p1.ProductName, p2.ProductName
HAVING COUNT(*) > 5
ORDER BY TimesBoughtTogether DESC
LIMIT 20;

-- CATEGORY 4: Employee Performance (3 queries)

-- Query 16: Sales by Employee
-- Business Question: Which employees generate the most sales?

SELECT
    e.EmployeeID,
    e.FirstName || ' ' || e.LastName as EmployeeName,
    e.Title,
    COUNT(DISTINCT o.OrderID) as OrdersProcessed,
    SUM(od.Quantity * od.UnitPrice) as TotalSales,
    ROUND(SUM(od.Quantity * od.UnitPrice) / COUNT(DISTINCT o.OrderID), 2) as AvgOrderValue
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY e.EmployeeID, EmployeeName, e.Title
ORDER BY TotalSales DESC;

-- Query 17: Employee Efficiency
-- Business Question: How efficient are our employees?

WITH EmployeeMetrics AS (
    SELECT
        e.EmployeeID,
        e.FirstName || ' ' || e.LastName as EmployeeName,
        COUNT(DISTINCT o.OrderID) as TotalOrders,
        SUM(od.Quantity * od.UnitPrice) as TotalRevenue,
        MIN(o.OrderDate) as FirstOrder,
        MAX(o.OrderDate) as LastOrder
    FROM Employees e
    JOIN Orders o ON e.EmployeeID = o.EmployeeID
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    GROUP BY e.EmployeeID, EmployeeName
)
SELECT
    EmployeeName,
    TotalOrders,
    TotalRevenue,
    ROUND(TotalRevenue / TotalOrders, 2) as RevenuePerOrder,
    julianday(LastOrder) - julianday(FirstOrder) as DaysActive,
    ROUND(TotalOrders / ((julianday(LastOrder) - julianday(FirstOrder)) / 30.0), 2) as OrdersPerMonth
FROM EmployeeMetrics
ORDER BY TotalRevenue DESC;

-- Query 18: Employee Territory Analysis
-- Business Question: How do employees perform by region?

SELECT
    e.FirstName || ' ' || e.LastName as EmployeeName,
    c.Country,
    COUNT(DISTINCT o.OrderID) as Orders,
    SUM(od.Quantity * od.UnitPrice) as Revenue
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY e.EmployeeID, EmployeeName, c.Country
HAVING COUNT(DISTINCT o.OrderID) >= 3
ORDER BY EmployeeName, Revenue DESC;

-- CATEGORY 5: Operational Metrics (2 queries)

-- Query 19: Shipping Performance
-- Business Question: How long does it take to ship orders?

SELECT
    ShipCountry,
    COUNT(OrderID) as TotalOrders,
    AVG(julianday(ShippedDate) - julianday(OrderDate)) as AvgDaysToShip,
    MIN(julianday(ShippedDate) - julianday(OrderDate)) as FastestShipment,
    MAX(julianday(ShippedDate) - julianday(OrderDate)) as SlowestShipment
FROM Orders
WHERE ShippedDate IS NOT NULL
GROUP BY ShipCountry
HAVING COUNT(OrderID) >= 5
ORDER BY AvgDaysToShip DESC;

-- Query 20: Revenue Concentration
-- Business Question: How concentrated is our revenue? (Pareto Analysis)

WITH CustomerRevenue AS (
    SELECT
        c.CustomerID,
        c.CompanyName,
        SUM(od.Quantity * od.UnitPrice) as Revenue
    FROM Customers c
    JOIN Orders o ON c.CustomerID = o.CustomerID
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    GROUP BY c.CustomerID, c.CompanyName
),
RankedCustomers AS (
    SELECT
        CustomerID,
        CompanyName,
        Revenue,
        SUM(Revenue) OVER (ORDER BY Revenue DESC) as CumulativeRevenue,
        SUM(Revenue) OVER () as TotalRevenue,
        ROW_NUMBER() OVER (ORDER BY Revenue DESC) as CustomerRank,
        COUNT(*) OVER () as TotalCustomers
    FROM CustomerRevenue
)
SELECT
    CustomerRank,
    CompanyName,
    Revenue,
    ROUND(100.0 * Revenue / TotalRevenue, 2) as PercentOfTotal,
    ROUND(100.0 * CumulativeRevenue / TotalRevenue, 2) as CumulativePercent,
    CASE
        WHEN ROUND(100.0 * CumulativeRevenue / TotalRevenue, 2) <= 80 THEN 'Top 80%'
        ELSE 'Bottom 20%'
    END as RevenueGroup
FROM RankedCustomers
ORDER BY CustomerRank
LIMIT 30;