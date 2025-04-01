USE CafeCoin;

--  As a Regional System Administrator, I want to deprecate a business that is no longer participating in the program so that I can remove their data and keep the system clean.
DELETE FROM Merchants
WHERE MerchantID = 2;

-- As a Regional System Administrator, I want to automate user deprecation after confirmation so that the offboarding process is streamlined and our systems do not store duplicate or inactive accounts.
UPDATE Customers
SET IsActive = FALSE
WHERE DateJoined < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- As a Regional System Administrator, I want a tool that flags accounts with suspicious activity so that I can efficiently investigate, report, and prevent fraudulent behavior.
INSERT INTO FraudTickets (AssignedToEmp, CreatedAt, Description, Status)
VALUES (2, NOW(), 'Unusual coin redemption behavior', 'Open');

SELECT *
FROM FraudTickets
WHERE Status = 'Open';

UPDATE FraudTickets
SET Status = 'Resolved'
WHERE TicketID = 1;

-- As a Regional System Administrator, I want to manually update point totals or account data so that I can adequately respond to verified customer or business owner complaints or errors.
UPDATE Customers
SET CoinBalance = 275
WHERE CustomerID = 1;

UPDATE Merchants
SET MembershipLvl = 'Gold'
WHERE MerchantID = 1;

-- As a Regional System Administrator, I want to build surveys for customers and businesses so that I can collect feedback, identify pain points in the platform, and design solutions to improve our data management and client-facing systems.
INSERT INTO Surveys (SurveyID, CreatedByEmp, Question, DateSent)
VALUES (3, 2, 'How satisfied are you with our rewards system?', CURDATE());

SELECT * FROM SurveyResponses
WHERE SurveyID = 1;


-- As a Regional System Administrator, I want to send mass notifications about maintenance, outages, and feature updates to users and businesses so that all platform users are given fair notice about down time and other relevant issues.
INSERT INTO Alerts (CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority)
VALUES (
  1,
  'Planned Maintenance',
  'The platform will be down from 2 AM–4 AM on April 5.',
  NOW(),
  'All Users',
  'Sent',
  'High'
);

SELECT * FROM Alerts
WHERE Audience = 'All Users';
