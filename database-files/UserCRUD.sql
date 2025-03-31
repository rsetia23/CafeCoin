USE CafeCoinDB;

-- As a Collective customer, I want to have the option to load my CafeCoin profile with a cash balance in-app or in-store so that my coﬀee transactions are more seamless.
INSERT INTO Transactions (CustomerID, MerchantID, Date, Time, PaymentMethod, CardUsed, TransactionType)
VALUES (1, 1, '2025-03-31', '10:30:00', 'Card', 1, 'Balance Reload');

UPDATE Customers
SET AccountBalance = AccountBalance + 10
WHERE CustomerID = 1;

-- As a Collective customer, I want to view my Coin accumulation and balance in real-time so that I can understand if I have a reward available and/or how far I am from earning a reward.
SELECT CoinBalance
FROM Customers
WHERE CustomerID = 1;

-- As a Collective customer, I want to access an interactive map featuring Collective members so that I can quickly view the shops near me where I can receive Coins.
SELECT *
FROM Merchants m
WHERE m.City = 'Boston'

-- As a Collective customer, I want to be able to see robust summary statistics of my cafe spending so that I can more eﬀectively manage my coﬀee habit and better understand how much I am contributing to my local coﬀee economy.

-- As a Collective customer, I want to be alerted to upcoming promotions, new menu items, and other news from Collective members I visit frequently so that I can take advantage of oﬀers at my favorite cafes.
INSERT INTO CommsSubscribers (CustomerID, MerchantID, DateSubscribed)
VALUES (1, 2, '2025-03-31')

-- As a Collective customer, I want to review tailored item and shop recommendations based on my preferences so that I can easily locate new cafes to try that I am confident I will enjoy.
SELECT sa.MerchantID
FROM StoreAmenities sa JOIN CustAmenityPrefs cap on sa.AmenityID = cap.AmenityID
WHERE cap.CustomerID = 1;

SELECT *
FROM StoreAmenities sa JOIN CustAmenityPrefs cap on sa.AmenityID = cap.AmenityID;
-- WHERE cap.CustomerID = 1;