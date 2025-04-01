-- User Story: As a shop owner, I want to be able to add new items to and remove old items from my menu...
INSERT INTO MenuItems (ItemId, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive)
VALUES (1001, 1, 'Honey Lavender Latte', 4.75, 'Espresso with steamed milk, honey, and lavender syrup', 'Beverage', TRUE, TRUE);

-- User Story: As a shop owner, I want access to a dashboard that displays transaction data like the number of purchases...
SELECT COUNT(DISTINCT t.TransactionId) AS RewardItemTransactionCount
FROM Transactions t
JOIN OrderDetails od ON t.TransactionId = od.TransactionId
JOIN MenuItems mi ON od.ItemId = mi.ItemId
WHERE t.MerchantId = 123 AND mi.IsRewardItem = TRUE AND t.Date >= '2024-01-01';

-- User Story: As a shop owner, I want to be able to edit the featured “reward item” I offer each month...
-- Deactivate the current reward item
UPDATE MenuItems
SET IsRewardItem = FALSE
WHERE MerchantID = 123 AND IsRewardItem = TRUE;

-- Activate the new reward item
UPDATE MenuItems
SET IsRewardItem = TRUE
WHERE ItemID = 1005 AND MerchantID = 123;


-- User Story: As a shop owner, I want to access customer contact info...
SELECT c.FirstName, c.LastName, c.Email, c.Phone
FROM Customers c
JOIN CommsSubscribers cc ON c.CustomerID = cc.CustomerID
JOIN Merchants m ON cc.MerchantID = m.MerchantID
WHERE m.MerchantID = 123 AND c.IsActive = TRUE;


-- User Story: As a shop owner, I want to make a payment for my membership plan...
-- Creating a dummy customer
INSERT INTO Transactions (CustomerID, MerchantID, PaymentMethod, CardUsed, Date, Time, TransactionType, AmountPaid)
VALUES (3, 1, 'Card', 1, CURRENT_DATE, CURRENT_TIME, 'Membership Fee', 49.99);