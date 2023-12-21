USE SupplyChain;

SELECT * FROM FactSales;
SELECT * FROM DimProducts;
SELECT * FROM DimInventory;
SELECT * FROM DimShipping;
SELECT * FROM DimSuppliers;


SELECT COUNT(Distinct Product_type) AS NumOfProducts FROM DimProducts;
SELECT COUNT(Distinct Shipping_carriers) AS NumOfShipping FROM DimShipping;
SELECT COUNT(Distinct Shipping_carriers) AS NumOfShippingCarriers FROM DimShipping;
SELECT COUNT(Distinct Supplier_name) AS NumOfSupplier FROM DimSuppliers;
SELECT COUNT(Distinct Location) AS NumOfLocations FROM DimSuppliers;


SELECT Distinct Product_type FROM DimProducts;
SELECT Distinct Shipping_carriers FROM DimShipping;
SELECT Distinct Shipping_carriers FROM DimShipping;
SELECT Distinct Supplier_name FROM DimSuppliers;
SELECT Distinct Location FROM DimSuppliers;
SELECT Distinct Customer_demographics FROM FactSales;


SELECT MAX(Number_of_products_sold) FROM FactSales;
SELECT MIN(Number_of_products_sold) FROM FactSales;
SELECT AVG(Revenue_generated) AS Revenue_Average FROM FactSales;
SELECT AVG(Price) AS Prices_Average FROM DimProducts;


								/* Sales Analysis: */

/*How many products does the company sell? */
SELECT 
	COUNT(*) AS NumberOfProducts 
FROM 
	DimProducts

/* How many orders has the company received? */


/* What are the top-selling products by revenue? */
SELECT p.Product_type AS Product, ROUND(SUM(s.Revenue_generated), 2) AS Revenue
FROM DimProducts p
JOIN FactSales s
ON p.SKU = s.SKU
GROUP BY p.Product_type
ORDER BY p.Product_type DESC;


/*Which product categories contribute the most to overall revenue?*/
WITH CategoryRevenue AS (
	SELECT 
		p.Product_type, 
		SUM(s.Revenue_generated) AS TotalRevenue
	FROM FactSales s
	JOIN DimProducts p
	ON p.SKU = s.SKU
	GROUP BY p.Product_type
)

SELECT Product_type, TotalRevenue
FROM (
		SELECT 
			ROW_NUMBER() OVER(ORDER BY TotalRevenue DESC) RowNum, 
			Product_type, 
			TotalRevenue
			FROM CategoryRevenue
	) AS RankedCategories
WHERE RowNum = 1;



/*What is the distribution of product preferences among different customer demographics, and are there any notable trends or patterns?*/
WITH DemographicPreferences AS (
	SELECT 
		s.Customer_demographics, 
		p.Product_type, 
		COUNT(*) AS PreferenceCount
	FROM FactSales s
	JOIN DimProducts p
	ON p.SKU = s.SKU
	GROUP BY s.Customer_demographics, p.Product_type
)

SELECT
	RANK() OVER(PARTITION BY Customer_demographics ORDER BY PreferenceCount DESC) AS RankInDemographic,
	Customer_demographics, 
	Product_type, 
	PreferenceCount
FROM DemographicPreferences
ORDER BY Customer_demographics, RankInDemographic;

--------------------------------------------------------------------------------------
SELECT s.Customer_demographics, p.Product_type, COUNT(*) AS count_customers
FROM FactSales s
	JOIN DimProducts p
	ON p.SKU = s.SKU
GROUP BY s.Customer_demographics, p.Product_type
ORDER BY s.Customer_demographics, count_customers DESC;






											/*Inventory and Production*/

/* Which products have the highest and lowest stock levels?*/
WITH ProductStockLevels AS (
	SELECT 
		i.SKU, 
		p.Product_type,	
		i.Stock_levels
	FROM DimInventory i
	join DimProducts p
	ON i.SKU = p.SKU
)

SELECT SKU, Product_type, Stock_levels
FROM 
	(
		SELECT
			ROW_NUMBER() OVER(ORDER BY Stock_levels DESC) AS HighStockRank,
			ROW_NUMBER() OVER(ORDER BY Stock_levels ASC) AS LowStockRank,
			SKU, 
			Product_type, 
			Stock_levels
		FROM ProductStockLevels
	) AS RankedStock
WHERE HighStockRank = 1 OR LowStockRank = 1;



/*How do lead times impact inventory levels?*/
WITH LeadTimeImpact AS (
	SELECT 
		i.SKU, 
		p.Product_type, 
		i.Lead_times, 
		i.Stock_levels
	FROM DimInventory i
	JOIN DimProducts p
	ON i.SKU = p.SKU
)

SELECT Lead_times, AVG(Stock_levels) AS AverageStockLevel
FROM LeadTimeImpact
GROUP BY Lead_times
ORDER BY Lead_times;



/*What is the defect rate for each product type, and how does it impact production volumes?*/
WITH ProductDefectImpact AS (
	SELECT 
		p.Product_type, 
		i.Production_volumes, 
		i.Defect_rates
	FROM DimInventory i
	join DimProducts p
	ON i.SKU = p.SKU
)

SELECT 
	Product_type, 
	AVG(Production_volumes) AS AverageProductionVolumes,
	AVG(Defect_rates) AS AverageDefectRate
FROM ProductDefectImpact
GROUP BY Product_type
ORDER BY Product_type;


					/*Shipping and Transportation*/

/* What are the average shipping times for different shipping carriers? */
WITH ShippingAverageTimes AS (
	SELECT
		sh.Shipping_carriers,
		AVG(sh.Shipping_times) AS AverageShippingTime
	FROM DimShipping sh
	GROUP BY sh.Shipping_carriers
)
SELECT 
	Shipping_carriers,
	AverageShippingTime
FROM 
	ShippingAverageTimes
ORDER BY 
	AverageShippingTime;



/*Which transportation modes are the most cost-effective for different routes?*/
WITH RouteCosts  AS (
	SELECT 
		sh.Transportation_modes, 
		sh.Routes, 
		AVG(sh.Costs) AS AverageCost
	FROM 
		DimShipping sh
	GROUP BY
		sh.Routes, sh.Transportation_modes
)

SELECT
	RANK() OVER(PARTITION BY Routes ORDER BY AverageCost) AS RankInRoute,
	Transportation_modes, 
	Routes, 
	AverageCost
FROM 
	RouteCosts
ORDER BY 
	Routes, RankInRoute;




/*Can we optimize routes based on cost and shipping times? */

/* Yes, we can optimize the routes, as our priority is speedy delivery and cost effective 
we can assign equal weights (these weights can be adjusted based on 
requirements (ex:- cost effective,speedy delivery or both). */
WITH RouteOptimization  AS (
	SELECT 
		sh.Routes,
		AVG(sh.Costs) AS AverageCost,
		AVG(sh.Shipping_times) AS AverageShippingTime
	FROM DimShipping sh
	GROUP BY sh.Routes
)

SELECT
	RANK() OVER(ORDER BY AverageCost + AverageShippingTime) AS CombinedRank,
	Routes,
	AverageCost,
	AverageShippingTime
FROM 
	RouteOptimization
ORDER BY
	CombinedRank;


								/*Supplier Performance */

/* Which suppliers have the shortest and longest lead times? */
WITH SupplierLeadTime  AS (
	SELECT 
		ds.Supplier_name,
		AVG(ds.Lead_time) AS AverageLeadTime
	FROM 
		DimSuppliers ds
	GROUP BY 
		ds.Supplier_name
)

SELECT
	RANK() OVER(ORDER BY AverageLeadTime) AS RankInLeadTime,
	Supplier_name,
	AverageLeadTime
FROM
	SupplierLeadTime
ORDER BY
	AverageLeadTime;



/*Are there any correlations between supplier locations and shipping costs?*/
WITH SupplierShippingCosts AS (
	SELECT
		ds.Supplier_name,
		ds.Location AS SupplierLocation,
		AVG(sh.Costs) AS AverageShippingCost
	FROM
		DimSuppliers ds
	JOIN DimShipping sh ON ds.Location = sh.Location
	GROUP BY 
		ds.Supplier_name,
		ds.Location
)
SELECT
	RANK() OVER(PARTITION BY SupplierLocation ORDER BY AverageShippingCost) AS RankInLocation,
	Supplier_name,
	SupplierLocation,
	AverageShippingCost
FROM
	SupplierShippingCosts
ORDER BY
    SupplierLocation, RankInLocation;



/* Maximum shipping cost by different transportation modes */
WITH MaxShippingCosts AS (
	SELECT 
		Transportation_modes,
		MAX(Shipping_costs) AS MaxShippingCost
	FROM DimShipping
	GROUP BY Transportation_modes
)
SELECT
	Transportation_modes,
	MaxShippingCost
FROM
	MaxShippingCosts;