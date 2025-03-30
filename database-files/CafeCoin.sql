CREATE DATABASE IF NOT EXISTS CafeCoinDB;
USE CafeCoinDB;

CREATE TABLE IF NOT EXISTS Customers
(
    CustomerID  INT AUTO_INCREMENT PRIMARY KEY,
    FirstName   VARCHAR(255) NOT NULL,
    LastName    VARCHAR(255) NOT NULL,
    Email       VARCHAR(255) NOT NULL UNIQUE,
    Phone       VARCHAR(255),
    Address     VARCHAR(255),
    CoinBalance INT     DEFAULT 0,
    DateJoined  DATE         NOT NULL,
    Active      BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS Merchants
(
    MerchantID    INT AUTO_INCREMENT PRIMARY KEY,
    MerchantName  VARCHAR(255) NOT NULL,
    MerchantType  VARCHAR(255),
    MembershipLvl VARCHAR(255),
    Email         VARCHAR(255) NOT NULL UNIQUE,
    Phone         VARCHAR(255),
    Address       VARCHAR(255),
    Website       VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS Employees
(
    EmployeeID   INT AUTO_INCREMENT PRIMARY KEY,
    FirstName    VARCHAR(255) NOT NULL,
    LastName     VARCHAR(255) NOT NULL,
    Email        VARCHAR(255) NOT NULL UNIQUE,
    Phone        VARCHAR(255),
    EmployeeType VARCHAR(255),
    StartDate    DATE         NOT NULL,
    Active       BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS Transactions
(
    TransactionID   INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID      INT  NOT NULL,
    MerchantID      INT  NOT NULL,
    Date            DATE NOT NULL,
    Time            TIME,
    Total           DECIMAL(10, 2),
    CoinsUsed       INT,
    BalanceDue      DECIMAL(10, 2),
    TransactionType VARCHAR(255),
    FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (MerchantID) REFERENCES Merchants (MerchantID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS MenuItems
(
    ItemID      INT AUTO_INCREMENT PRIMARY KEY,
    MerchantID  INT          NOT NULL,
    ItemName    VARCHAR(255) NOT NULL,
    Price       DECIMAL(10, 2),
    Description VARCHAR(255),
    ItemType    VARCHAR(255),
    RewardItem  BOOLEAN,
    Active      BOOLEAN,
    FOREIGN KEY (MerchantID) REFERENCES Merchants (MerchantID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS OrderDetails
(
    TransactionID INT,
    ItemID        INT,
    Quantity      INT,
    Price         DECIMAL(10, 2),
    Total         DECIMAL(10, 2),
    PRIMARY KEY (TransactionID, ItemID),
    FOREIGN KEY (TransactionID) REFERENCES Transactions (TransactionID) ON DELETE CASCADE,
    FOREIGN KEY (ItemID) REFERENCES MenuItems (ItemID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ComplaintTickets
(
    TicketID             INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID           INT      NOT NULL,
    AssignedToEmployeeID INT,
    CreatedAt            DATETIME NOT NULL,
    Category             VARCHAR(255),
    Description          TEXT,
    Status               VARCHAR(255),
    Priority             VARCHAR(255),
    FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (AssignedToEmployeeID) REFERENCES Employees (EmployeeID) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS Surveys
(
    SurveyID   INT AUTO_INCREMENT PRIMARY KEY,
    MerchantID INT  NOT NULL,
    Question   TEXT NOT NULL,
    DateSent   DATE,
    FOREIGN KEY (MerchantID) REFERENCES Merchants (MerchantID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS SurveyResponses
(
    ResponseID INT AUTO_INCREMENT PRIMARY KEY,
    SurveyID   INT NOT NULL,
    CustomerID INT NOT NULL,
    Response   TEXT,
    SubmitDate DATE,
    FOREIGN KEY (SurveyID) REFERENCES Surveys (SurveyID) ON DELETE CASCADE,
    FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS DigitalPaymentMethods
(
    MethodID         INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID       INT NOT NULL,
    MethodType       VARCHAR(255),
    CardNumber       VARCHAR(255) UNIQUE,
    CardType         VARCHAR(255),
    Expiration       DATE,
    AvailableBalance DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS CustomerComms
(
    PromoID    INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    Type       VARCHAR(255),
    Content    TEXT,
    DateSent   DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Subscribers
(
    CustomerID     INT,
    SubType        VARCHAR(255),
    DateSubscribed DATE,
    Active         BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (CustomerID, SubType),
    FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Leads
(
    LeadID          INT AUTO_INCREMENT PRIMARY KEY,
    EmployeeID      INT,
    BusinessName    VARCHAR(255),
    OwnerFirst      VARCHAR(255),
    OwnerLast       VARCHAR(255),
    Email           VARCHAR(255),
    PhoneNumber     VARCHAR(255),
    Address         VARCHAR(255),
    Website         VARCHAR(255),
    Status          VARCHAR(255),
    Notes           TEXT,
    LastContactedAt DATETIME,
    FOREIGN KEY (EmployeeID) REFERENCES Employees (EmployeeID) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS FraudTickets
(
    TicketID    INT AUTO_INCREMENT PRIMARY KEY,
    EmployeeID  INT,
    CreatedAt   DATETIME NOT NULL,
    Description TEXT,
    Status      VARCHAR(255),
    FOREIGN KEY (EmployeeID) REFERENCES Employees (EmployeeID) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS Alerts
(
    AlertID    INT AUTO_INCREMENT PRIMARY KEY,
    EmployeeID INT,
    Title      VARCHAR(255),
    Message    TEXT,
    SentAt     DATETIME,
    Audience   VARCHAR(255),
    Status     VARCHAR(255),
    Priority   VARCHAR(255),
    FOREIGN KEY (EmployeeID) REFERENCES Employees (EmployeeID) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS Features
(
    FeatureID   INT AUTO_INCREMENT PRIMARY KEY,
    Name        VARCHAR(255) NOT NULL,
    Description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS StoreFeatures
(
    MerchantID INT,
    FeatureID  INT,
    PRIMARY KEY (MerchantID, FeatureID),
    FOREIGN KEY (MerchantID) REFERENCES Merchants (MerchantID) ON DELETE CASCADE,
    FOREIGN KEY (FeatureID) REFERENCES Features (FeatureID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS MerchantTransaction
(
    MerchantTransactionID INT AUTO_INCREMENT PRIMARY KEY,
    TransactionID         INT NOT NULL,
    Date                  DATE,
    Time                  TIME,
    BalanceDue            DECIMAL(10, 2),
    TransactionType       VARCHAR(255),
    FOREIGN KEY (TransactionID) REFERENCES Transactions (TransactionID) ON DELETE CASCADE
);

-- Customers
INSERT INTO Customers (FirstName, LastName, Email, Phone, Address, CoinBalance, DateJoined, Active)
VALUES ('Alice', 'Smith', 'alice@example.com', '555-1234', '123 Main St', 200, '2024-01-01', TRUE),
       ('Bob', 'Jones', 'bob@example.com', '555-5678', '456 Elm St', 150, '2024-02-15', TRUE);

-- Merchants
INSERT INTO Merchants (MerchantName, MerchantType, MembershipLvl, Email, Phone, Address, Website)
VALUES ('Cafe Bliss', 'Coffee Shop', 'Gold', 'contact@cafebliss.com', '555-1111', '789 Bean Blvd', 'www.cafebliss.com'),
       ('The Juice Bar', 'Smoothies', 'Silver', 'info@juicebar.com', '555-2222', '321 Berry Ln', 'www.juicebar.com');

-- Employees
INSERT INTO Employees (FirstName, LastName, Email, Phone, EmployeeType, StartDate, Active)
VALUES ('Jane', 'Doe', 'jane.doe@cafecoin.com', '555-9999', 'Support', '2023-08-01', TRUE),
       ('Mark', 'Lee', 'mark.lee@cafecoin.com', '555-8888', 'Fraud Analyst', '2023-06-15', TRUE);

-- Transactions
INSERT INTO Transactions (CustomerID, MerchantID, Date, Time, Total, CoinsUsed, BalanceDue, TransactionType)
VALUES (1, 1, '2025-03-01', '08:30:00', 12.50, 50, 0.00, 'Coffee'),
       (2, 2, '2025-03-02', '10:15:00', 9.75, 25, 1.50, 'Juice');

-- MenuItems
INSERT INTO MenuItems (MerchantID, ItemName, Price, Description, ItemType, RewardItem, Active)
VALUES (1, 'Latte', 4.50, 'Hot espresso with milk', 'Drink', TRUE, TRUE),
       (2, 'Strawberry Smoothie', 5.25, 'Fresh strawberries and yogurt', 'Drink', FALSE, TRUE);

-- OrderDetails
INSERT INTO OrderDetails (TransactionID, ItemID, Quantity, Price, Total)
VALUES (1, 1, 2, 4.50, 9.00),
       (2, 2, 1, 5.25, 5.25);

-- ComplaintTickets
INSERT INTO ComplaintTickets (CustomerID, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority)
VALUES (1, 1, '2025-03-03 09:00:00', 'Order Delay', 'My order took 30 mins', 'Open', 'High'),
       (2, 2, '2025-03-03 10:45:00', 'App Crash', 'App crashed during payment', 'Resolved', 'Medium');

-- Surveys
INSERT INTO Surveys (MerchantID, Question, DateSent)
VALUES (1, 'How do you rate our coffee?', '2025-03-01'),
       (2, 'Was the smoothie fresh?', '2025-03-02');

-- SurveyResponses
INSERT INTO SurveyResponses (SurveyID, CustomerID, Response, SubmitDate)
VALUES (1, 1, 'Great taste!', '2025-03-01'),
       (2, 2, 'Yes, very fresh', '2025-03-02');

-- DigitalPaymentMethods
INSERT INTO DigitalPaymentMethods (CustomerID, MethodType, CardNumber, CardType, Expiration, AvailableBalance)
VALUES (1, 'Credit Card', '4111111111111111', 'Visa', '2026-01-01', 500.00),
       (2, 'Apple Pay', 'N/A', 'Mobile', NULL, 300.00);

-- CustomerComms
INSERT INTO CustomerComms (CustomerID, Type, Content, DateSent)
VALUES (1, 'Promo', '20% off your next drink!', '2025-02-28'),
       (2, 'Update', 'We’ve updated our app!', '2025-03-01');

-- Subscribers
INSERT INTO Subscribers (CustomerID, SubType, DateSubscribed, Active)
VALUES (1, 'Monthly', '2025-01-01', TRUE),
       (2, 'Weekly', '2025-02-01', TRUE);

-- Leads
INSERT INTO Leads (EmployeeID, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes,
                   LastContactedAt)
VALUES (1, 'Sunny Cafe', 'Taylor', 'Green', 'sunny@example.com', '555-3333', '789 Brew St', 'www.sunnycafe.com', 'New',
        'Called once', '2025-03-01'),
       (2, 'Urban Bean', 'Alex', 'Lopez', 'urban@example.com', '555-4444', '654 Java Ave', 'www.urbanbean.com',
        'In Review', 'Requested follow-up', '2025-03-02');

-- FraudTickets
INSERT INTO FraudTickets (EmployeeID, CreatedAt, Description, Status)
VALUES (2, '2025-03-03 11:00:00', 'Suspicious coin refund', 'Open'),
       (1, '2025-03-04 10:30:00', 'Multiple failed payment attempts', 'Investigating');

-- Alerts
INSERT INTO Alerts (EmployeeID, Title, Message, SentAt, Audience, Status, Priority)
VALUES (1, 'System Maintenance', 'Scheduled downtime tonight.', '2025-03-03 18:00:00', 'All Users', 'Sent', 'Low'),
       (2, 'New Feature Launch', 'We’ve added order tracking!', '2025-03-04 09:00:00', 'Customers', 'Sent', 'Medium');

-- Features
INSERT INTO Features (Name, Description)
VALUES ('Free Wi-Fi', 'High-speed wireless internet'),
       ('Outdoor Seating', 'Tables available outside');

-- StoreFeatures
INSERT INTO StoreFeatures (MerchantID, FeatureID)
VALUES (1, 1),
       (2, 2);

-- MerchantTransaction
INSERT INTO MerchantTransaction (TransactionID, Date, Time, BalanceDue, TransactionType)
VALUES (1, '2025-03-01', '08:30:00', 0.00, 'Coffee'),
       (2, '2025-03-02', '10:15:00', 1.50, 'Juice');
