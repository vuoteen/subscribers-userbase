CREATE VIEW subscription_breakdown AS 
(WITH cte AS (SELECT
    s.SubscriptionCountry
    ,s.SubscriptionType
    ,sp.Name AS Product_Name
    ,pd.MonthlyPrice
    ,s.Number AS Subscription_Number
    ,DENSE_RANK() OVER (PARTITION BY s.Number ORDER BY pd.StartDate DESC, pd.EndDate DESC) AS Charge_Rank
FROM
    subscriptions AS s
        LEFT JOIN users AS u
            ON u.Id = s.UserId
        LEFT JOIN subscriptionproducts AS sp
            ON sp.SubscriptionId = s.Id
        LEFT JOIN productdetails AS pd
            ON pd.ProductId = sp.Id
WHERE 1=1
    AND (s.Status = 'Active' OR (s.Status = 'Inactive' AND s.EndDate > CURRENT_DATE))
    AND (s.SubscriptionType IS NULL OR S.SubscriptionType IN ('Internet Provider','Cable Provider'))
    AND u.IsTestUser IS FALSE
    AND pd.Model = 'FlatFee')

SELECT
    cte.SubscriptionCountry
    ,cte.SubscriptionType
    ,IF(cte.SubscriptionType IS NULL,'Direct','Third-Party') AS SubscriptionCategory
    ,cte.Product_Name AS ProductName
    ,CASE   WHEN cte.Product_Name LIKE '%Annual Pass%' THEN "Annual Pass"
            WHEN cte.Product_Name LIKE '%Monthly Pass%' THEN "Monthly Pass"
                ELSE 'N/A'
                    END AS Plan_Type
    ,cte.MonthlyPrice
    ,COUNT(cte.Subscription_Number) AS Total_Subscriptions
    ,SUM(COUNT(cte.Subscription_Number)) OVER (PARTITION BY cte.SubscriptionCountry,IF(cte.SubscriptionType IS NULL,'Direct','Third-Party')) AS Total_Per_Subscription_Category
    ,SUM(COUNT(cte.Subscription_Number)) OVER (PARTITION BY cte.SubscriptionCountry,cte.SubscriptionType) AS Total_Per_Subscription_Type
    ,SUM(COUNT(cte.Subscription_Number)) OVER (PARTITION BY cte.SubscriptionCountry,CASE   WHEN cte.Product_Name LIKE '%Annual Pass%' THEN "Annual Pass"
            WHEN cte.Product_Name LIKE '%Monthly Pass%' THEN "Monthly Pass"
                ELSE 'N/A'
                    END) AS Total_Per_Plan_Type 
    ,SUM(COUNT(cte.Subscription_Number)) OVER (PARTITION BY cte.SubscriptionCountry) AS Total_Per_Subscription_Country
FROM cte
WHERE 1=1
    AND cte.Charge_Rank = 1
GROUP BY 1,2,3,4,5,6
ORDER BY 11 DESC, 1 ASC, 3 ASC, 10 DESC, 7 DESC)