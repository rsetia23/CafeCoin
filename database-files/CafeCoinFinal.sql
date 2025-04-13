CREATE DATABASE IF NOT EXISTS CafeCoin;
USE CafeCoin;

DROP TABLE IF EXISTS ComplaintTickets;
DROP TABLE IF EXISTS Leads;
DROP TABLE IF EXISTS FraudTickets;
DROP TABLE IF EXISTS Alerts;
DROP TABLE IF EXISTS SurveyResponses;
DROP TABLE IF EXISTS CommsSubscribers;
DROP TABLE IF EXISTS Surveys;
DROP TABLE IF EXISTS CustomerComms;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS OrderDetails;
DROP TABLE IF EXISTS Transactions;
DROP TABLE IF EXISTS RewardItems;
DROP TABLE IF EXISTS MenuItems;
DROP TABLE IF EXISTS StoreAmenities;
DROP TABLE IF EXISTS CustAmenityPrefs;
DROP TABLE IF EXISTS DigitalPaymentMethods;
DROP TABLE IF EXISTS Amenities;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Merchants;


CREATE TABLE IF NOT EXISTS Customers
(
    CustomerID     INT AUTO_INCREMENT PRIMARY KEY,
    FirstName      VARCHAR(255) NOT NULL,
    LastName       VARCHAR(255) NOT NULL,
    Email          VARCHAR(255) NOT NULL UNIQUE,
    Phone          VARCHAR(255),
    StreetAddress  VARCHAR(255),
    Apartment      VARCHAR(255),
    City           VARCHAR(255),
    State          VARCHAR(255),
    ZipCode        VARCHAR(9),
    CoinBalance    INT     DEFAULT 0,
    AccountBalance INT     DEFAULT 0,
    DateJoined     DATE         NOT NULL,
    IsActive       BOOLEAN DEFAULT TRUE,
    AutoReloadAmt  INT     DEFAULT 0
);

CREATE TABLE IF NOT EXISTS Merchants
(
    MerchantID    INT AUTO_INCREMENT PRIMARY KEY,
    MerchantName  VARCHAR(255) NOT NULL,
    MerchantType  VARCHAR(255) NOT NULL,
    MembershipLvl VARCHAR(255),
    Email         VARCHAR(255) NOT NULL UNIQUE,
    Phone         VARCHAR(255),
    StreetAddress VARCHAR(255),
    Suite         VARCHAR(255),
    City          VARCHAR(255),
    State         VARCHAR(255),
    ZipCode       VARCHAR(9),
    Lat DECIMAL(9, 6),
    Lon DECIMAL(9,6),
    Website       VARCHAR(255),
    OwnerFirst    VARCHAR(255),
    OwnerLast     VARCHAR(255),
    OwnerComment  VARCHAR(255),
    IsActive      BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS Employees
(
    EmployeeID   INT AUTO_INCREMENT PRIMARY KEY,
    MerchantID   INT          NOT NULL,
    FirstName    VARCHAR(255) NOT NULL,
    LastName     VARCHAR(255) NOT NULL,
    Email        VARCHAR(255) NOT NULL UNIQUE,
    Phone        VARCHAR(255),
    EmployeeType VARCHAR(255),
    StartDate    DATE         NOT NULL,
    IsActive     BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (MerchantID) REFERENCES Merchants (MerchantID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS DigitalPaymentMethods
(
    MethodID   INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    CardType   VARCHAR(255),
    NameOnCard VARCHAR(255),
    CardNumber VARCHAR(16) UNIQUE,
    Expiration DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Transactions
(
    TransactionID   INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID      INT          NOT NULL,
    MerchantID      INT          NOT NULL,
    PaymentMethod   VARCHAR(255),
    CardUsed        INT,
    TransactionDate            DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    TransactionType VARCHAR(255) NOT NULL,
    AmountPaid      DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (MerchantID) REFERENCES Merchants (MerchantID) ON DELETE CASCADE,
    FOREIGN KEY (CardUsed) REFERENCES DigitalPaymentMethods (MethodID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS MenuItems
(
    ItemID       INT AUTO_INCREMENT PRIMARY KEY,
    MerchantID   INT          NOT NULL,
    ItemName     VARCHAR(255) NOT NULL,
    CurrentPrice DECIMAL(10, 2),
    Description  VARCHAR(255),
    ItemType     VARCHAR(255),
    IsRewardItem BOOLEAN,
    IsActive     BOOLEAN,
    FOREIGN KEY (MerchantID) REFERENCES Merchants (MerchantID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS RewardItems
(
    RewardID   INT AUTO_INCREMENT PRIMARY KEY,
    MerchantID INT NOT NULL,
    ItemID     INT NOT NULL,
    StartDate  DATE,
    EndDate    DATE,
    FOREIGN KEY (MerchantID) REFERENCES Merchants (MerchantID) ON DELETE CASCADE,
    FOREIGN KEY (ItemID) REFERENCES MenuItems (ItemID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS OrderDetails
(
    OrderItemNum   INT,
    TransactionID  INT,
    ItemID         INT,
    Price          DECIMAL(10, 2),
    RewardRedeemed BOOLEAN NOT NULL,
    Discount       DECIMAL(10, 2),
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
    FOREIGN KEY (AssignedToEmployeeID) REFERENCES Employees (EmployeeID) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS Surveys
(
    SurveyID     INT AUTO_INCREMENT PRIMARY KEY,
    CreatedByEmp INT  NOT NULL,
    Question     TEXT NOT NULL,
    DateSent     DATE,
    FOREIGN KEY (CreatedByEmp) REFERENCES Employees (EmployeeID) ON DELETE CASCADE
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
    MerchantID     INT,
    DateSubscribed DATE,
    PRIMARY KEY (CustomerID, MerchantID),
    FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (MerchantID) REFERENCES Merchants (MerchantID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Leads
(
    LeadID          INT AUTO_INCREMENT PRIMARY KEY,
    AssignedToEmp   INT,
    BusinessName    VARCHAR(255),
    OwnerFirst      VARCHAR(255),
    OwnerLast       VARCHAR(255),
    Email           VARCHAR(255),
    PhoneNumber     VARCHAR(255),
    StreetAddress   VARCHAR(255),
    Suite           VARCHAR(255),
    City            VARCHAR(255),
    State           VARCHAR(255),
    ZipCode         VARCHAR(9),
    Website         VARCHAR(255),
    Status          VARCHAR(255),
    Notes           TEXT,
    LastContactedAt DATETIME,
    FOREIGN KEY (AssignedToEmp) REFERENCES Employees (EmployeeID) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS FraudTickets
(
    TicketID      INT AUTO_INCREMENT PRIMARY KEY,
    AssignedToEmp INT,
    CreatedAt     DATETIME NOT NULL,
    Description   TEXT,
    Status        VARCHAR(255),
    FOREIGN KEY (AssignedToEmp) REFERENCES Employees (EmployeeID) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS Alerts
(
    AlertID      INT AUTO_INCREMENT PRIMARY KEY,
    CreatedByEmp INT,
    Title        VARCHAR(255),
    Message      TEXT,
    SentAt       DATETIME,
    Audience     VARCHAR(255),
    Status       VARCHAR(255),
    Priority     VARCHAR(255),
    FOREIGN KEY (CreatedByEmp) REFERENCES Employees (EmployeeID) ON DELETE SET NULL
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
