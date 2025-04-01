USE CafeCoin;

-- As a Data Analyst, I want to view sales and financial performance across all Collective members so that
-- I can identify high-performing and underperforming locations.
    SELECT *
    From CafeCoin.Transactions;

-- As a Data Analyst, I want to compare key performance indicators (like average transaction value or reward
-- redemptions) across different stores or regions so that I can highlight trends, gaps, and best practices.

-- find average transaction value
    SELECT
    m.MerchantID,
    m.MerchantName,
    m.City,
    m.State,
    COUNT(t.TransactionID) AS NumTransactions,
    SUM(t.AmountPaid) AS TotalRevenue,
    AVG(t.AmountPaid) AS AvgTransactionValue
FROM Transactions t
JOIN Merchants m ON t.MerchantID = m.MerchantID
GROUP BY m.MerchantID, m.MerchantName, m.City, m.State
ORDER BY AvgTransactionValue DESC;

-- find reward redemption
    SELECT
    m.MerchantID,
    m.MerchantName,
    m.City,
    m.State,
    COUNT(DISTINCT t.TransactionID) AS TotalTransactions,
    COUNT(CASE WHEN od.RewardRedeemed THEN 1 END) AS RewardRedemptions,
    ROUND(100.0 * COUNT(CASE WHEN od.RewardRedeemed THEN 1 END) / COUNT(DISTINCT t.TransactionID), 2) AS RedemptionRatePercent
FROM Transactions t
JOIN OrderDetails od ON t.TransactionID = od.TransactionID
JOIN Merchants m ON t.MerchantID = m.MerchantID
GROUP BY m.MerchantID, m.MerchantName, m.City, m.State
ORDER BY RedemptionRatePercent DESC;


-- As a Data Analyst, I want to view the membership level of Collective stores so that CafeCoin
-- marketing teams can tailor promotional campaigns more effectively.

    SELECT MerchantID, MerchantName, MerchantType, MembershipLvl
    FROM Merchants;

-- As a Data Analyst, I want a Dashboard of CafeCoin’s employee headcount–so that I can maintain CafeCoin’s
-- financial health by providing relevant information to key internal stakeholders.

    Select *
    FROM CafeCoin.CafeCoinEmployees;

-- As a Data Analyst, I want to identify the most popular drinks system-wide so
-- that I can identify products or businesses to be featured in our promotional campaigns.
    SELECT
    mi.ItemID,
    mi.ItemName,
    mi.Description,
    mi.CurrentPrice,
    mi.ItemType,
    m.MerchantName,
    COUNT(od.ItemID) AS TimesPurchased,
    SUM(od.Price) AS TotalRevenue
FROM OrderDetails od
JOIN MenuItems mi ON od.ItemID = mi.ItemID
JOIN Merchants m ON mi.MerchantID = m.MerchantID
WHERE mi.ItemType = 'Drink'
GROUP BY mi.ItemID, mi.ItemName, mi.Description, mi.CurrentPrice, mi.ItemType, m.MerchantName
ORDER BY TimesPurchased DESC;


-- As a Data Analyst, I want to see a list of potential stores so that field teams are able to better
-- prioritize outreach to potential new Collective members.
    SELECT *
    From CafeCoin.Leads;
