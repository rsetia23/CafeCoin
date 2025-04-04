CREATE DATABASE IF NOT EXISTS CafeCoinDB;
USE CafeCoinDB2;

CREATE TABLE IF NOT EXISTS Customers
(
    CustomerID  INT AUTO_INCREMENT PRIMARY KEY,
    FirstName   VARCHAR(255) NOT NULL,
    LastName    VARCHAR(255) NOT NULL,
    Email       VARCHAR(255) NOT NULL UNIQUE,
    Phone       VARCHAR(255),
    StreetAddress     VARCHAR(255),
    Apartment VARCHAR(255),
    City VARCHAR(255),
    State VARCHAR(255),
    ZipCode VARCHAR(9),
    CoinBalance INT     DEFAULT 0,
    AccountBalance INT DEFAULT 0,
    DateJoined  DATE         NOT NULL,
    IsActive      BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS Merchants
(
    MerchantID    INT AUTO_INCREMENT PRIMARY KEY,
    MerchantName  VARCHAR(255) NOT NULL,
    MerchantType  VARCHAR(255),
    MembershipLvl VARCHAR(255),
    Email         VARCHAR(255) NOT NULL UNIQUE,
    Phone         VARCHAR(255),
    StreetAddress     VARCHAR(255),
    Suite VARCHAR(255),
    City VARCHAR(255),
    State VARCHAR(255),
    ZipCode VARCHAR(9),
    Website       VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS CafeCoinEmployees
(
    EmployeeID   INT AUTO_INCREMENT PRIMARY KEY,
    FirstName    VARCHAR(255) NOT NULL,
    LastName     VARCHAR(255) NOT NULL,
    Email        VARCHAR(255) NOT NULL UNIQUE,
    Phone        VARCHAR(255),
    EmployeeType VARCHAR(255),
    StartDate    DATE         NOT NULL,
    IsActive       BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS DigitalPaymentMethods
(
    MethodID         INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID       INT NOT NULL,
    CardType         VARCHAR(255),
    NameOnCard VARCHAR(255),
    CardNumber       VARCHAR(16) UNIQUE,
    Expiration       DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Transactions
(
    TransactionID   INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID      INT  NOT NULL,
    MerchantID      INT  NOT NULL,
    PaymentMethod VARCHAR(255),
    CardUsed INT,
    Date            DATE NOT NULL,
    Time            TIME,
    TransactionType VARCHAR(255),
    FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (MerchantID) REFERENCES Merchants (MerchantID) ON DELETE CASCADE,
    FOREIGN KEY (CardUsed) REFERENCES DigitalPaymentMethods (MethodID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS MenuItems
(
    ItemID      INT AUTO_INCREMENT PRIMARY KEY,
    MerchantID  INT          NOT NULL,
    ItemName    VARCHAR(255) NOT NULL,
    Price       DECIMAL(10, 2),
    Description VARCHAR(255),
    ItemType    VARCHAR(255),
    IsRewardItem  BOOLEAN,
    IsActive      BOOLEAN,
    FOREIGN KEY (MerchantID) REFERENCES Merchants (MerchantID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS OrderDetails
(
    OrderItemNum INT,
    TransactionID INT,
    ItemID        INT,
    Quantity      INT,
    Price         DECIMAL(10, 2),
    CoinsUsed INT,
    Discount DECIMAL (10, 2),
    CoinsEarned INT,
    PRIMARY KEY (TransactionID, OrderItemNum),
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
    FOREIGN KEY (AssignedToEmployeeID) REFERENCES CafeCoinEmployees (EmployeeID) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS Surveys
(
    SurveyID   INT AUTO_INCREMENT PRIMARY KEY,
    CreatedByEmp INT  NOT NULL,
    Question   TEXT NOT NULL,
    DateSent   DATE,
    FOREIGN KEY (CreatedByEmp) REFERENCES CafeCoinEmployees (EmployeeID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS SurveyResponses
(
    ResponseID INT AUTO_INCREMENT,
    SurveyID   INT NOT NULL,
    CustomerID INT NOT NULL,
    Response   TEXT,
    SubmitDate DATE,
    PRIMARY KEY (ResponseID, SurveyID),
    FOREIGN KEY (SurveyID) REFERENCES Surveys (SurveyID) ON DELETE CASCADE,
    FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS CustomerComms
(
    PromoID    INT AUTO_INCREMENT PRIMARY KEY,
    MerchantID INT NOT NULL,
    Type       VARCHAR(255),
    Content    TEXT,
    DateSent   DATE,
    FOREIGN KEY (MerchantID) REFERENCES Merchants (MerchantID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS CommsSubscribers
(
    CustomerID     INT,
    MerchantID        INT,
    DateSubscribed DATE,
    PRIMARY KEY (CustomerID, MerchantID),
    FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (MerchantID) REFERENCES Merchants (MerchantID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Leads
(
    LeadID          INT AUTO_INCREMENT PRIMARY KEY,
    AssignedToEmp      INT,
    BusinessName    VARCHAR(255),
    OwnerFirst      VARCHAR(255),
    OwnerLast       VARCHAR(255),
    Email           VARCHAR(255),
    PhoneNumber     VARCHAR(255),
    StreetAddress     VARCHAR(255),
    Suite VARCHAR(255),
    City VARCHAR(255),
    State VARCHAR(255),
    ZipCode VARCHAR(9),
    Website         VARCHAR(255),
    Status          VARCHAR(255),
    Notes           TEXT,
    LastContactedAt DATETIME,
    FOREIGN KEY (AssignedToEmp) REFERENCES CafeCoinEmployees (EmployeeID) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS FraudTickets
(
    TicketID    INT AUTO_INCREMENT PRIMARY KEY,
    AssignedToEmp  INT,
    CreatedAt   DATETIME NOT NULL,
    Description TEXT,
    Status      VARCHAR(255),
    FOREIGN KEY (AssignedToEmp) REFERENCES CafeCoinEmployees (EmployeeID) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS Alerts
(
    AlertID    INT AUTO_INCREMENT PRIMARY KEY,
    CreatedByEmp INT,
    Title VARCHAR(255),
    Message    TEXT,
    SentAt     DATETIME,
    Audience   VARCHAR(255),
    Status     VARCHAR(255),
    Priority   VARCHAR(255),
    FOREIGN KEY (CreatedByEmp) REFERENCES CafeCoinEmployees (EmployeeID) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS Amenities
(
    AmenityID   INT AUTO_INCREMENT PRIMARY KEY,
    Name        VARCHAR(255) NOT NULL,
    Description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS StoreAmenities
(
    MerchantID INT,
    AmenityID  INT,
    PRIMARY KEY (MerchantID, AmenityID),
    FOREIGN KEY (MerchantID) REFERENCES Merchants (MerchantID) ON DELETE CASCADE,
    FOREIGN KEY (AmenityID) REFERENCES Amenities (AmenityID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS CustAmenityPrefs
(
    CustomerID INT,
    AmenityID  INT,
    PRIMARY KEY (CustomerID, AmenityID),
    FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (AmenityID) REFERENCES Amenities (AmenityID) ON DELETE CASCADE
);

-- Customers
INSERT INTO Customers (FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive)
VALUES ('Alice', 'Smith', 'alice@example.com', '555-1234', '123 Main St', 'Unit 3', 'Boston', 'MA', '02120', 200, 50, '2024-01-01', TRUE),
       ('Bob', 'Jones', 'bob@example.com', '555-5678', '456 Elm St', 'Apartment #4', 'Boston', 'MA', '02120', 150, 10, '2024-02-15', TRUE);

-- Merchants
INSERT INTO Merchants (MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Website)
VALUES ('CafeCoin', 'CafeCoin', NULL, 'contact@cafecoin.com', '555-1111', '789 Bean Blvd', NULL, 'Boston', 'MA', '02120', 'www.cafecoin.com'),
       ('The Juice Bar', 'Collective Member', 'Silver', 'info@juicebar.com', '555-2222', '321 Berry Ln', 'Suite 1', 'Boston', 'MA', '02120','www.juicebar.com');

-- CafeCoinEmployees
INSERT INTO CafeCoinEmployees (FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive)
VALUES ('Jane', 'Doe', 'jane.doe@cafecoin.com', '555-9999', 'Support', '2023-08-01', TRUE),
       ('Mark', 'Lee', 'mark.lee@cafecoin.com', '555-8888', 'Fraud Analyst', '2023-06-15', TRUE);

-- DigitalPaymentMethods
INSERT INTO DigitalPaymentMethods (CustomerID, CardType, CardNumber, NameOnCard, Expiration)
VALUES (1, 'Credit', '4111111111111111', 'Alice A. Smith', '2026-01-01'),
       (1, 'Debit', '4222222222222222', 'Alice Smith', '2027-01-01');

-- Transactions
INSERT INTO Transactions (CustomerID, MerchantID, Date, Time, PaymentMethod, CardUsed, TransactionType)
VALUES (1, 1, '2025-03-01', '08:30:00', 'card', 1, 'Product'),
       (2, 2, '2025-03-02', '10:15:00', 'card', 1, 'Product');

-- MenuItems
INSERT INTO MenuItems (MerchantID, ItemName, Price, Description, ItemType, IsRewardItem, IsActive)
VALUES (1, 'Latte', 4.50, 'Hot espresso with milk', 'Drink', TRUE, TRUE),
       (2, 'Strawberry Smoothie', 5.25, 'Fresh strawberries and yogurt', 'Drink', FALSE, TRUE);

-- OrderDetails
INSERT INTO OrderDetails (OrderItemNum, TransactionID, ItemID, Quantity, Price, CoinsUsed, Discount, CoinsEarned)
VALUES (1, 1, 1, 2, 4.50, 1000, 4.50, 45),
       (1, 2, 2, 1, 5.25, 0, 0, 53);

-- ComplaintTickets
INSERT INTO ComplaintTickets (CustomerID, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority)
VALUES (1, 1, '2025-03-03 09:00:00', 'Order Delay', 'My order took 30 mins', 'Open', 'High'),
       (2, 2, '2025-03-03 10:45:00', 'App Crash', 'App crashed during payment', 'Resolved', 'Medium');

-- Surveys
INSERT INTO Surveys (SurveyID, CreatedByEmp, Question, DateSent)
VALUES (1, 1, 'Have you enjoyed your recent experiences with CafeCoin?', '2025-03-01'),
       (2, 2, 'Do you use the shop map feature?', '2025-03-02');

-- SurveyResponses
INSERT INTO SurveyResponses (ResponseID, SurveyID, CustomerID, Response, SubmitDate)
VALUES (1, 1, 1, 'Great taste!', '2025-03-01'),
       (2, 1, 2, 'Yes, all the time', '2025-03-02');

-- CustomerComms
INSERT INTO CustomerComms (MerchantID, Type, Content, DateSent)
VALUES (1, 'Promo', '20% off your next drink!', '2025-02-28'),
       (2, 'Update', 'We’ve updated our website!', '2025-03-01');

-- Subscribers
INSERT INTO CommsSubscribers (CustomerID, MerchantID, DateSubscribed)
VALUES (1, 1, '2025-01-01'),
       (2, 1, '2025-02-01');

-- Leads
INSERT INTO Leads (AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Suite, City, State, ZipCode, Website, Status, Notes,
                   LastContactedAt)
VALUES (1, 'Sunny Cafe', 'Taylor', 'Green', 'sunny@example.com', '555-3333', '789 Brew St', NULL, 'Boston', 'MA', '02120','www.sunnycafe.com', 'New',
        'Called once', '2025-03-01'),
       (2, 'Urban Bean', 'Alex', 'Lopez', 'urban@example.com', '555-4444', '654 Java Ave', NULL, 'Boston', 'MA', '02120', 'www.urbanbean.com',
        'In Review', 'Requested follow-up', '2025-03-02');

-- FraudTickets
INSERT INTO FraudTickets (AssignedToEmp, CreatedAt, Description, Status)
VALUES (2, '2025-03-03 11:00:00', 'Suspicious coin refund', 'Open'),
       (1, '2025-03-04 10:30:00', 'Multiple failed payment attempts', 'Investigating');

-- Alerts
INSERT INTO Alerts (CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority)
VALUES (1, 'System Maintenance', 'Scheduled downtime tonight.', '2025-03-03 18:00:00', 'All Users', 'Sent', 'Low'),
       (2, 'New Feature Launch', 'We’ve added order tracking!', '2025-03-04 09:00:00', 'Customers', 'Sent', 'Medium');

-- Features
INSERT INTO Amenities (Name, Description)
VALUES ('Free Wi-Fi', 'High-speed wireless internet'),
       ('Outdoor Seating', 'Tables available outside');

-- StoreFeatures
INSERT INTO StoreAmenities (MerchantID, AmenityID)
VALUES (1, 1),
       (2, 2);

-- MerchantTransaction
INSERT INTO CustAmenityPrefs (CustomerID, AmenityID)
VALUES (1, 1),
       (2, 1);
