USE CafeCoin;

-- As a Collective customer, I want to have the option to load my CafeCoin profile with a cash balance in-app or in-store so that my coﬀee transactions are more seamless.
INSERT INTO Transactions (CustomerID, MerchantID, Date, Time, PaymentMethod, CardUsed, TransactionType, AmountPaid)
VALUES (1, 1, '2025-03-31', '10:30:00', 'Card', 1, 'Balance Reload', 10);

UPDATE Customers
SET AccountBalance = AccountBalance + 10
WHERE CustomerID = 1;

-- As a Collective customer, I want to view my Coin accumulation and balance in real-time so that I can understand if I have a reward available and/or how far I am from earning a reward.
SELECT CoinBalance
FROM Customers
WHERE CustomerID = 1;

-- As a Collective customer, I want to access an interactive map featuring Collective members so that I can quickly view the shops near me where I can receive Coins.
SELECT m.MerchantID, m.MerchantName, m.StreetAddress, m.Suite, m.City, m.State, m.ZipCode
FROM Merchants m
WHERE m.City = 'Boston';

-- As a Collective customer, I want to be able to see robust summary statistics of my cafe spending so that I can more eﬀectively manage my coﬀee habit and better understand how much I am contributing to my local coﬀee economy.
SELECT c.CustomerID, c.FirstName, c.LastName, sum(t.AmountPaid) as TotalSpent, avg(t.AmountPaid) as AvgSpend, max(AmountPaid) as LargestOrder, count(t.TransactionID) as NumOrders, count(DISTINCT od.ItemID) AS UniqueItemsPurchased, sum(od.Discount) AS TotalSavings
FROM Customers c JOIN Transactions t on c.CustomerID = t.CustomerID LEFT JOIN OrderDetails od ON t.TransactionID = od.TransactionID
WHERE t.TransactionType != 'Balance Reload' AND t.Date >= DATE_ADD(NOW(), INTERVAL -1 MONTH)
GROUP BY c.CustomerID, c.FirstName, c.LastName;

-- As a Collective customer, I want to be alerted to upcoming promotions, new menu items, and other news from Collective members I visit frequently so that I can take advantage of oﬀers at my favorite cafes.
INSERT INTO CommsSubscribers (CustomerID, MerchantID, DateSubscribed)
VALUES (1, 2, '2025-03-31');

-- As a Collective customer, I want to review tailored item and shop recommendations based on my preferences so that I can easily locate new cafes to try that I am confident I will enjoy.
-- First approach for recommendations is to recommend all shops that have a feature the customer prefers
-- if one of Bob's preferences is wifi, return all matches between Bob and stores offering wifi
-- if another is outdoor seating, return all matches between Bob and stores not yet returned that offer outdoor seating, etc:
SELECT DISTINCT c.CustomerID, c.FirstName, c.LastName, m.MerchantID, m.MerchantName
FROM StoreAmenities sa JOIN CustAmenityPrefs cap on sa.AmenityID = cap.AmenityID JOIN Customers c on cap.CustomerID = c.CustomerID JOIN Merchants m ON sa.MerchantID = m.MerchantID
WHERE c.FirstName = 'Bob' AND c.LastName = 'Jones';

-- Second approach for recommendations is to recommend only shops that have ALL features the customer prefers
-- eg if Bob prefers wifi and outdoor seating, only return stores offering both:
SELECT c.CustomerID, c.FirstName, c.LastName, m.MerchantName
FROM StoreAmenities sa JOIN CustAmenityPrefs cap on sa.AmenityID = cap.AmenityID JOIN Customers c on cap.CustomerID = c.CustomerID JOIN Merchants m ON sa.MerchantID = m.MerchantID JOIN Amenities a ON cap.AmenityID = a.AmenityID
WHERE c.FirstName = 'Bob' AND c.LastName = 'Jones'
GROUP BY m.MerchantName, c.CustomerID, c.FirstName, c.LastName
HAVING count(distinct cap.AmenityID) = (SELECT COUNT(DISTINCT cap2.AmenityID)
                                        FROM CustAmenityPrefs cap2 JOIN Customers c2 ON cap2.CustomerID = c2.CustomerID
                                        WHERE c2.FirstName = 'Bob' AND c2.LastName = 'Jones');