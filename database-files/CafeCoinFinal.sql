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
    DateJoined     DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
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
    StartDate    DATETIME DEFAULT CURRENT_TIMESTAMP         NOT NULL,
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
    CreatedAt            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
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
    DateSent     DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CreatedByEmp) REFERENCES Employees (EmployeeID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS SurveyResponses
(
    ResponseID INT AUTO_INCREMENT,
    SurveyID   INT NOT NULL,
    CustomerID INT NOT NULL,
    Response   TEXT,
    SubmitDate DATETIME DEFAULT CURRENT_TIMESTAMP,
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
    DateSent   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (MerchantID) REFERENCES Merchants (MerchantID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS CommsSubscribers
(
    CustomerID     INT,
    MerchantID     INT,
    DateSubscribed DATETIME DEFAULT CURRENT_TIMESTAMP,
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
    LastContactedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (AssignedToEmp) REFERENCES Employees (EmployeeID) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS FraudTickets
(
    TicketID      INT AUTO_INCREMENT PRIMARY KEY,
    AssignedToEmp INT,
    CreatedAt     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
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
    SentAt       DATETIME DEFAULT CURRENT_TIMESTAMP,
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

-- Customers
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (1, 'Jasper', 'Finch', 'siwanicki0@wix.com', '520-637-2899', '57 Myrtle Court', '14th Floor', 'Prescott', 'Arizona', '86305', 51, 38, '2024-06-19', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (2, 'Sander', 'Valde', 'svalde1@utexas.edu', '352-968-2822', '2 Algoma Park', 'Room 1095', 'Spring Hill', 'Florida', '34611', 36, 44, '2024-05-14', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (3, 'Berny', 'Avent', 'bavent2@yolasite.com', '510-559-2810', '2 Magdeline Pass', 'Apt 1175', 'Oakland', 'California', '94660', 52, 36, '2024-05-02', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (4, 'Teressa', 'Blogg', 'tblogg3@cnn.com', '313-901-1433', '001 Fieldstone Point', 'Apt 2000', 'Detroit', 'Michigan', '48232', 91, 9, '2024-05-17', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (5, 'Ransom', 'Loads', 'rloads4@skyrock.com', '203-580-1272', '31986 Rusk Avenue', 'Room 1232', 'Fairfield', 'Connecticut', '06825', 97, 27, '2024-06-08', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (6, 'Simonne', 'Gussin', 'sgussin5@nsw.gov.au', '504-411-1785', '4 Sachs Avenue', 'PO Box 52254', 'Metairie', 'Louisiana', '70005', 41, 2, '2025-03-05', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (7, 'Lorrie', 'Quene', 'lquene6@fc2.com', '571-293-5437', '8230 Marquette Parkway', 'Apt 749', 'Fairfax', 'Virginia', '22036', 72, 97, '2025-01-16', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (8, 'Fletcher', 'Shurville', 'fshurville7@illinois.edu', '509-588-6958', '17370 Spaight Junction', 'Room 179', 'Yakima', 'Washington', '98907', 186, 46, '2025-02-13', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (9, 'Gertrudis', 'Brownfield', 'gbrownfield8@ebay.co.uk', '718-453-9805', '1 Northport Crossing', '14th Floor', 'Brooklyn', 'New York', '11220', 74, 47, '2025-01-25', true, 7);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (10, 'Nora', 'Beadnall', 'nbeadnall9@ted.com', '850-711-1279', '88494 Clyde Gallagher Lane', 'Room 1149', 'Panama City', 'Florida', '32405', 28, 63, '2024-12-01', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (11, 'Stanislaus', 'Izkoveski', 'sizkoveskia@wp.com', '316-623-0814', '1684 Superior Terrace', 'Apt 1366', 'Wichita', 'Kansas', '67230', 96, 78, '2024-11-06', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (12, 'Brietta', 'Scourge', 'bscourgeb@creativecommons.org', '213-139-8491', '7038 Mendota Trail', 'PO Box 9283', 'Los Angeles', 'California', '90030', 65, 17, '2025-01-18', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (13, 'Fernandina', 'Spurden', 'fspurdenc@friendfeed.com', '509-314-8059', '7846 Oriole Point', 'PO Box 16775', 'Spokane', 'Washington', '99260', 49, 54, '2024-10-06', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (14, 'Brendon', 'Berge', 'bberged@yolasite.com', '256-368-3893', '1677 Clove Way', 'Room 1594', 'Huntsville', 'Alabama', '35815', 24, 19, '2025-02-27', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (15, 'Elinore', 'Strangeways', 'estrangewayse@sakura.ne.jp', '818-133-6654', '503 Canary Crossing', 'Room 1400', 'Torrance', 'California', '90510', 299, 79, '2024-07-14', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (16, 'Harriott', 'Hallgarth', 'hhallgarthf@com.com', '615-532-5825', '50845 Northfield Lane', '2nd Floor', 'Nashville', 'Tennessee', '37250', 322, 5, '2024-10-02', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (17, 'Rurik', 'Pemberton', 'rpembertong@hhs.gov', '330-838-9811', '3 Green Point', 'Room 838', 'Akron', 'Ohio', '44310', 99, 90, '2024-05-08', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (18, 'Rafaelita', 'Hamelyn', 'rhamelynh@archive.org', '803-713-8627', '54230 Riverside Lane', 'Suite 6', 'Columbia', 'South Carolina', '29215', 31, 38, '2025-02-26', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (19, 'Brett', 'Cundy', 'bcundyi@themeforest.net', '202-956-2563', '1112 Dapin Park', 'Suite 90', 'Washington', 'District of Columbia', '20409', 52, 38, '2025-01-21', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (20, 'Elissa', 'Moryson', 'emorysonj@smh.com.au', '561-625-5251', '41 Mockingbird Circle', 'PO Box 53454', 'West Palm Beach', 'Florida', '33405', 29, 6, '2024-09-09', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (21, 'Henderson', 'Gillitt', 'hgillittk@example.com', '515-136-0596', '60482 Schlimgen Trail', 'Room 282', 'Des Moines', 'Iowa', '50347', 36, 10, '2025-03-23', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (22, 'Marley', 'Cricket', 'mcricketl@xrea.com', '202-445-5306', '03 Moulton Street', 'Apt 1884', 'Washington', 'District of Columbia', '20010', 4, 62, '2025-03-30', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (23, 'Berna', 'Bagwell', 'bbagwellm@economist.com', '937-742-2810', '58508 Dixon Road', '19th Floor', 'Dayton', 'Ohio', '45419', 77, 55, '2024-08-19', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (24, 'Blinny', 'Eyles', 'beylesn@cnn.com', '318-401-7384', '0424 Merrick Plaza', 'Apt 1774', 'Shreveport', 'Louisiana', '71151', 90, 30, '2024-06-04', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (25, 'Robbie', 'McAvin', 'rmcavino@csmonitor.com', '804-779-8687', '13 Bartillon Terrace', 'Apt 972', 'Richmond', 'Virginia', '23260', 0, 98, '2024-05-11', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (26, 'Mirilla', 'Pozzi', 'mpozzip@forbes.com', '850-415-7836', '0 Cody Lane', 'Room 1929', 'Pensacola', 'Florida', '32511', 99, 39, '2024-12-22', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (27, 'Kippie', 'Steffan', 'ksteffanq@reference.com', '816-650-3033', '2929 Kensington Drive', 'Suite 89', 'Kansas City', 'Missouri', '64199', 16, 1, '2024-11-11', false, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (28, 'Romain', 'Chessill', 'rchessillr@liveinternet.ru', '484-114-0055', '089 Farmco Plaza', 'PO Box 82635', 'Bethlehem', 'Pennsylvania', '18018', 81, 25, '2024-09-30', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (29, 'Paten', 'Pimm', 'ppimms@dagondesign.com', '937-986-1761', '3 Sunfield Junction', 'Suite 33', 'Dayton', 'Ohio', '45470', 87, 3, '2024-10-14', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (30, 'Deanne', 'Ruane', 'druanet@uol.com.br', '831-614-8913', '12 Gateway Road', 'Room 1210', 'Santa Cruz', 'California', '95064', 65, 59, '2024-08-14', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (31, 'Josephine', 'Boothe', 'jbootheu@epa.gov', '208-568-0763', '98 Hallows Drive', 'Apt 343', 'Idaho Falls', 'Idaho', '83405', 48, 88, '2024-07-24', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (32, 'Marsiella', 'Paul', 'mpaulv@example.com', '775-927-8902', '5290 Sachs Circle', 'Suite 94', 'Reno', 'Nevada', '89550', 323, 31, '2024-04-11', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (33, 'Lianna', 'Stracey', 'lstraceyw@shareasale.com', '316-407-4591', '1 Park Meadow Plaza', 'Room 360', 'Wichita', 'Kansas', '67236', 89, 63, '2024-09-22', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (34, 'Aloisia', 'Marie', 'amariex@chron.com', '360-925-3043', '028 Maywood Park', '10th Floor', 'Seattle', 'Washington', '98121', 94, 45, '2024-05-07', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (35, 'Victoria', 'Blessed', 'vblessedy@google.fr', '860-345-2431', '59 Arrowood Place', 'PO Box 78394', 'Hartford', 'Connecticut', '06140', 32, 3, '2025-02-28', false, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (36, 'Nanon', 'Hammarberg', 'nhammarbergz@ask.com', '956-697-6475', '72 Mcbride Street', '13th Floor', 'Laredo', 'Texas', '78044', 300, 27, '2024-06-22', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (37, 'Camilla', 'Duchateau', 'cduchateau10@usda.gov', '626-633-7187', '84 Lunder Alley', 'Suite 30', 'Pasadena', 'California', '91109', 71, 34, '2024-07-12', true, 17);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (38, 'Heidi', 'MacCoughen', 'hmaccoughen11@phoca.cz', '724-775-9252', '271 Sundown Terrace', '12th Floor', 'Pittsburgh', 'Pennsylvania', '15210', 97, 49, '2025-02-06', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (39, 'Kev', 'Cohn', 'kcohn12@nbcnews.com', '314-979-7351', '065 Montana Junction', '7th Floor', 'Saint Louis', 'Missouri', '63150', 63, 35, '2024-12-22', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (40, 'Malissa', 'Bielfeldt', 'mbielfeldt13@reverbnation.com', '972-861-4815', '17012 Valley Edge Hill', 'Room 1869', 'Dallas', 'Texas', '75251', 52, 34, '2024-06-09', true, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (101, 'Alice', 'Smith', 'alice@example.com', '555-1234', '123 Main St', 'Unit 3', 'Boston', 'MA', '02120', 200, 50, '2024-01-01', TRUE, 0);
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) VALUES (102, 'Bob', 'Jones', 'bob@example.com', '555-5678', '456 Elm St', 'Apartment #4', 'Boston', 'MA', '02120', 150, 10, '2024-02-15', TRUE, 5);

-- Merchants
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (1, 'CafeCoin', 'CafeCoin', NULL, 'estalman0@meetup.com', '508-474-2771', '08 2nd Crossing', '18th Floor', 'Newton', 'Massachusetts', '02162', 42.3319, -71.254, 'msn.com', 'Elwin', 'Stalman', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (2, 'The Brew Spot', 'Collective Member', 'Silver', 'dpaeckmeyer1@yellowpages.com', '217-212-8066', '15 Hintze Drive', 'PO Box 62357', 'Springfield', 'Illinois', '62705', 39.7495, -89.606, 'weebly.com', 'Danica', 'Paeckmeyer', 'Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (3, 'Urban Grind', 'Collective Member', 'Gold', 'rbichard2@theatlantic.com', '214-173-8702', '42828 Sunnyside Avenue', 'Suite 90', 'Dallas', 'Texas', '75379', 32.7673, -96.7776, 'devhub.com', 'Read', 'Bichard', 'Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (4, 'Cozy Corner Cafe', 'Collective Member', 'Bronze', 'gmartinon3@nymag.com', '253-266-7139', '59 Namekagon Plaza', '13th Floor', 'Tacoma', 'Washington', '98411', 47.0662, -122.1132, 'wp.com', 'Garold', 'Martinon', 'Nulla justo.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (5, 'The Daily Drip', 'Collective Member', 'Silver', 'nsoares4@prnewswire.com', '413-899-2498', '9057 Oak Valley Trail', 'PO Box 70724', 'Springfield', 'Massachusetts', '01114', 42.1707, -72.6048, 'deviantart.com', 'Niko', 'Soares', 'In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (6, 'Java Junction', 'Collective Member', 'Gold', 'krooney5@huffingtonpost.com', '210-872-0938', '1483 Summerview Park', 'Room 1030', 'San Antonio', 'Texas', '78205', 29.4237, -98.4925, 'businesswire.com', 'Kelcie', 'Rooney', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (7, 'The Roasted Bean', 'Collective Member', 'Bronze', 'agumbley6@friendfeed.com', '515-665-5676', '925 Myrtle Center', 'Suite 55', 'Des Moines', 'Iowa', '50330', 41.6727, -93.5722, 'i2i.jp', 'Ashley', 'Gumbley', 'Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (8, 'The Coffee Loft', 'Collective Member', 'Silver', 'cbubbins7@boston.com', '305-556-6477', '52 Steensland Hill', '6th Floor', 'Miami Beach', 'Florida', '33141', 25.8486, -80.1446, 'pinterest.com', 'Carce', 'Bubbins', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (9, 'The Perk Place', 'Collective Member', 'Gold', 'kjonsson8@statcounter.com', '480-496-4530', '4 Erie Alley', 'Apt 1345', 'Phoenix', 'Arizona', '85045', 33.3022, -112.1226, 'gov.uk', 'Kristal', 'Jonsson', 'In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (10, 'Brewed Awakening', 'Collective Member', 'Bronze', 'cshrigley9@prlog.org', '502-906-6618', '24 Toban Avenue', 'Apt 1224', 'Louisville', 'Kentucky', '40233', 38.189, -85.6768, 'google.nl', 'Coriss', 'Shrigley', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (11, 'Caffeine & Co.', 'Collective Member', 'Silver', 'tkhilkova@newyorker.com', '763-327-8583', '05 Oakridge Way', 'PO Box 73011', 'Monticello', 'Minnesota', '55585', 45.2009, -93.8881, 'barnesandnoble.com', 'Tedi', 'Khilkov', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (12, 'Steam & Beans', 'Collective Member', 'Gold', 'ealabasterb@wikia.com', '952-915-8248', '808 Bunker Hill Place', 'PO Box 78990', 'Maple Plain', 'Minnesota', '55579', 45.0159, -93.4719, 'studiopress.com', 'Ellswerth', 'Alabaster', 'Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (13, 'The Java House', 'Collective Member', 'Bronze', 'cfinec@dmoz.org', '862-298-0624', '5052 Pine View Hill', 'Apt 580', 'Newark', 'New Jersey', '07195', 40.7918, -74.2452, 'vistaprint.com', 'Cordey', 'Fine', 'Duis aliquam convallis nunc.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (14, 'The Beanery', 'Collective Member', 'Silver', 'ggarcid@phpbb.com', '562-208-4478', '621 Leroy Park', 'Apt 1137', 'Long Beach', 'California', '90847', 33.7866, -118.2987, 'vk.com', 'Giffie', 'Garci', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', false);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (15, 'Steamy Sips', 'Collective Member', 'Gold', 'ewestnagee@chron.com', '214-579-5386', '256 Sugar Alley', '15th Floor', 'Mesquite', 'Texas', '75185', 32.7403, -96.5618, 'diigo.com', 'Esther', 'Westnage', 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (16, 'The Grindhouse', 'Collective Member', 'Bronze', 'kmcgorleyf@technorati.com', '202-800-7387', '1 Clyde Gallagher Road', 'Suite 20', 'Washington', 'District of Columbia', '20073', 38.897, -77.0251, 'hexun.com', 'Kriste', 'Mc Gorley', 'Vestibulum ac est lacinia nisi venenatis tristique.', false);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (17, 'Mocha Moments', 'Collective Member', 'Silver', 'lgasparrog@wiley.com', '763-890-1393', '96389 Alpine Hill', '11th Floor', 'Minneapolis', 'Minnesota', '55402', 44.9762, -93.2759, 'woothemes.com', 'Lionel', 'Gasparro', 'Nunc purus. Phasellus in felis. Donec semper sapien a libero.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (18, 'Cup of Joy', 'Collective Member', 'Gold', 'hshalesh@amazon.co.jp', '903-525-3436', '825 Sundown Avenue', 'PO Box 69402', 'Longview', 'Texas', '75605', 32.5547, -94.7767, 'yellowpages.com', 'Heinrik', 'Shales', 'Morbi quis tortor id nulla ultrices aliquet.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (19, 'The Morning Buzz', 'Collective Member', 'Bronze', 'cdrablei@yolasite.com', '315-367-2712', '7245 Gina Center', 'PO Box 92459', 'Syracuse', 'New York', '13205', 43.0123, -76.1452, 'cisco.com', 'Chryste', 'Drable', 'Curabitur gravida nisi at nibh.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (20, 'Grind & Brew', 'Collective Member', 'Silver', 'wgiralj@guardian.co.uk', '201-934-2823', '77658 Crest Line Avenue', 'Suite 47', 'Jersey City', 'New Jersey', '07305', 40.702, -74.089, 'google.cn', 'Wendy', 'Giral', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (21, 'Espresso Express', 'Collective Member', 'Gold', 'bcreswellk@ox.ac.uk', '972-306-7972', '49 Elmside Center', 'Room 150', 'Dallas', 'Texas', '75236', 32.69, -96.9177, 'engadget.com', 'Bell', 'Creswell', 'Donec semper sapien a libero. Nam dui.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (22, 'Roasty Toasty Cafe', 'Collective Member', 'Bronze', 'jharbourl@rakuten.co.jp', '201-477-8083', '7904 Annamark Center', 'PO Box 3467', 'Paterson', 'New Jersey', '07522', 40.9252, -74.1781, 'com.com', 'Janaye', 'Harbour', 'Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo.', false);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (23, 'Bean Town Cafe', 'Collective Member', 'Silver', 'vbluesm@house.gov', '509-669-8454', '2378 Butternut Circle', '16th Floor', 'Yakima', 'Washington', '98907', 46.6288, -120.574, 'scribd.com', 'Vite', 'Blues', 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (24, 'The Java Joint', 'Collective Member', 'Gold', 'lmarplen@hexun.com', '571-829-5706', '14 Graedel Junction', 'Suite 15', 'Arlington', 'Virginia', '22234', 38.8808, -77.113, 'techcrunch.com', 'Leila', 'Marple', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (25, 'The Steaming Cup', 'Collective Member', 'Bronze', 'swheatero@google.co.jp', '360-288-8918', '4 Melvin Street', 'Suite 46', 'Seattle', 'Washington', '98166', 47.4511, -122.353, 'google.es', 'Susann', 'Wheater', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum.', false);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (26, 'Bold Brews', 'Collective Member', 'Silver', 'dcaistorp@com.com', '561-995-2178', '8977 Ryan Court', 'Apt 296', 'West Palm Beach', 'Florida', '33411', 26.6644, -80.1741, 'goodreads.com', 'Daryl', 'Caistor', 'Nulla justo. Aliquam quis turpis eget elit sodales scelerisque.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (27, 'Caffeine Central', 'Collective Member', 'Gold', 'eprovestq@whitehouse.gov', '626-906-9117', '87387 Carey Parkway', 'Room 1179', 'Pasadena', 'California', '91103', 34.1669, -118.1551, 'sciencedaily.com', 'Ethelyn', 'Provest', 'Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (28, 'Brewed Bliss', 'Collective Member', 'Bronze', 'crappoportr@slideshare.net', '561-926-7793', '53799 Scoville Court', 'PO Box 17741', 'West Palm Beach', 'Florida', '33411', 26.6644, -80.1741, 'hibu.com', 'Cullin', 'Rappoport', 'Donec quis orci eget orci vehicula condimentum.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (29, 'The Cozy Mug', 'Collective Member', 'Silver', 'tgarrishs@zdnet.com', '757-524-7551', '6 Glendale Pass', 'Apt 1767', 'Suffolk', 'Virginia', '23436', 36.8926, -76.5142, 'google.com.hk', 'Thorpe', 'Garrish', 'Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (30, 'The Sipping Station', 'Collective Member', 'Gold', 'fsillyt@hhs.gov', '612-621-0582', '573 East Junction', '10th Floor', 'Minneapolis', 'Minnesota', '55417', 44.9054, -93.2361, 'biglobe.ne.jp', 'Felecia', 'Silly', 'Suspendisse accumsan tortor quis turpis. Sed ante.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (31, 'Pour Over Paradise', 'Collective Member', 'Bronze', 'ccatonnetu@forbes.com', '505-759-4253', '902 Lien Road', 'Apt 1723', 'Albuquerque', 'New Mexico', '87201', 35.0443, -106.6729, 'nsw.gov.au', 'Cornelle', 'Catonnet', 'Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (32, 'Sip & Savor', 'Collective Member', 'Silver', 'bjerransv@princeton.edu', '619-290-3016', '17709 Arrowood Crossing', '3rd Floor', 'San Diego', 'California', '92165', 33.0169, -116.846, 'php.net', 'Blake', 'Jerrans', 'Nulla ut erat id mauris vulputate elementum. Nullam varius.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (33, 'The Daily Grind', 'Collective Member', 'Gold', 'bhaighw@statcounter.com', '772-580-3663', '33203 Crescent Oaks Parkway', 'Room 903', 'Vero Beach', 'Florida', '32969', 27.709, -80.5726, 'paypal.com', 'Bibbie', 'Haigh', 'Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (34, 'The Brew Crew', 'Collective Member', 'Bronze', 'kmallindinex@nymag.com', '607-134-7511', '9 Warner Street', 'PO Box 95551', 'Elmira', 'New York', '14905', 42.0869, -76.8397, 'so-net.ne.jp', 'Kristien', 'Mallindine', 'Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (35, 'Steeped & Steamy', 'Collective Member', 'Silver', 'mmarcusseny@illinois.edu', '212-620-7919', '5328 Florence Avenue', 'Apt 1921', 'Jamaica', 'New York', '11431', 40.6869, -73.8501, 'bing.com', 'Marinna', 'Marcussen', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (36, 'The Roasting Room', 'Collective Member', 'Gold', 'haylenz@microsoft.com', '814-318-0490', '7 Manley Avenue', 'PO Box 41362', 'Erie', 'Pennsylvania', '16505', 42.1109, -80.1534, 'merriam-webster.com', 'Hilary', 'Aylen', 'Vestibulum sed magna at nunc commodo placerat.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (37, 'Bean & Barrel', 'Collective Member', 'Bronze', 'ihatrey10@chronoengine.com', '651-144-5097', '23263 Hallows Lane', '19th Floor', 'Minneapolis', 'Minnesota', '55417', 44.9054, -93.2361, 'comcast.net', 'Iorgo', 'Hatrey', 'In hac habitasse platea dictumst.', false);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (38, 'Sip City', 'Collective Member', 'Silver', 'alebang11@nhs.uk', '941-131-6168', '6 Clove Junction', '19th Floor', 'Naples', 'Florida', '34102', 26.134, -81.7953, 'freewebs.com', 'Aryn', 'Lebang', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', true);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (39, 'The Coffee Cartel', 'Collective Member', 'Gold', 'trosendahl12@youku.com', '571-951-4042', '9 Northridge Lane', 'Room 608', 'Reston', 'Virginia', '22096', 38.8318, -77.2888, 'elpais.com', 'Terri-jo', 'Rosendahl', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', false);
INSERT INTO Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) VALUES (40, 'Brewtopia', 'Collective Member', 'Bronze', 'boatley13@prweb.com', '480-823-8189', '1682 Parkside Lane', '12th Floor', 'Phoenix', 'Arizona', '85025', 33.4226, -111.7236, 'facebook.com', 'Barnabas', 'Oatley', 'Cras pellentesque volutpat dui.', true);

-- Employees
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (1, '11', 'Steven', 'McKitterick', 'smckitterick0@blinklist.com', '303-794-5400', 'CafeCoin', '2024-10-21', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (2, '29', 'Lorraine', 'Gabitis', 'lgabitis1@ebay.com', '422-924-6520', 'CafeCoin', '2024-10-06', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (3, '37', 'Mil', 'Flight', 'mflight2@timesonline.co.uk', '931-487-8790', 'Store', '2024-11-03', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (4, '18', 'Gerald', 'Ashpole', 'gashpole3@china.com.cn', '872-677-5466', 'Store', '2024-11-14', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (5, '24', 'Mead', 'Stedman', 'mstedman4@zimbio.com', '108-789-0589', 'Store', '2025-01-21', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (6, '6', 'Spike', 'Judge', 'sjudge5@github.com', '214-645-8154', 'CafeCoin', '2024-12-24', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (7, '38', 'Lyndsey', 'Lyles', 'llyles6@ask.com', '606-797-8710', 'CafeCoin', '2024-06-05', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (8, '15', 'Baldwin', 'Leopold', 'bleopold7@fema.gov', '910-847-5697', 'CafeCoin', '2024-12-19', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (9, '16', 'Willy', 'Inge', 'winge8@wikia.com', '410-344-0804', 'CafeCoin', '2025-01-30', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (10, '14', 'Ximenes', 'Jarville', 'xjarville9@themeforest.net', '684-887-9922', 'Store', '2025-03-04', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (11, '31', 'Sapphire', 'Bacchus', 'sbacchusa@shinystat.com', '970-596-0150', 'Store', '2024-09-27', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (12, '17', 'Kirstin', 'Brunker', 'kbrunkerb@si.edu', '907-600-2118', 'Store', '2025-03-12', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (13, '20', 'Ariadne', 'Arlott', 'aarlottc@weather.com', '962-423-5124', 'Store', '2024-06-25', false);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (14, '23', 'Tabbi', 'Jeacocke', 'tjeacocked@springer.com', '216-625-8586', 'Store', '2025-03-03', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (15, '12', 'Herschel', 'Covotto', 'hcovottoe@epa.gov', '214-412-7778', 'CafeCoin', '2024-08-13', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (16, '28', 'Avictor', 'Glazzard', 'aglazzardf@gizmodo.com', '214-158-9993', 'CafeCoin', '2025-03-10', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (17, '33', 'Hermina', 'Shelly', 'hshellyg@shutterfly.com', '882-992-7839', 'CafeCoin', '2024-06-21', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (18, '19', 'Kane', 'Granger', 'kgrangerh@prnewswire.com', '526-568-5393', 'CafeCoin', '2024-06-27', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (19, '26', 'Moyra', 'Antecki', 'manteckii@nba.com', '620-267-7924', 'Store', '2024-07-11', false);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (20, '7', 'Arther', 'Blakeman', 'ablakemanj@example.com', '208-838-4387', 'CafeCoin', '2024-06-11', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (21, '9', 'Renard', 'Pentecust', 'rpentecustk@cmu.edu', '950-977-7908', 'Store', '2024-12-27', false);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (22, '27', 'Jayme', 'Goulden', 'jgouldenl@mtv.com', '801-131-5288', 'Store', '2024-04-09', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (23, '10', 'Lisette', 'Cawood', 'lcawoodm@linkedin.com', '163-910-9869', 'Store', '2025-02-08', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (24, '3', 'Karlie', 'Haslegrave', 'khaslegraven@huffingtonpost.com', '480-465-3817', 'CafeCoin', '2024-05-27', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (25, '5', 'Thorn', 'Curston', 'tcurstono@blogspot.com', '306-285-8014', 'CafeCoin', '2024-06-22', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (26, '34', 'Ned', 'Crush', 'ncrushp@house.gov', '165-987-2399', 'Store', '2024-10-05', false);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (27, '8', 'Tessi', 'Reade', 'treadeq@google.com', '654-890-3243', 'Store', '2024-09-11', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (28, '40', 'Marybeth', 'Alti', 'maltir@simplemachines.org', '418-985-1448', 'CafeCoin', '2024-11-09', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (29, '13', 'Ingunna', 'Holstein', 'iholsteins@1und1.de', '595-163-0150', 'Store', '2025-02-01', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (30, '2', 'Gwenneth', 'Malacrida', 'gmalacridat@digg.com', '746-360-8411', 'CafeCoin', '2024-07-01', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (31, '30', 'Tannie', 'Neil', 'tneilu@amazonaws.com', '970-969-0219', 'Store', '2025-02-18', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (32, '35', 'Mellisa', 'Beverstock', 'mbeverstockv@eventbrite.com', '387-165-5273', 'Store', '2024-06-26', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (33, '21', 'Gilles', 'Barbery', 'gbarberyw@independent.co.uk', '259-849-0945', 'Store', '2025-02-01', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (34, '1', 'Aliza', 'Handrok', 'ahandrokx@odnoklassniki.ru', '198-643-3210', 'Store', '2025-01-22', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (35, '22', 'Darsey', 'Masdin', 'dmasdiny@weibo.com', '802-325-8796', 'Store', '2024-10-17', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (36, '25', 'Fiona', 'Quilliam', 'fquilliamz@yahoo.com', '896-467-8808', 'CafeCoin', '2024-06-29', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (37, '39', 'Eunice', 'Collen', 'ecollen10@multiply.com', '819-779-0335', 'Store', '2024-07-28', false);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (38, '32', 'Serena', 'Bailes', 'sbailes11@ihg.com', '169-342-7899', 'CafeCoin', '2024-04-18', false);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (39, '36', 'Dawna', 'Benediktovich', 'dbenediktovich12@fotki.com', '904-322-4593', 'Store', '2024-04-22', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (40, '4', 'Con', 'Mourgue', 'cmourgue13@cbsnews.com', '214-500-0406', 'CafeCoin', '2024-06-14', false);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (41, '7', 'Grete', 'Harrowell', 'gharrowell14@spotify.com', '254-227-2704', 'CafeCoin', '2024-08-09', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (42, '15', 'Paule', 'Vayne', 'pvayne15@mozilla.com', '161-997-6939', 'CafeCoin', '2025-01-01', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (43, '20', 'Torrence', 'Bowser', 'tbowser16@ucoz.ru', '610-109-6939', 'Store', '2024-08-10', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (44, '24', 'Armand', 'Hanmore', 'ahanmore17@prweb.com', '699-860-7354', 'CafeCoin', '2025-03-11', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (45, '32', 'Sadye', 'Scamal', 'sscamal18@sohu.com', '775-861-4980', 'CafeCoin', '2024-11-25', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (46, '12', 'Augy', 'Godsal', 'agodsal19@ovh.net', '962-399-9210', 'CafeCoin', '2024-10-28', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (47, '30', 'Mil', 'Nanuccioi', 'mnanuccioi1a@dropbox.com', '322-459-1610', 'Store', '2025-03-03', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (48, '16', 'Jonis', 'Cushion', 'jcushion1b@ow.ly', '582-500-5138', 'CafeCoin', '2025-01-04', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (49, '21', 'Raynard', 'Rayson', 'rrayson1c@yandex.ru', '547-855-1371', 'CafeCoin', '2024-10-08', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (50, '35', 'Donetta', 'Bottinelli', 'dbottinelli1d@ezinearticles.com', '188-206-9169', 'Store', '2025-01-21', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (51, '10', 'Francine', 'Asals', 'fasals1e@wordpress.com', '905-112-1148', 'CafeCoin', '2024-12-09', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (52, '19', 'Rozamond', 'Beecham', 'rbeecham1f@unesco.org', '410-307-9092', 'Store', '2024-10-16', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (53, '4', 'Adiana', 'Kilban', 'akilban1g@sciencedaily.com', '667-685-0711', 'CafeCoin', '2024-09-17', false);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (54, '37', 'Mandie', 'Ruoss', 'mruoss1h@disqus.com', '975-114-8281', 'CafeCoin', '2024-07-08', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (55, '40', 'Eldon', 'Wyvill', 'ewyvill1i@reddit.com', '604-972-6866', 'Store', '2024-07-22', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (56, '33', 'Sue', 'Bryett', 'sbryett1j@bigcartel.com', '665-819-4839', 'Store', '2024-08-06', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (57, '27', 'Willyt', 'Newby', 'wnewby1k@drupal.org', '743-643-9910', 'CafeCoin', '2024-12-08', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (58, '22', 'Ronna', 'Camm', 'rcamm1l@blog.com', '244-744-6988', 'Store', '2025-01-20', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (59, '17', 'Mariya', 'McGrath', 'mmcgrath1m@nps.gov', '428-754-3915', 'CafeCoin', '2025-02-28', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (60, '1', 'Lorie', 'Fears', 'lfears1n@i2i.jp', '826-405-4224', 'Store', '2025-03-13', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (61, '23', 'Hercule', 'Shadrach', 'hshadrach1o@si.edu', '171-282-5851', 'CafeCoin', '2025-01-10', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (62, '2', 'Herta', 'Nolot', 'hnolot1p@123-reg.co.uk', '894-222-6944', 'CafeCoin', '2024-10-13', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (63, '18', 'Alys', 'Keiling', 'akeiling1q@hhs.gov', '830-539-0342', 'CafeCoin', '2025-04-02', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (64, '14', 'Clare', 'Verty', 'cverty1r@merriam-webster.com', '218-703-5963', 'CafeCoin', '2025-02-09', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (65, '25', 'Kati', 'Redler', 'kredler1s@addthis.com', '554-942-8266', 'CafeCoin', '2024-09-16', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (66, '26', 'Micky', 'Wissbey', 'mwissbey1t@paginegialle.it', '870-779-7889', 'CafeCoin', '2024-06-02', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (67, '34', 'Melicent', 'Phinnessy', 'mphinnessy1u@altervista.org', '602-426-8667', 'Store', '2024-07-25', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (68, '9', 'Derward', 'Whetnell', 'dwhetnell1v@mac.com', '503-963-0317', 'Store', '2024-11-13', false);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (69, '13', 'Thibaud', 'MacGahy', 'tmacgahy1w@rakuten.co.jp', '384-756-1545', 'CafeCoin', '2025-02-23', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (70, '11', 'Madelon', 'Rubega', 'mrubega1x@nydailynews.com', '906-219-9824', 'Store', '2024-10-20', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (71, '36', 'Katine', 'Weston', 'kweston1y@jimdo.com', '713-622-7957', 'CafeCoin', '2025-04-01', false);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (72, '31', 'Brandice', 'Walklot', 'bwalklot1z@drupal.org', '477-881-7953', 'Store', '2024-06-20', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (73, '38', 'Rochell', 'Courtin', 'rcourtin20@cdbaby.com', '253-734-2255', 'Store', '2024-06-02', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (74, '8', 'Elena', 'Clinton', 'eclinton21@diigo.com', '395-464-9490', 'CafeCoin', '2024-05-24', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (75, '5', 'Arlie', 'Boraston', 'aboraston22@com.com', '652-145-5378', 'CafeCoin', '2025-02-20', false);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (76, '3', 'Ramona', 'Deeks', 'rdeeks23@cbsnews.com', '104-817-9965', 'CafeCoin', '2024-05-11', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (77, '6', 'Cybil', 'Devil', 'cdevil24@ezinearticles.com', '160-901-9598', 'CafeCoin', '2024-07-09', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (78, '29', 'Rollins', 'Mealand', 'rmealand25@discuz.net', '846-183-2448', 'Store', '2024-04-21', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (79, '28', 'Basia', 'Newey', 'bnewey26@gnu.org', '425-455-3982', 'CafeCoin', '2025-01-24', true);
INSERT INTO Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) VALUES (80, '39', 'Stanislas', 'Scogin', 'sscogin27@ihg.com', '796-110-0184', 'CafeCoin', '2025-03-31', true);


-- DPM
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (1, '1', 'Mastercard', 'Mariam Furbank', '5048376235365506', '2025-06-13');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (2, '2', 'Amex', 'Agneta Larkby', '5048378257889983', '2028-03-18');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (3, '3', 'Visa', 'Lucita Icke', '5048376306089530', '2027-06-23');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (4, '4', 'Other', 'Georgena Antonomolii', '5108753537917951', '2027-06-15');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (5, '5', 'Visa', 'Odie Castagno', '5108758221757365', '2026-09-12');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (6, '6', 'Visa', 'Alano Hacking', '5108751924676040', '2027-07-04');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (7, '7', 'Other', 'Liva Borland', '5048372926539988', '2027-07-06');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (8, '8', 'Mastercard', 'Birk Goatman', '5108753419971746', '2025-06-25');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (9, '9', 'Mastercard', 'Golda Fobidge', '5048372923656009', '2028-04-18');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (10, '10', 'Mastercard', 'Doria Overthrow', '5108752850064086', '2028-08-22');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (11, '11', 'Visa', 'Rollin Banaszewski', '5048371926845668', '2026-12-12');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (12, '12', 'Other', 'Lockwood McGebenay', '5108754960991703', '2026-03-24');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (13, '13', 'Other', 'Cary Gibson', '5048371248954370', '2025-05-17');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (14, '14', 'Mastercard', 'Tuck Beaulieu', '5048370892400102', '2028-01-20');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (15, '15', 'Mastercard', 'Alverta Leall', '5108755739412269', '2026-09-20');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (16, '16', 'Visa', 'Lia Tumility', '5108750542045216', '2026-01-19');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (17, '17', 'Mastercard', 'Buddie Heinrici', '5108756014019332', '2028-05-11');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (18, '18', 'Amex', 'Ardyth O''Regan', '5108758884713069', '2026-05-11');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (19, '19', 'Amex', 'Sacha McPhee', '5108759362869720', '2028-08-11');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (20, '20', 'Mastercard', 'Griffith Olivelli', '5048376981313429', '2025-07-06');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (21, '21', 'Other', 'Dean Jamieson', '5108754334597707', '2027-04-22');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (22, '22', 'Amex', 'Consuela Haet', '5048376470125748', '2025-06-17');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (23, '23', 'Mastercard', 'Cher Handasyde', '5048372766548339', '2025-07-01');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (24, '24', 'Mastercard', 'Ninette Torbet', '5108751372976843', '2029-04-02');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (25, '25', 'Mastercard', 'Cindee Clilverd', '5108755089180805', '2025-09-03');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (26, '26', 'Mastercard', 'Sterne Elstone', '5048376147358185', '2027-08-14');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (27, '27', 'Other', 'Courtney Wooff', '5048376240387354', '2028-07-01');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (28, '28', 'Visa', 'Kassia Clemente', '5048377856365700', '2027-03-16');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (29, '29', 'Other', 'Michelle Toulson', '5108755586375387', '2027-04-29');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (30, '30', 'Amex', 'Emlyn Van Eeden', '5108750392035895', '2026-07-07');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (31, '31', 'Other', 'Carmine Rumgay', '5108755063951049', '2025-07-06');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (32, '32', 'Visa', 'Sara-ann Eginton', '5108759075293721', '2026-11-13');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (33, '33', 'Other', 'Quint Hasnip', '5048378275078189', '2028-07-26');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (34, '34', 'Other', 'Rosalind Letty', '5108757988292533', '2027-02-06');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (35, '35', 'Mastercard', 'Brittni Zanolli', '5048379990328917', '2028-11-08');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (36, '36', 'Amex', 'Padriac Pitson', '5108752677498590', '2028-01-05');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (37, '37', 'Other', 'Jana Couper', '5108758203297802', '2028-07-19');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (38, '38', 'Mastercard', 'Valaria Castro', '5108759828627746', '2027-12-12');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (39, '39', 'Visa', 'Huntley Moscone', '5108753863517102', '2028-12-25');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (40, '40', 'Other', 'Gibbie Marczyk', '5108757897851908', '2026-02-15');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (41, '1', 'Visa', 'Kailey Belfitt', '5048372454885894', '2027-03-13');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (42, '2', 'Other', 'Elton Pruce', '5048372959970274', '2026-01-28');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (43, '3', 'Amex', 'Mirilla Gallico', '5048377776093556', '2028-01-31');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (44, '4', 'Other', 'Lorie Sparey', '5048377231163564', '2027-12-26');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (45, '5', 'Other', 'Cookie Dabrowski', '5048379708343356', '2027-06-30');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (46, '6', 'Other', 'Keeley Sole', '5108757221846863', '2027-01-31');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (47, '7', 'Other', 'Zorine Sabbin', '5048370427057161', '2026-11-15');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (48, '8', 'Amex', 'Ranice Doust', '5048374581471317', '2025-06-25');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (49, '9', 'Other', 'Aron Lidgertwood', '5048379093840008', '2026-11-08');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (50, '10', 'Other', 'Nappie Ivel', '5108751849239734', '2028-08-29');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (51, '11', 'Other', 'Roxie Copcutt', '5108756090342384', '2027-07-28');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (52, '12', 'Visa', 'Jesse Cawsey', '5108753845043441', '2029-03-09');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (53, '13', 'Mastercard', 'Abby Scoles', '5108755905604178', '2028-12-15');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (54, '14', 'Mastercard', 'Florencia Liddle', '5108759895831791', '2026-11-05');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (55, '15', 'Other', 'Cathrin Eccleshall', '5048377062320473', '2027-04-11');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (56, '16', 'Visa', 'Mada Harvett', '5108757119685241', '2025-11-19');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (57, '17', 'Other', 'Tiffie Gotts', '5108759638263997', '2025-06-08');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (58, '18', 'Amex', 'Hanson Dionisii', '5048379223233165', '2028-07-07');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (59, '19', 'Other', 'Georgetta Figge', '5048373456029689', '2027-01-30');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (60, '20', 'Mastercard', 'Filia Iacobetto', '5108754892308828', '2026-07-26');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (61, '21', 'Amex', 'Jody Fysh', '5048377546091377', '2026-05-22');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (62, '22', 'Mastercard', 'Marcel Catton', '5108751137675946', '2026-01-30');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (63, '23', 'Visa', 'Harrietta Kyme', '5048372893884359', '2029-01-05');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (64, '24', 'Mastercard', 'Beret Humburton', '5048371430509412', '2026-05-23');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (65, '25', 'Mastercard', 'Marga Edmonson', '5048371118372695', '2029-03-23');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (66, '26', 'Visa', 'Aluin Gyles', '5048373743595161', '2027-08-15');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (67, '27', 'Mastercard', 'Robb Sakins', '5108750526015102', '2028-01-05');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (68, '28', 'Mastercard', 'Artur Mesant', '5108750399424381', '2025-09-20');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (69, '29', 'Amex', 'Odey Arnowicz', '5048373552799763', '2026-03-01');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (70, '30', 'Amex', 'Reena McLarnon', '5108751928871316', '2027-01-30');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (71, '31', 'Amex', 'Abby MacPake', '5048377186231374', '2027-11-29');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (72, '32', 'Mastercard', 'Selinda Willman', '5108754441837020', '2025-09-10');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (73, '33', 'Other', 'Arlana Poate', '5108757896934606', '2028-08-30');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (74, '34', 'Visa', 'Chantal Chitty', '5048371391128483', '2029-03-22');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (75, '35', 'Mastercard', 'Alvan Stode', '5048379746039958', '2027-01-24');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (76, '36', 'Visa', 'Jamie Ortells', '5108754812232751', '2028-08-30');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (77, '37', 'Visa', 'Austine Sarney', '5108753083668156', '2025-06-28');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (78, '38', 'Visa', 'Skippie Styan', '5048376558888985', '2027-01-19');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (79, '39', 'Amex', 'Hyacintha Klimkovich', '5048379136392611', '2027-09-23');
INSERT INTO DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) VALUES (80, '40', 'Mastercard', 'Carol Haburne', '5108753378992055', '2027-09-18');

-- Transactions
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (1, '1', '2', 'accountbalance', null, '2024-08-05', 'purchase', 40.94);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (2, '2', '21', 'accountbalance', null, '2025-02-17', 'purchase', 3.29);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (3, '3', '6', 'accountbalance', null, '2024-12-01', 'purchase', 20.06);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (4, '4', '10', 'card', '4', '2025-01-06', 'purchase', 88.3);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (5, '5', '27', 'accountbalance', null, '2025-02-17', 'purchase', 10);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (6, '6', '14', 'accountbalance', null, '2025-04-04', 'purchase', 73.34);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (7, '7', '22', 'accountbalance', null, '2024-11-13', 'purchase', 0);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (8, '8', '34', 'card', '8', '2024-06-25', 'balancereload', 73.46);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (9, '9', '25', 'accountbalance', null, '2024-11-29', 'purchase', 13.35);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (10, '10', '38', 'accountbalance', null, '2024-08-18', 'purchase', 46.62);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (11, '11', '33', 'card', '11', '2024-05-06', 'purchase', 55.1);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (12, '12', '3', 'accountbalance', null, '2024-05-06', 'purchase', 0);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (13, '13', '16', 'accountbalance', null, '2024-12-06', 'purchase', 43.91);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (14, '14', '26', 'card', '14', '2024-09-25', 'purchase', 77.84);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (15, '15', '31', 'accountbalance', null, '2024-06-14', 'purchase', 20.77);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (16, '16', '23', 'card', '16', '2025-01-15', 'purchase', 12.84);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (17, '17', '40', 'accountbalance', null, '2024-12-03', 'purchase', 37.49);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (18, '18', '32', 'accountbalance', null, '2024-04-14', 'purchase', 76.36);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (19, '19', '39', 'accountbalance', null, '2024-09-09', 'purchase', 9.46);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (20, '20', '4', 'accountbalance', null, '2024-09-24', 'purchase', 2.99);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (21, '21', '28', 'accountbalance', null, '2024-05-10', 'purchase', 0.0);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (22, '22', '5', 'card', '22', '2024-10-10', 'balancereload', 51.63);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (23, '23', '1', 'accountbalance', null, '2024-05-31', 'purchase', 29.59);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (24, '24', '24', 'card', '24', '2024-06-11', 'balancereload', 18.72);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (25, '25', '11', 'accountbalance', null, '2024-04-14', 'purchase', 40);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (26, '26', '37', 'card', '26', '2024-09-20', 'purchase', 82.08);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (27, '27', '13', 'card', '27', '2024-07-17', 'purchase', 14.17);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (28, '28', '19', 'accountbalance', null, '2025-02-03', 'purchase', 97.34);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (29, '29', '12', 'card', '29', '2024-08-27', 'purchase', 0);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (30, '30', '17', 'card', '30', '2025-01-02', 'purchase', 57.14);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (31, '31', '36', 'accountbalance', null, '2024-09-28', 'purchase', 0.17);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (32, '32', '8', 'accountbalance', null, '2024-06-19', 'purchase', 20);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (33, '33', '7', 'accountbalance', null, '2024-05-23', 'purchase', 109.99);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (34, '34', '20', 'accountbalance', null, '2024-08-05', 'purchase', 79.99);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (35, '35', '15', 'accountbalance', null, '2025-03-08', 'purchase', 24.99);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (36, '36', '9', 'card', '36', '2024-05-20', 'balancereload', 6.34);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (37, '37', '30', 'card', '37', '2024-12-26', 'balancereload', 44.22);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (38, '38', '29', 'accountbalance', null, '2024-04-16', 'purchase', 83.76);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (39, '39', '18', 'accountbalance', null, '2024-07-23', 'purchase', 97.3);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (40, '40', '35', 'accountbalance', null, '2024-11-01', 'purchase', 19.19);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (41, '1', '5', 'accountbalance', null, '2025-04-05', 'purchase', 19.19);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (42, '1', '7', 'accountbalance', null, '2025-04-06', 'purchase', 10.0);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (43, '1', '5', 'accountbalance', null, '2025-04-06', 'purchase', 10.0);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (501, 101, 1, 'card', NULL, '2025-04-05 09:00:00', 'Product', 4.50);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (502, 102, 1, 'card', NULL, '2025-04-10 14:30:00', 'Product', 4.50);
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, TransactionDate, TransactionType, AmountPaid) VALUES (503, 101, 1, 'card', NULL, '2025-04-15 08:15:00', 'Product', 4.50);


-- MenuItems
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (1, '1', 'nulla nisl', 2.2, 'Quisque id justo sit amet sapien dignissim vestibulum.', 'Merchandise', true, false);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (2, '2', 'cubilia curae donec', 1.33, 'Morbi ut odio.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (3, '3', 'metus', 5.36, 'Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante.', 'Beverage', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (4, '4', 'vestibulum aliquet ultrices', 3.79, 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla.', 'Food', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (5, '5', 'libero convallis', 4.31, 'Aliquam erat volutpat.', 'Beverage', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (6, '6', 'sem mauris', 9.38, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi.', 'Food', true, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (7, '7', 'quisque porta', 3.55, 'Aliquam non mauris.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (8, '8', 'justo etiam pretium', 4.45, 'Nam nulla.', 'Merchandise', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (9, '9', 'pretium', 7.41, 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', 'Food', true, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (10, '10', 'quisque erat', 7.61, 'Proin risus.', 'Merchandise', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (11, '11', 'ligula sit amet', 8.07, 'Duis aliquam convallis nunc.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (12, '12', 'pharetra', 4.13, 'Duis consequat dui nec nisi volutpat eleifend.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (13, '13', 'erat vestibulum sed', 1.94, 'Etiam justo.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (14, '14', 'posuere', 3.9, 'In eleifend quam a odio.', 'Beverage', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (15, '15', 'luctus ultricies', 5.36, 'In quis justo.', 'Beverage', true, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (16, '16', 'vestibulum velit id', 7.92, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam.', 'Merchandise', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (17, '17', 'in eleifend', 4.08, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam.', 'Packaged', true, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (18, '18', 'ligula sit', 1.18, 'Cras non velit nec nisi vulputate nonummy.', 'Food', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (19, '19', 'felis ut', 4.6, 'Integer ac leo.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (20, '20', 'eu', 4.26, 'Suspendisse accumsan tortor quis turpis.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (21, '21', 'proin', 1.21, 'Suspendisse accumsan tortor quis turpis.', 'Food', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (22, '22', 'lectus aliquam sit', 2.56, 'Duis bibendum.', 'Food', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (23, '23', 'quam', 8.92, 'Proin eu mi.', 'Merchandise', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (24, '24', 'in porttitor', 8.16, 'Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante.', 'Beverage', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (25, '25', 'fusce congue diam', 4.89, 'Aenean fermentum.', 'Merchandise', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (26, '26', 'metus arcu adipiscing', 4.83, 'Vivamus vel nulla eget eros elementum pellentesque.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (27, '27', 'aliquet', 4.4, 'In est risus, auctor sed, tristique in, tempus sit amet, sem.', 'Beverage', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (28, '28', 'ante', 4.08, 'Integer ac leo.', 'Food', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (29, '29', 'velit', 3.21, 'Duis consequat dui nec nisi volutpat eleifend.', 'Beverage', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (30, '30', 'nulla eget', 9.67, 'Cras non velit nec nisi vulputate nonummy.', 'Merchandise', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (31, '31', 'eleifend', 1.47, 'Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (32, '32', 'faucibus cursus', 7.75, 'Donec ut dolor.', 'Beverage', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (33, '33', 'ornare', 7.82, 'Integer ac leo.', 'Beverage', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (34, '34', 'vel', 8.18, 'Nulla ut erat id mauris vulputate elementum.', 'Food', true, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (35, '35', 'dui maecenas tristique', 3.3, 'Praesent blandit lacinia erat.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (36, '36', 'aliquam quis', 8.5, 'Pellentesque eget nunc.', 'Merchandise', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (37, '37', 'auctor gravida sem', 2.79, 'Nulla mollis molestie lorem.', 'Merchandise', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (38, '38', 'sit', 4.57, 'Nunc rhoncus dui vel sem.', 'Beverage', true, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (39, '39', 'in porttitor pede', 1.22, 'Nullam porttitor lacus at turpis.', 'Packaged', false, false);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (40, '40', 'metus aenean', 6.77, 'Nulla tempus.', 'Beverage', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (41, '1', 'faucibus', 3.8, 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa.', 'Merchandise', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (42, '2', 'non ligula', 1.61, 'Morbi porttitor lorem id ligula.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (43, '3', 'tincidunt ante vel', 9.75, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (44, '4', 'consectetuer eget rutrum', 4.63, 'Duis mattis egestas metus.', 'Merchandise', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (45, '5', 'interdum venenatis turpis', 2.49, 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla.', 'Beverage', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (46, '6', 'ante', 9.73, 'Nulla ut erat id mauris vulputate elementum.', 'Beverage', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (47, '7', 'vestibulum', 6.11, 'Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', 'Merchandise', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (48, '8', 'vulputate elementum nullam', 7.66, 'Integer non velit.', 'Merchandise', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (49, '9', 'mauris sit amet', 7.96, 'Vestibulum rutrum rutrum neque.', 'Food', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (50, '10', 'sed ante', 9.55, 'Nulla tempus.', 'Food', true, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (51, '11', 'fusce lacus purus', 9.94, 'Aenean lectus.', 'Beverage', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (52, '12', 'quisque porta', 9.79, 'Donec semper sapien a libero.', 'Beverage', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (53, '13', 'vestibulum', 1.7, 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa.', 'Merchandise', false, false);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (54, '14', 'sollicitudin vitae consectetuer', 3.37, 'In hac habitasse platea dictumst.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (55, '15', 'vel', 1.0, 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (56, '16', 'nulla sed accumsan', 6.61, 'In sagittis dui vel nisl.', 'Food', true, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (57, '17', 'non pretium quis', 1.97, 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (58, '18', 'fermentum justo nec', 3.58, 'Pellentesque viverra pede ac diam.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (59, '19', 'eros elementum pellentesque', 5.19, 'Duis bibendum.', 'Packaged', false, false);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (60, '20', 'eget massa tempor', 5.65, 'Cras in purus eu magna vulputate luctus.', 'Merchandise', true, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (61, '21', 'ut at dolor', 9.65, 'Cras pellentesque volutpat dui.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (62, '22', 'lacinia aenean', 4.4, 'Pellentesque at nulla.', 'Beverage', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (63, '23', 'in purus eu', 4.0, 'Vestibulum ac est lacinia nisi venenatis tristique.', 'Beverage', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (64, '24', 'tempor turpis nec', 9.47, 'Vivamus tortor.', 'Food', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (65, '25', 'luctus nec', 9.78, 'In hac habitasse platea dictumst.', 'Packaged', false, false);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (66, '26', 'nunc nisl', 4.87, 'Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante.', 'Beverage', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (67, '27', 'justo etiam', 2.75, 'Morbi vel lectus in quam fringilla rhoncus.', 'Food', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (68, '28', 'neque', 8.32, 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante.', 'Food', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (69, '29', 'enim blandit', 3.56, 'Ut tellus.', 'Beverage', true, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (70, '30', 'augue', 9.65, 'Aenean auctor gravida sem.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (71, '31', 'sem sed sagittis', 8.0, 'Curabitur gravida nisi at nibh.', 'Beverage', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (72, '32', 'metus aenean', 9.08, 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (73, '33', 'aliquet pulvinar', 1.14, 'Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 'Merchandise', false, false);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (74, '34', 'malesuada in imperdiet', 5.5, 'Maecenas rhoncus aliquam lacus.', 'Beverage', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (75, '35', 'vulputate', 8.81, 'Mauris ullamcorper purus sit amet nulla.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (76, '36', 'commodo', 4.93, 'Vivamus vel nulla eget eros elementum pellentesque.', 'Beverage', true, false);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (77, '37', 'leo', 9.11, 'Nunc rhoncus dui vel sem.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (78, '38', 'ultrices mattis', 3.45, 'In est risus, auctor sed, tristique in, tempus sit amet, sem.', 'Merchandise', true, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (79, '39', 'amet', 5.3, 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (80, '40', 'odio justo', 9.64, 'Maecenas ut massa quis augue luctus tincidunt.', 'Packaged', false, true);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (501, 1, 'Vanilla Cold Brew', 4.25, 'Smooth vanilla-infused cold brew coffee', 'Drink', TRUE, TRUE);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (502, 1, 'Choco Muffin', 3.00, 'Chocolate chip muffin baked fresh daily', 'Food', FALSE, TRUE);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (503, 1, 'Matcha Latte', 5.00, 'Japanese matcha with steamed milk', 'Drink', TRUE, TRUE);
INSERT INTO MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) VALUES (504, 1, 'Avocado Toast', 6.50, 'Sourdough topped with smashed avocado', 'Food', FALSE, TRUE);

-- RewardItems
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (1, '19', '1', '2025-01-13', '2029-10-12');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (2, '25', '2', '2023-12-15', '2085-12-10');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (3, '50', '3', '2024-04-12', '2038-06-15');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (4, '45', '4', '2023-01-24', '2092-09-27');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (5, '30', '5', '2024-01-01', '2071-04-07');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (6, '12', '6', '2024-04-24', '2059-10-25');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (7, '67', '7', '2024-04-21', '2053-10-28');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (8, '56', '8', '2023-04-18', '2029-03-23');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (9, '61', '9', '2023-06-02', '2087-10-06');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (10, '36', '10', '2023-09-20', '2026-12-02');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (11, '46', '11', '2024-11-08', '2057-07-20');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (12, '16', '12', '2023-07-10', '2068-07-16');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (13, '5', '13', '2023-04-15', '2035-01-07');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (14, '10', '14', '2023-12-03', '2104-11-01');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (15, '39', '15', '2024-06-01', '2095-06-27');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (16, '44', '16', '2025-03-10', '2047-07-05');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (17, '35', '17', '2023-01-21', '2044-02-23');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (18, '17', '18', '2023-10-19', '2063-03-14');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (19, '76', '19', '2024-03-08', '2086-03-31');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (20, '31', '20', '2023-05-22', '2051-12-22');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (21, '28', '21', '2024-10-16', '2104-10-27');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (22, '4', '22', '2024-11-12', '2058-09-27');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (23, '48', '23', '2023-07-25', '2091-07-10');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (24, '70', '24', '2024-04-18', '2041-06-10');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (25, '27', '25', '2024-08-24', '2105-05-01');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (26, '60', '26', '2023-09-20', '2084-05-21');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (27, '66', '27', '2024-05-28', '2037-06-05');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (28, '54', '28', '2024-05-20', '2072-04-23');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (29, '43', '29', '2025-03-06', '2091-06-17');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (30, '1', '30', '2024-07-14', '2048-04-05');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (31, '72', '31', '2024-05-26', '2031-11-11');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (32, '77', '32', '2024-02-12', '2081-03-13');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (33, '21', '33', '2023-02-18', '2083-08-23');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (34, '32', '34', '2025-01-07', '2097-02-27');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (35, '57', '35', '2024-03-10', '2096-07-05');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (36, '53', '36', '2024-01-12', '2037-09-26');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (37, '65', '37', '2024-09-30', '2106-01-23');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (38, '7', '38', '2023-10-03', '2095-06-05');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (39, '80', '39', '2025-01-02', '2084-02-15');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (40, '52', '40', '2025-03-26', '2060-10-08');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (41, '3', '1', '2023-02-16', '2070-11-25');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (42, '26', '2', '2025-02-21', '2085-06-16');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (43, '38', '3', '2023-11-15', '2059-12-27');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (44, '63', '4', '2025-04-04', '2088-11-11');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (45, '51', '5', '2025-04-04', '2044-07-30');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (46, '41', '6', '2024-05-10', '2031-11-16');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (47, '59', '7', '2025-04-02', '2087-03-01');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (48, '68', '8', '2024-03-04', '2039-06-07');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (49, '29', '9', '2024-01-09', '2031-09-09');
INSERT INTO RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) VALUES (50, '69', '10', '2023-04-05', '2077-02-03');
INSERT INTO RewardItems (RewardID, MerchantID, ItemID, StartDate, EndDate) VALUES (501, 1, 501, '2025-04-01', '2025-05-01');
INSERT INTO RewardItems (RewardID, MerchantID, ItemID, StartDate, EndDate) VALUES (502, 1, 503, '2025-04-01', '2025-05-01');

-- Order Details
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (1, '6', '14', 73.34, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (2, '33', '7', 100.99, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (3, '9', '25', 10.00, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (4, '18', '32', 15.99, true, 15.99);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (5, '32', '8', 88.62, true, 88.62);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (6, '5', '27', 10.00, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (7, '33', '47', 9.00, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (8, '25', '11', 47.11, true, 47.11);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (9, '18', '32', 22.99, true, 22.99);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (10, '5', '67', 24.31, true, 24.31);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (11, '38', '29', 83.76, true, 83.76);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (12, '25', '51', 40.00, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (13, '7', '22', 10.00, true, 10.00);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (14, '17', '40', 37.94, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (15, '19', '39', 9.46, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (16, '20', '4', 2.99, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (17, '9', '65', 3.35, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (18, '31', '36', 0.10, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (19, '21', '28', 16.4, true, 16.4);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (20, '3', '6', 20.06, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (21, '11', '33', 40, true, 40);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (22, '9', '25', 5, true, 5);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (23, '34', '20', 70.99, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (24, '4', '50', 40.00, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (25, '4', '10', 48.3, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (26, '28', '19', 97.34, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (27, '18', '72', 76.36, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (28, '28', '19', 5.49, true, 5.49);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (29, '17', '80', 24.99, true, 24.99);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (30, '16', '23', 3.99, true, 3.99);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (31, '14', '26', 77.84, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (32, '34', '20', 39.99, true, 39.99);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (33, '20', '44', 24.87, true, 24.87);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (34, '39', '18', 97.3, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (35, '21', '28', 8.49, true, 8.49);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (36, '16', '63', 12.84, true, 12.84);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (37, '34', '60', 78.75, true, 78.75);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (38, '32', '48', 20, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (39, '15', '31', 10.77, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (40, '26', '37', 42.08, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (41, '40', '35', 19.19, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (42, '12', '3', 47.19, true, 47.19);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (43, '13', '16', 89.99, true, 89.99);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (44, '13', '56', 43.91, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (45, '23', '1', 19.59, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (46, '34', '20', 9.00, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (47, '11', '73', 55.1, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (48, '12', '3', 5.49, true, 5.49);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (49, '29', '12', 42.51, true, 42.51);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (50, '23', '1', 10.00, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (51, '15', '31', 10.00, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (52, '26', '37', 40.00, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (53, '30', '17', 4.29, true, 4.29);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (54, '30', '57', 57.14, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (55, '2', '2', 19.99, true, 19.99);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (56, '35', '15', 34.99, true, 34.99);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (57, '2', '21', 3.29, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (58, '35', '15', 20.00, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (59, '35', '45', 4.00, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (60, '10', '38', 20.00, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (61, '27', '13', 14.17, true, 14.17);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (62, '1', '2', 40.94, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (63, '35', '15', 0.99, false, 0.0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (64, '3', '6', 20.00, true, 20.00);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (65, '33', '7', 90.87, true, 90.87);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (66, '7', '22', 28.91, true, 28.91);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (67, '35', '15', 9.14, true, 9.14);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (68, '1', '42', 40.00, true, 40.00);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (69, '10', '78', 26.62, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (70, '31', '76', 0.07, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (1, '41', '5', 19, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (2, '41', '45', 0.19, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (1, '42', '7', 5, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (2, '42', '7', 5, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionId, ItemId, Price, RewardRedeemed, Discount) VALUES (2, '43', '5', 10, false, 0);
INSERT INTO OrderDetails (OrderItemNum, TransactionID, ItemID, Price, RewardRedeemed, Discount) VALUES (1, 501, 501, 4.50, TRUE, 0.00);
INSERT INTO OrderDetails (OrderItemNum, TransactionID, ItemID, Price, RewardRedeemed, Discount) VALUES (1, 502, 501, 4.50, TRUE, 0.00);
INSERT INTO OrderDetails (OrderItemNum, TransactionID, ItemID, Price, RewardRedeemed, Discount) VALUES (1, 503, 501, 4.50, TRUE, 0.00);

-- ComplaintTickets
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (1, '32', '44', '2023-01-26', 'Order Delay', 'Order took longer than expected to arrive', 'In Progress', 'High');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (2, '10', '22', '2024-07-31', 'App Crash', 'App stopped working during use', 'Resolved', 'Critical');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (3, '19', '33', '2024-10-22', 'Wrong Order', 'Received incorrect item', 'Escalated', 'Urgent');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (4, '16', '47', '2023-03-01', 'Payment Issue', 'Problem occurred while processing payment', 'Closed', 'Low');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (5, '11', '62', '2023-12-25', 'Missing Items', 'Some items were missing from the order', 'Escalated', 'Medium');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (6, '6', '50', '2024-12-13', 'Order Delay', 'Order took longer than expected to arrive', 'Closed', 'Critical');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (7, '21', '20', '2024-06-16', 'App Crash', 'App stopped working during use', 'Escalated', 'High');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (8, '20', '58', '2023-07-08', 'Wrong Order', 'Received incorrect item', 'Escalated', 'Low');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (9, '8', '69', '2023-08-16', 'Payment Issue', 'Problem occurred while processing payment', 'Resolved', 'Medium');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (10, '4', '78', '2023-08-01', 'Missing Items', 'Some items were missing from the order', 'Open', 'Urgent');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (11, '5', '43', '2023-03-07', 'Order Delay', 'Order took longer than expected to arrive', 'Closed', 'Urgent');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (12, '14', '49', '2025-03-16', 'App Crash', 'App stopped working during use', 'Open', 'Critical');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (13, '38', '7', '2024-01-14', 'Wrong Order', 'Received incorrect item', 'Open', 'Urgent');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (14, '1', '15', '2024-02-15', 'Payment Issue', 'Problem occurred while processing payment', 'Escalated', 'Urgent');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (15, '36', '17', '2024-08-04', 'Missing Items', 'Some items were missing from the order', 'Resolved', 'Medium');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (16, '40', '55', '2023-10-23', 'Order Delay', 'Order took longer than expected to arrive', 'In Progress', 'Medium');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (17, '17', '60', '2024-11-30', 'App Crash', 'App stopped working during use', 'In Progress', 'Critical');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (18, '22', '65', '2024-02-01', 'Wrong Order', 'Received incorrect item', 'Open', 'Critical');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (19, '13', '2', '2023-07-23', 'Payment Issue', 'Problem occurred while processing payment', 'Resolved', 'Critical');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (20, '35', '13', '2023-10-08', 'Missing Items', 'Some items were missing from the order', 'Open', 'High');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (21, '24', '73', '2023-02-22', 'Order Delay', 'Order took longer than expected to arrive', 'In Progress', 'Medium');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (22, '2', '72', '2025-03-08', 'App Crash', 'App stopped working during use', 'Open', 'Low');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (23, '9', '31', '2023-03-17', 'Wrong Order', 'Received incorrect item', 'In Progress', 'Low');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (24, '3', '37', '2023-01-13', 'Payment Issue', 'Problem occurred while processing payment', 'Escalated', 'Low');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (25, '29', '56', '2024-06-11', 'Missing Items', 'Some items were missing from the order', 'In Progress', 'High');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (26, '34', '68', '2023-11-06', 'Order Delay', 'Order took longer than expected to arrive', 'Open', 'Critical');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (27, '23', '9', '2024-07-01', 'App Crash', 'App stopped working during use', 'Escalated', 'Low');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (28, '31', '59', '2024-02-20', 'Wrong Order', 'Received incorrect item', 'In Progress', 'Low');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (29, '7', '28', '2023-07-04', 'Payment Issue', 'Problem occurred while processing payment', 'Resolved', 'Urgent');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (30, '33', '3', '2025-02-16', 'Missing Items', 'Some items were missing from the order', 'Open', 'Urgent');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (31, '39', '54', '2023-03-07', 'Order Delay', 'Order took longer than expected to arrive', 'Resolved', 'Critical');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (32, '28', '4', '2024-04-24', 'App Crash', 'App stopped working during use', 'Resolved', 'Critical');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (33, '15', '16', '2024-10-13', 'Wrong Order', 'Received incorrect item', 'Open', 'Critical');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (34, '27', '70', '2023-10-22', 'Payment Issue', 'Problem occurred while processing payment', 'Escalated', 'Medium');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (35, '25', '40', '2024-07-05', 'Missing Items', 'Some items were missing from the order', 'Closed', 'Medium');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (36, '37', '74', '2023-11-11', 'Order Delay', 'Order took longer than expected to arrive', 'Open', 'Urgent');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (37, '18', '6', '2023-05-26', 'App Crash', 'App stopped working during use', 'Escalated', 'High');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (38, '30', '21', '2025-01-11', 'Wrong Order', 'Received incorrect item', 'Open', 'Critical');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (39, '26', '1', '2023-05-10', 'Payment Issue', 'Problem occurred while processing payment', 'Open', 'Medium');
INSERT INTO ComplaintTickets (TicketId, CustomerId, AssignedToEmployeeID, CreatedAt, Category, Description, Status, Priority) VALUES (40, '12', '77', '2025-04-11', 'Missing Items', 'Some items were missing from the order', 'Open', 'Urgent');

-- Surveys
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (1, '36', 'What is your least favorite item?', '2023-08-24');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (2, '35', 'Do you feel the pricing is fair?', '2023-07-24');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (3, '24', 'What is your favorite menu item?', '2024-02-29');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (4, '1', 'What is your least favorite item?', '2023-02-15');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (5, '53', 'Have you used the CafeCoin rewards?', '2023-03-10');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (6, '80', 'How would you rate the value for your money?', '2023-01-26');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (7, '66', 'Any additional comments?', '2024-12-02');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (8, '50', 'What is your favorite menu item?', '2024-06-11');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (9, '52', 'Was the wait time acceptable?', '2024-06-15');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (10, '75', 'Are you satisfied with the loyalty program?', '2023-04-06');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (11, '31', 'How often do you visit this cafe?', '2024-07-27');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (12, '73', 'Do you follow us on social media?', '2023-02-12');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (13, '5', 'Do you order ahead or in-store?', '2024-08-13');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (14, '65', 'How would you rate the ambiance?', '2023-11-21');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (15, '79', 'Was the wait time acceptable?', '2023-12-11');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (16, '77', 'Was your mobile order ready on time?', '2023-02-20');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (17, '63', 'Do you order ahead or in-store?', '2024-05-11');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (18, '9', 'How often do you visit this cafe?', '2024-01-06');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (19, '15', 'Was your order prepared correctly?', '2024-05-25');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (20, '38', 'Was the wait time acceptable?', '2024-04-10');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (21, '46', 'Any additional comments?', '2023-04-22');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (22, '3', 'Any additional comments?', '2024-11-24');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (23, '64', 'Have you used the CafeCoin rewards?', '2024-11-13');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (24, '25', 'Do you find the app easy to use?', '2024-02-13');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (25, '22', 'How satisfied are you with the selection of drinks?', '2023-04-04');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (26, '14', 'Would you like to receive special birthday offers?', '2025-02-25');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (27, '62', 'Do you use digital payments?', '2023-07-30');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (28, '58', 'Would you attend a community coffee tasting?', '2024-11-09');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (29, '49', 'Have you encountered any technical issues with the app?', '2023-05-17');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (30, '19', 'What can we improve?', '2024-10-01');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (31, '10', 'Do you follow us on social media?', '2024-05-09');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (32, '67', 'Do you feel the pricing is fair?', '2023-12-01');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (33, '20', 'Do you feel CafeCoin adds value to your visits?', '2024-02-08');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (34, '60', 'Would you like more gluten-free options?', '2024-03-26');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (35, '11', 'Do you use digital payments?', '2023-01-27');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (36, '2', 'Would you like to see more local events at this cafe?', '2024-10-14');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (37, '40', 'How satisfied are you with your recent purchase?', '2024-10-02');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (38, '71', 'Are our hours of operation convenient?', '2023-05-02');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (39, '74', 'Would you prefer more seasonal items?', '2023-12-13');
INSERT INTO Surveys (SurveyId, CreatedByEmp, Question, DateSent) VALUES (40, '41', 'Is the shop environment comfortable?', '2024-10-21');

-- SurveyResponses
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (1, 35, '12', 'The app is glitchy.', '2024-04-19');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (2, 22, '1', 'This location is always clean.', '2023-04-13');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (3, 14, '15', 'Excellent tea options!', '2025-01-07');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (4, 23, '30', 'This location is always clean.', '2023-11-16');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (5, 9, '32', 'Would love more promotions.', '2023-12-13');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (6, 31, '9', 'This is my go-to cafe.', '2023-04-06');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (7, 16, '27', 'Not user friendly.', '2024-02-04');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (8, 18, '21', 'It''s convenient and easy.', '2025-01-11');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (9, 24, '10', 'Too sweet for me.', '2024-08-18');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (10, 19, '6', 'I like the outdoor seating.', '2025-04-03');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (11, 22, '22', 'I like how fast it was.', '2024-08-12');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (12, 18, '5', 'The app is glitchy.', '2024-04-30');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (13, 11, '16', 'Love the rewards program.', '2025-02-05');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (14, 29, '20', 'Will definitely return!', '2023-03-24');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (15, 15, '28', 'My order was incorrect.', '2023-08-12');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (16, 34, '29', 'Love the new app update!', '2024-03-18');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (17, 3, '35', 'Everything was clean.', '2023-11-01');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (18, 1, '8', 'Too crowded.', '2024-09-02');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (19, 11, '7', 'Would love more promotions.', '2023-09-18');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (20, 30, '36', 'Would love more promotions.', '2023-11-07');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (21, 19, '4', 'More dairy-free milk options would be great.', '2025-04-06');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (22, 21, '14', 'Rewards take too long to earn.', '2023-04-03');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (23, 18, '26', 'It’s always busy here.', '2024-03-26');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (24, 19, '19', 'I didn’t know about the app.', '2023-03-05');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (25, 5, '25', 'Staff was incredibly kind!', '2023-11-21');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (26, 18, '18', 'The app is glitchy.', '2023-04-22');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (27, 21, '3', 'I like the outdoor seating.', '2024-11-21');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (28, 39, '31', 'I couldn’t find parking.', '2025-01-10');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (29, 10, '2', 'Love the rewards program.', '2023-10-30');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (30, 19, '23', 'I like how fast it was.', '2023-05-07');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (31, 12, '17', 'The coffee was perfect.', '2023-03-20');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (32, 10, '39', 'Would love more promotions.', '2024-09-25');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (33, 9, '38', 'The wifi didn’t work.', '2023-05-09');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (34, 30, '11', 'I come here every week.', '2025-02-06');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (35, 37, '24', 'Too crowded.', '2023-12-04');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (36, 40, '37', 'I love this place!', '2024-07-23');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (37, 25, '40', 'Didn’t get my receipt.', '2025-02-02');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (38, 11, '33', 'Excellent tea options!', '2023-04-29');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (39, 1, '13', 'Keep up the great work!', '2024-06-11');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (40, 28, '34', 'I prefer another shop nearby.', '2023-07-28');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (41, 17, '19', 'This is my go-to cafe.', '2023-01-25');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (42, 33, '35', 'I had to wait too long.', '2025-02-23');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (43, 2, '1', 'It’s always busy here.', '2024-07-17');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (44, 27, '24', 'Not enough seating.', '2024-03-23');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (45, 33, '9', 'Not enough seating.', '2025-02-24');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (46, 1, '4', 'I got my order quickly.', '2023-03-27');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (47, 11, '13', 'Perfect spot to study.', '2023-09-12');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (48, 37, '34', 'Too sweet for me.', '2024-01-25');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (49, 6, '7', 'Not enough seating.', '2024-07-22');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (50, 28, '30', 'Not enough seating.', '2024-09-17');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (51, 30, '21', 'I prefer another shop nearby.', '2025-02-11');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (52, 18, '31', 'Music was too loud.', '2024-05-13');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (53, 29, '36', 'It’s overpriced.', '2023-12-04');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (54, 21, '23', 'The wifi didn’t work.', '2023-11-09');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (55, 5, '25', 'Will definitely return!', '2024-03-07');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (56, 24, '40', 'Love the latte art!', '2024-02-19');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (57, 34, '28', 'It feels overpriced.', '2024-05-27');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (58, 14, '20', 'Didn’t get my receipt.', '2024-04-10');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (59, 27, '12', 'I would recommend it.', '2023-03-29');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (60, 17, '33', 'Not user friendly.', '2023-10-14');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (61, 6, '37', 'Will definitely return!', '2024-03-04');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (62, 34, '16', 'I’m not sure I’d return.', '2023-07-14');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (63, 31, '29', 'Rewards take too long to earn.', '2024-08-04');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (64, 24, '18', 'It’s always busy here.', '2023-12-18');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (65, 27, '22', 'I come here every week.', '2023-07-11');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (66, 16, '6', 'It’s overpriced.', '2024-09-22');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (67, 31, '10', 'The app is glitchy.', '2024-07-27');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (68, 34, '2', 'I got my order quickly.', '2024-01-22');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (69, 10, '14', 'This is my go-to cafe.', '2024-07-23');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (70, 1, '38', 'Service was slow.', '2024-12-04');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (71, 34, '17', 'Keep up the great work!', '2023-04-18');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (72, 7, '32', 'Love the new app update!', '2023-03-30');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (73, 9, '5', 'Payment process was smooth.', '2025-01-08');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (74, 2, '11', 'Payment process was smooth.', '2024-05-23');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (75, 27, '3', 'My order was incorrect.', '2024-12-29');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (76, 10, '27', 'I didn’t know about the app.', '2025-03-11');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (77, 9, '15', 'Keep up the great work!', '2023-08-02');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (78, 12, '39', 'I prefer another shop nearby.', '2025-01-24');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (79, 19, '8', 'Excellent tea options!', '2023-12-08');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (80, 27, '26', 'I love the seasonal drinks.', '2024-11-02');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (81, 25, '39', 'It’s overpriced.', '2023-04-14');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (82, 18, '17', 'I love the seasonal drinks.', '2025-04-04');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (83, 7, '31', 'More plant-based options please.', '2024-01-01');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (84, 30, '4', 'Love the community feel here.', '2023-12-10');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (85, 27, '12', 'Love the new app update!', '2023-02-05');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (86, 30, '5', 'Rewards take too long to earn.', '2023-11-25');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (87, 36, '38', 'It''s convenient and easy.', '2023-05-31');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (88, 39, '40', 'Everything was great!', '2023-10-14');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (89, 3, '35', 'Staff was incredibly kind!', '2023-07-29');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (90, 24, '32', 'Didn’t get my receipt.', '2023-02-03');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (91, 33, '15', 'Love the cozy vibe.', '2025-02-20');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (92, 13, '10', 'Please bring back the old menu.', '2023-02-25');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (93, 22, '14', 'I didn’t enjoy the latte.', '2024-10-13');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (94, 37, '2', 'Very cozy environment.', '2023-09-28');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (95, 39, '22', 'App crashed during checkout.', '2024-02-14');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (96, 12, '30', 'Will definitely return!', '2023-05-09');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (97, 7, '28', 'I love the seasonal drinks.', '2024-11-07');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (98, 38, '33', 'Please expand the vegan menu.', '2024-07-12');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (99, 12, '7', 'Too sweet for me.', '2023-12-13');
INSERT INTO SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) VALUES (100, 17, '29', 'Not user friendly.', '2024-11-27');

-- CustomerComms
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (1, '1', 'Promo', 'Limited-time offer or sale', '2024-08-13');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (2, '2', 'Update', 'Business or app changes', '2024-04-21');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (3, '3', 'Event', 'Upcoming in-store or virtual event', '2023-02-14');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (4, '4', 'Reminder', 'Friendly nudge for action', '2023-10-24');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (5, '5', 'Survey', 'Request for customer feedback', '2023-02-26');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (6, '6', 'Alert', 'Important or urgent notice', '2023-05-30');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (7, '7', 'Newsletter', 'Regular info and tips', '2023-01-28');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (8, '8', 'Discount', 'Price cut or special deal', '2023-12-15');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (9, '9', 'Thank You', 'Appreciation message', '2024-10-15');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (10, '10', 'Feature Launch', 'New feature or product release', '2024-04-11');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (11, '11', 'Promo', 'Limited-time offer or sale', '2024-05-12');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (12, '12', 'Update', 'Business or app changes', '2023-01-07');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (13, '13', 'Event', 'Upcoming in-store or virtual event', '2024-01-22');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (14, '14', 'Reminder', 'Friendly nudge for action', '2024-11-23');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (15, '15', 'Survey', 'Request for customer feedback', '2023-10-11');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (16, '16', 'Alert', 'Important or urgent notice', '2024-08-08');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (17, '17', 'Newsletter', 'Regular info and tips', '2023-07-12');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (18, '18', 'Discount', 'Price cut or special deal', '2024-07-25');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (19, '19', 'Thank You', 'Appreciation message', '2024-12-13');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (20, '20', 'Feature Launch', 'New feature or product release', '2023-05-07');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (21, '21', 'Promo', 'Limited-time offer or sale', '2023-08-22');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (22, '22', 'Update', 'Business or app changes', '2024-10-30');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (23, '23', 'Event', 'Upcoming in-store or virtual event', '2024-03-10');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (24, '24', 'Reminder', 'Friendly nudge for action', '2024-03-04');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (25, '25', 'Survey', 'Request for customer feedback', '2024-01-03');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (26, '26', 'Alert', 'Important or urgent notice', '2024-04-09');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (27, '27', 'Newsletter', 'Regular info and tips', '2023-11-08');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (28, '28', 'Discount', 'Price cut or special deal', '2024-12-26');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (29, '29', 'Thank You', 'Appreciation message', '2025-02-03');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (30, '30', 'Feature Launch', 'New feature or product release', '2023-08-13');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (31, '31', 'Promo', 'Limited-time offer or sale', '2025-01-31');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (32, '32', 'Update', 'Business or app changes', '2023-09-26');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (33, '33', 'Event', 'Upcoming in-store or virtual event', '2023-03-14');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (34, '34', 'Reminder', 'Friendly nudge for action', '2024-11-25');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (35, '35', 'Survey', 'Request for customer feedback', '2024-10-27');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (36, '36', 'Alert', 'Important or urgent notice', '2023-02-26');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (37, '37', 'Newsletter', 'Regular info and tips', '2025-04-03');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (38, '38', 'Discount', 'Price cut or special deal', '2024-01-17');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (39, '39', 'Thank You', 'Appreciation message', '2024-09-11');
INSERT INTO CustomerComms (PromoId, MerchantId, Type, Content, DateSent) VALUES (40, '40', 'Feature Launch', 'New feature or product release', '2023-03-11');

-- CommsSubscribers
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('37', '8', '2025-04-01');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('7', '30', '2024-03-22');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('40', '38', '2023-07-11');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('9', '15', '2023-02-27');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('2', '6', '2025-03-01');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('12', '2', '2024-11-14');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('6', '10', '2025-03-27');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('21', '23', '2023-08-21');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('5', '1', '2025-04-11');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('35', '11', '2024-09-02');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('15', '35', '2024-03-25');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('10', '5', '2024-04-02');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('3', '37', '2023-12-20');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('34', '4', '2025-01-23');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('38', '33', '2024-01-18');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('28', '16', '2023-09-08');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('8', '22', '2025-03-18');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('25', '12', '2023-05-14');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('14', '40', '2025-03-05');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('24', '25', '2024-10-22');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('11', '36', '2023-11-03');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('30', '18', '2024-09-18');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('27', '14', '2024-04-27');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('39', '34', '2023-04-30');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('29', '32', '2023-10-05');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('31', '19', '2025-01-03');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('16', '31', '2023-08-18');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('33', '24', '2024-05-29');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('4', '29', '2023-02-22');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('17', '3', '2023-10-18');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('13', '39', '2025-02-18');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('23', '27', '2023-02-10');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('32', '21', '2023-06-28');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('20', '28', '2024-08-02');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('22', '20', '2023-12-16');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('36', '26', '2024-07-30');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('19', '13', '2023-08-12');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('1', '9', '2023-08-07');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('18', '7', '2024-12-30');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('26', '17', '2023-08-08');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('22', '7', '2024-11-23');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('18', '36', '2024-06-08');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('28', '30', '2023-07-02');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('27', '13', '2024-09-27');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('39', '10', '2024-08-12');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('37', '24', '2025-01-17');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('14', '23', '2024-11-29');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('12', '16', '2023-08-29');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('35', '12', '2024-06-14');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('15', '40', '2023-04-06');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('19', '32', '2025-03-11');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('25', '4', '2024-02-15');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('32', '33', '2023-08-22');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('38', '29', '2025-02-20');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('4', '26', '2024-06-29');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('36', '28', '2024-08-19');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('21', '8', '2023-06-17');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('2', '1', '2023-04-10');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('34', '25', '2024-11-06');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('7', '31', '2023-12-21');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('6', '3', '2024-12-04');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('33', '18', '2024-04-26');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('16', '37', '2024-04-03');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('8', '9', '2024-06-03');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('29', '20', '2023-12-15');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('20', '27', '2024-12-25');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('3', '11', '2023-04-09');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('9', '39', '2024-06-03');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('23', '38', '2024-08-20');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('11', '14', '2023-08-24');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('5', '5', '2023-09-27');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('40', '22', '2023-05-09');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('30', '15', '2024-02-24');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('1', '2', '2024-11-03');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('17', '35', '2023-09-16');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('31', '40', '2024-02-03');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('24', '34', '2023-05-28');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('13', '6', '2024-11-29');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('26', '21', '2024-12-07');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('10', '17', '2025-03-07');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('19', '10', '2023-11-23');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('16', '6', '2023-03-02');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('28', '31', '2023-02-03');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('35', '32', '2025-02-15');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('4', '36', '2024-04-02');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('30', '39', '2024-04-13');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('39', '7', '2025-02-16');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('15', '29', '2024-04-22');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('23', '16', '2023-07-12');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('1', '34', '2023-06-08');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('10', '30', '2025-01-06');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('24', '3', '2024-01-27');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('34', '21', '2024-07-31');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('5', '33', '2023-04-17');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('32', '37', '2025-01-18');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('8', '23', '2024-03-08');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('26', '35', '2024-03-27');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('20', '11', '2023-12-30');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('11', '28', '2024-12-04');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('27', '22', '2024-10-14');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('29', '40', '2023-09-29');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('2', '4', '2024-04-06');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('6', '27', '2024-05-10');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('9', '19', '2024-01-04');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('40', '17', '2024-02-12');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('14', '1', '2025-01-11');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('12', '14', '2023-02-18');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('13', '20', '2023-05-07');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('25', '18', '2024-05-17');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('7', '13', '2024-12-05');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('22', '15', '2024-08-24');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('38', '9', '2023-09-16');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('31', '24', '2023-01-03');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('37', '5', '2024-03-29');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('33', '2', '2023-08-10');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('17', '26', '2024-08-25');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('36', '38', '2024-11-22');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('18', '25', '2024-09-04');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('21', '40', '2023-06-27');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('3', '12', '2023-04-10');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('6', '20', '2023-07-13');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('19', '34', '2024-06-18');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('18', '15', '2024-12-31');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('4', '18', '2023-02-28');
INSERT INTO CommsSubscribers (CustomerId, MerchantId, DateSubscribed) VALUES ('15', '23', '2023-07-05');

-- Leads
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (1, '23', 'Voolia', 'Lorrayne', 'Habberjam', 'lhabberjam0@blogs.com', '336-834-1151', '972 Fairview Circle', 'berkeley.edu/massa/quis.html', 'In Review', 'Forwarded deck', '2023-10-04', 42, 'Greensboro', 'North Carolina', 35820);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (2, '11', 'Wikizz', 'Yuri', 'Olennikov', 'yolennikov1@360.cn', '915-926-6576', '5488 Dawn Avenue', 'tinyurl.com/venenatis/tristique.jsp', 'Closed Lost', 'Interested in joining', '2023-09-16', 52, 'El Paso', 'Texas', 67294);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (3, '52', 'Lajo', 'Costanza', 'Yaneev', 'cyaneev2@springer.com', '719-675-6691', '7 Fremont Avenue', 'go.com/primis/in/faucibus/orci.html', 'New', 'Not the right time', '2024-08-20', 58, 'Colorado Springs', 'Colorado', 66356);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (4, '7', 'Oyoyo', 'Ferdinand', 'Hulk', 'fhulk3@barnesandnoble.com', '865-649-0953', '0 Ramsey Alley', 'buzzfeed.com/et/eros/vestibulum/ac/est/lacinia/nisi.jpg', 'New', 'Introduced to second decision-maker', '2023-11-14', 57, 'Knoxville', 'Tennessee', 87302);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (5, '27', 'Yodo', 'Honoria', 'Knolles-Green', 'hknollesgreen4@dmoz.org', '305-429-0646', '10 Del Sol Place', 'moonfruit.com/lectus.json', 'In Review', 'Needs Q2 launch', '2024-07-23', 64, 'Hialeah', 'Florida', 79802);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (6, '63', 'Devpulse', 'Rosalinda', 'McAvey', 'rmcavey5@multiply.com', '913-746-5763', '9 Everett Pass', 'independent.co.uk/massa/volutpat/convallis/morbi/odio/odio/elementum.json', 'Closed Won', 'Forwarded deck', '2024-04-02', 77, 'Shawnee Mission', 'Kansas', 29298);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (7, '26', 'Tazz', 'Ahmad', 'Hill', 'ahill6@usatoday.com', '304-103-1395', '3036 Crest Line Plaza', 'addthis.com/vulputate/nonummy/maecenas/tincidunt/lacus.jsp', 'Closed Lost', 'Sent intro email', '2024-11-11', 41, 'Charleston', 'West Virginia', 24089);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (8, '41', 'Bubblebox', 'Avrom', 'Matuszinski', 'amatuszinski7@npr.org', '432-251-6722', '75 Derek Park', 'over-blog.com/turpis/donec/posuere/metus/vitae.html', 'Contacted', 'Wants more examples', '2023-10-07', 100, 'Midland', 'Texas', 17201);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (9, '61', 'Realbuzz', 'Lorie', 'Daffey', 'ldaffey8@miibeian.gov.cn', '602-773-0257', '513 Gateway Pass', 'ihg.com/donec.html', 'In Review', 'Scheduled follow-up call', '2024-04-23', 23, 'Glendale', 'Arizona', 77589);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (10, '62', 'Fanoodle', 'Parnell', 'Bellew', 'pbellew9@yandex.ru', '571-193-3141', '99673 Laurel Alley', 'wp.com/amet/lobortis.html', 'In Review', 'Interested in free trial', '2025-02-19', 54, 'Alexandria', 'Virginia', 35585);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (11, '70', 'Demimbu', 'Cobb', 'Jacob', 'cjacoba@1688.com', '757-442-7948', '14 Riverside Alley', 'harvard.edu/erat/curabitur/gravida.aspx', 'Negotiating', 'Circle back next quarter', '2023-08-27', 59, 'Norfolk', 'Virginia', 31513);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (12, '66', 'Kamba', 'Emmeline', 'Cotelard', 'ecotelardb@pen.io', '404-304-0148', '53058 Butterfield Terrace', 'cdbaby.com/augue.png', 'Negotiating', 'Interested in joining', '2025-01-22', 3, 'Decatur', 'Georgia', 14779);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (13, '57', 'Topicware', 'Christophe', 'Kenshole', 'ckensholec@state.gov', '318-658-7837', '3 Crest Line Terrace', 'japanpost.jp/mi/pede/malesuada/in.aspx', 'Contacted', 'Opened email no reply', '2023-12-30', 21, 'Monroe', 'Louisiana', 75551);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (14, '35', 'Topicshots', 'Bernie', 'Dolby', 'bdolbyd@nyu.edu', '860-753-9969', '17 Eastwood Road', 'photobucket.com/diam/nam/tristique.aspx', 'Negotiating', 'No answer on call', '2024-06-27', 49, 'Hartford', 'Connecticut', 70335);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (15, '78', 'Mybuzz', 'Magda', 'Wisden', 'mwisdene@home.pl', '260-182-4775', '7029 Di Loreto Terrace', 'github.io/auctor.js', 'In Review', 'Said to reach back next week', '2024-08-02', 10, 'Fort Wayne', 'Indiana', 96055);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (16, '34', 'Lazz', 'Nehemiah', 'Anselm', 'nanselmf@whitehouse.gov', '202-897-2053', '794 Spohn Way', '163.com/ut/nulla/sed/accumsan.png', 'New', 'Shared use case', '2024-02-22', 4, 'Washington', 'District of Columbia', 70064);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (17, '9', 'Leexo', 'Gwendolin', 'Poulsen', 'gpoulseng@plala.or.jp', '804-860-5178', '997 Reinke Circle', 'drupal.org/nulla.aspx', 'Negotiating', 'Scheduled follow-up call', '2024-08-31', 91, 'Richmond', 'Virginia', 15226);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (18, '20', 'Topicstorm', 'Kean', 'Shadwick', 'kshadwickh@illinois.edu', '513-781-1151', '0012 Barnett Way', 'newyorker.com/habitasse/platea/dictumst/etiam/faucibus.png', 'Contacted', 'Asked for technical details', '2023-12-20', 50, 'Cincinnati', 'Ohio', 95541);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (19, '73', 'Roomm', 'Dredi', 'Augur', 'dauguri@trellian.com', '603-255-6759', '2 Kings Plaza', 'aol.com/tellus/nulla/ut/erat/id/mauris.jsp', 'In Review', 'Sent onboarding overview', '2024-12-30', 29, 'Manchester', 'New Hampshire', 55772);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (20, '77', 'Browsetype', 'Ignace', 'Manson', 'imansonj@soundcloud.com', '318-775-5623', '88776 Magdeline Circle', 'gravatar.com/pellentesque/eget/nunc/donec/quis/orci/eget.json', 'Closed Lost', 'Passed along to partner', '2024-04-19', 29, 'Shreveport', 'Louisiana', 87680);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (21, '50', 'Zoomzone', 'Ashlie', 'Mallam', 'amallamk@china.com.cn', '530-792-2342', '356 Scofield Street', 'arizona.edu/orci/mauris/lacinia/sapien/quis/libero/nullam.html', 'Contacted', 'Asked about custom plan', '2024-04-05', 72, 'Sacramento', 'California', 24928);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (22, '30', 'Ailane', 'Marline', 'Buche', 'mbuchel@census.gov', '404-928-4583', '6 Maple Wood Court', 'bbb.org/nisl/nunc/rhoncus.png', 'Negotiating', 'Sent intro email', '2024-08-31', 70, 'Atlanta', 'Georgia', 23679);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (23, '65', 'Feedmix', 'Bernete', 'Lots', 'blotsm@comcast.net', '201-459-4867', '39619 Hoffman Lane', 'apple.com/pulvinar/lobortis/est/phasellus/sit.jsp', 'Closed Lost', 'Needs executive buy-in', '2023-06-10', 82, 'Jersey City', 'New Jersey', 90251);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (24, '79', 'Dablist', 'Rem', 'Fintoph', 'rfintophn@opensource.org', '323-378-5165', '44 Merchant Way', 'princeton.edu/justo/nec/condimentum/neque.jpg', 'New', 'Rescheduled call', '2024-07-14', 39, 'Inglewood', 'California', 80668);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (25, '22', 'Nlounge', 'Ody', 'Pischoff', 'opischoffo@webnode.com', '404-132-1543', '46003 Fulton Avenue', 'stanford.edu/vel/nulla/eget/eros/elementum/pellentesque.aspx', 'Contacted', 'Not the right time', '2023-08-22', 31, 'Alpharetta', 'Georgia', 24904);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (26, '4', 'Gabcube', 'Alwin', 'Bushell', 'abushellp@eepurl.com', '205-665-2992', '4 Kim Park', 'aol.com/volutpat/dui/maecenas/tristique/est/et.png', 'In Review', 'Asked for technical details', '2024-03-08', 48, 'Birmingham', 'Alabama', 35464);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (27, '68', 'Pixoboo', 'Corrinne', 'Caudrey', 'ccaudreyq@nytimes.com', '806-611-4639', '4 Grasskamp Circle', 'usgs.gov/nullam/sit/amet.js', 'Contacted', 'Sent intro email', '2023-03-27', 38, 'Lubbock', 'Texas', 40942);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (28, '51', 'Feedmix', 'Willyt', 'Runsey', 'wrunseyr@creativecommons.org', '704-409-0437', '9916 Springview Drive', 'miitbeian.gov.cn/ligula/suspendisse/ornare/consequat/lectus/in/est.xml', 'Contacted', 'Rescheduled call', '2024-06-10', 93, 'Charlotte', 'North Carolina', 87505);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (29, '13', 'Lazzy', 'Amitie', 'Petchey', 'apetcheys@theatlantic.com', '559-237-3789', '8644 Sloan Street', 'jigsy.com/sapien/a.js', 'In Review', 'Said to reach back next week', '2024-07-23', 10, 'Fresno', 'California', 22610);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (30, '28', 'Flipstorm', 'Colette', 'Stone Fewings', 'cstonefewingst@pinterest.com', '281-268-1945', '775 Moose Court', 'phpbb.com/volutpat/sapien/arcu/sed/augue/aliquam.png', 'In Review', 'Asked for technical details', '2024-03-11', 92, 'Houston', 'Texas', 68699);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (31, '69', 'Brightdog', 'Vevay', 'Simpson', 'vsimpsonu@webmd.com', '516-601-1252', '2 Russell Terrace', 'theglobeandmail.com/odio/consequat/varius.html', 'New', 'Reviewing with manager', '2024-03-01', 58, 'Jamaica', 'New York', 12401);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (32, '59', 'Eare', 'Rodrick', 'Steanyng', 'rsteanyngv@icio.us', '717-932-9435', '72344 Pennsylvania Circle', 'ucla.edu/ipsum.aspx', 'New', 'Checking internal resources', '2025-01-20', 55, 'Lancaster', 'Pennsylvania', 49236);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (33, '54', 'Kayveo', 'Sigismond', 'O''Glassane', 'soglassanew@drupal.org', '408-686-1460', '37622 North Park', 'nsw.gov.au/non/interdum/in.jsp', 'Closed Won', 'Introduced to second decision-maker', '2023-04-05', 64, 'San Jose', 'California', 99209);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (34, '44', 'Oyoba', 'Marinna', 'Du Fray', 'mdufrayx@google.com.br', '702-784-0125', '2 Florence Place', 'booking.com/magnis/dis.png', 'Contacted', 'Needs legal review', '2023-02-01', 30, 'Las Vegas', 'Nevada', 19242);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (35, '5', 'Lajo', 'Henka', 'Pegram', 'hpegramy@squidoo.com', '727-373-0204', '0518 Anthes Street', 'xinhuanet.com/vehicula/condimentum.jsp', 'Negotiating', 'Requested pricing info', '2025-01-09', 81, 'Saint Petersburg', 'Florida', 88515);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (36, '71', 'Innotype', 'Gill', 'Whitewood', 'gwhitewoodz@nhs.uk', '480-111-0098', '7141 Moulton Way', 'ezinearticles.com/in/ante/vestibulum/ante/ipsum/primis.js', 'New', 'Shared use case', '2023-01-16', 87, 'Scottsdale', 'Arizona', 34794);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (37, '2', 'Livetube', 'Nancee', 'Darby', 'ndarby10@amazon.de', '515-331-5676', '6512 Dottie Pass', 'about.com/suspendisse/ornare.json', 'Negotiating', 'Scheduled follow-up call', '2024-05-07', 34, 'Des Moines', 'Iowa', 96920);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (38, '31', 'Yamia', 'Katti', 'Pithcock', 'kpithcock11@nifty.com', '303-259-0065', '8 Shasta Hill', 'imgur.com/ante.png', 'Contacted', 'Asked for technical details', '2023-01-13', 74, 'Boulder', 'Colorado', 70009);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (39, '45', 'Trilith', 'Felita', 'Owers', 'fowers12@gmpg.org', '718-581-3300', '41502 Summer Ridge Road', 'typepad.com/quam/turpis/adipiscing/lorem.xml', 'Negotiating', 'Requested pricing info', '2023-01-14', 20, 'Staten Island', 'New York', 19748);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (40, '48', 'Twinte', 'Birdie', 'Sapseed', 'bsapseed13@ihg.com', '706-967-8971', '108 Upham Drive', 'vimeo.com/eget/elit/sodales/scelerisque/mauris/sit.aspx', 'Contacted', 'Needs executive buy-in', '2023-06-29', 59, 'Cumming', 'Georgia', 82997);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (41, '42', 'Kazio', 'Fina', 'Brisley', 'fbrisley14@ocn.ne.jp', '410-691-7959', '9 Claremont Avenue', 'topsy.com/adipiscing.js', 'Closed Won', 'Wants to see case studies', '2024-11-30', 66, 'Baltimore', 'Maryland', 35931);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (42, '32', 'Realpoint', 'Merill', 'Cosens', 'mcosens15@tuttocitta.it', '510-157-8952', '74 Maryland Avenue', 'engadget.com/sit/amet/sem/fusce.html', 'Negotiating', 'Wants more examples', '2024-06-16', 8, 'Berkeley', 'California', 41353);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (43, '16', 'Kazio', 'Bevin', 'Cloy', 'bcloy16@reddit.com', '562-372-8822', '16496 Scoville Junction', 'seattletimes.com/eget.png', 'New', 'Negotiating pricing', '2025-02-17', 20, 'Los Angeles', 'California', 57445);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (44, '75', 'Camido', 'Robbyn', 'Strangman', 'rstrangman17@wikispaces.com', '202-808-8923', '9457 Heath Park', 'rediff.com/viverra/dapibus/nulla/suscipit.xml', 'In Review', 'Interested in joining', '2023-05-10', 97, 'Washington', 'District of Columbia', 19987);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (45, '56', 'Eidel', 'Elspeth', 'Sherar', 'esherar18@howstuffworks.com', '707-906-2555', '03 Buhler Alley', 'si.edu/vulputate/luctus/cum/sociis/natoque.jpg', 'Closed Won', 'Opened email no reply', '2023-05-17', 78, 'Petaluma', 'California', 67714);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (46, '47', 'Linklinks', 'Valaria', 'Isacke', 'visacke19@ibm.com', '210-295-4348', '005 Macpherson Parkway', 'nyu.edu/sapien/varius/ut/blandit/non.jsp', 'New', 'Interested in free trial', '2024-03-10', 32, 'San Antonio', 'Texas', 37743);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (47, '53', 'Feedfish', 'Merralee', 'Lamplough', 'mlamplough1a@wordpress.org', '205-805-9513', '9 Namekagon Crossing', 'google.fr/donec/posuere.js', 'Closed Won', 'Asked for technical details', '2023-02-23', 51, 'Birmingham', 'Alabama', 93243);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (48, '3', 'Demivee', 'Curtice', 'Arrowsmith', 'carrowsmith1b@e-recht24.de', '832-823-2555', '93745 Dennis Terrace', 'youku.com/aliquam/sit/amet/diam.jpg', 'In Review', 'Sent intro email', '2023-06-01', 6, 'Houston', 'Texas', 34030);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (49, '76', 'Plajo', 'Dasi', 'Waterstone', 'dwaterstone1c@hexun.com', '330-822-4741', '6 Dwight Center', 'nifty.com/non/mattis/pulvinar.json', 'Contacted', 'Asked about custom plan', '2024-08-27', 51, 'Akron', 'Ohio', 51665);
INSERT INTO Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, StreetAddress, Website, Status, Notes, LastContactedAt, Suite, City, State, ZipCode) VALUES (50, '80', 'Yadel', 'Towny', 'Lakey', 'tlakey1d@stanford.edu', '803-304-7785', '4 Carberry Point', 'altervista.org/nec/nisi/vulputate/nonummy/maecenas/tincidunt/lacus.js', 'Negotiating', 'Interested in free trial', '2023-01-27', 6, 'Columbia', 'South Carolina', 80066);

-- FraudTickets
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (1, '16', '2024-11-01', 'Duplicate transaction entries', 'Open');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (2, '42', '2024-07-02', 'Data tampering suspected', 'Awaiting Customer Response');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (3, '79', '2024-09-02', 'Unusual high-value transaction', 'Closed');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (4, '55', '2024-04-17', 'Data tampering suspected', 'Closed');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (5, '56', '2024-12-27', 'Data tampering suspected', 'Dismissed');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (6, '3', '2023-07-23', 'Multiple reports from same user', 'Dismissed');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (7, '54', '2023-08-19', 'Inconsistent location data', 'Escalated');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (8, '60', '2025-01-23', 'Complaints of unauthorized purchase', 'On Hold');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (9, '27', '2023-05-14', 'Sudden coin drain', 'Resolved');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (10, '61', '2023-08-27', 'Duplicate transaction entries', 'On Hold');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (11, '15', '2024-03-28', 'Order placed and canceled repeatedly', 'On Hold');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (12, '77', '2023-07-14', 'Multiple failed login attempts', 'Escalated');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (13, '57', '2025-02-18', 'System flagged abnormal usage', 'Open');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (14, '2', '2025-01-17', 'Sudden coin drain', 'Open');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (15, '64', '2023-03-09', 'Data tampering suspected', 'Dismissed');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (16, '20', '2024-11-14', 'Sudden coin drain', 'Escalated');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (17, '53', '2023-12-26', 'Reward item redeemed multiple times', 'Escalated');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (18, '10', '2024-08-13', 'System flagged abnormal usage', 'Resolved');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (19, '45', '2023-10-04', 'Data tampering suspected', 'Closed');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (20, '17', '2023-10-03', 'Customer denying transactions', 'Awaiting Customer Response');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (21, '4', '2024-03-10', 'Customer denying transactions', 'Awaiting Customer Response');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (22, '22', '2024-01-05', 'Data tampering suspected', 'Dismissed');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (23, '19', '2023-07-05', 'System flagged abnormal usage', 'Resolved');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (24, '65', '2025-01-27', 'Customer denying transactions', 'Escalated');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (25, '46', '2023-11-26', 'Multiple chargebacks', 'On Hold');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (26, '11', '2025-03-06', 'Card used in multiple cities', 'Awaiting Customer Response');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (27, '62', '2024-12-12', 'Customer denying transactions', 'On Hold');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (28, '76', '2024-12-13', 'Multiple chargebacks', 'Investigating');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (29, '25', '2023-10-08', 'Suspicious refund activity', 'Closed');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (30, '33', '2024-09-16', 'Account accessed from unknown device', 'Open');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (31, '36', '2024-10-21', 'Account accessed from unknown device', 'Closed');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (32, '23', '2023-03-12', 'Suspected fake account', 'Investigating');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (33, '30', '2023-04-06', 'Multiple failed login attempts', 'Open');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (34, '1', '2023-03-29', 'Duplicate transaction entries', 'On Hold');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (35, '12', '2023-09-18', 'Multiple chargebacks', 'Awaiting Customer Response');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (36, '38', '2025-01-18', 'Card used in multiple cities', 'Resolved');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (37, '49', '2025-03-10', 'Inconsistent location data', 'Dismissed');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (38, '34', '2024-01-08', 'Order placed and canceled repeatedly', 'Dismissed');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (39, '28', '2023-10-09', 'Multiple failed login attempts', 'On Hold');
INSERT INTO FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) VALUES (40, '63', '2024-02-13', 'Data tampering suspected', 'Awaiting Customer Response');

-- Alerts
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (1, '79', 'Staff Training Announcement', 'CafeCoin turns one – celebrate with us!', '2023-04-15', 'Support Team.', 'Open', 'Low');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (2, '23', 'System Maintenance', 'Limited-time offer available', '2024-07-07', 'Beta Testers', 'Investigating', 'High');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (3, '35', 'Delivery Area Expansion', 'Order ahead and skip the line.', '2023-09-10', 'Merchants', 'Investigating', 'Low');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (4, '19', 'Limited Time Offer', 'Refer a friend and earn coins', '2024-01-22', 'Employees', 'Open', 'Low');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (5, '12', 'Transaction Delay Alert', 'New merchant partners added', '2023-01-26', 'All Users', 'Dismissed', 'Low');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (6, '70', 'Data Usage Policy', 'System maintenance scheduled tonight', '2024-05-29', 'Customers', 'On Hold', 'Medium');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (7, '48', 'Coin Balance Adjustment', 'Limited-time offer available', '2023-09-28', 'All Users', 'On Hold', 'High');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (8, '5', 'Limited Time Offer', 'New rewards program launched', '2024-06-19', 'Support Team.', 'Dismissed', 'Medium');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (9, '38', 'Website Maintenance', 'Refer a friend and earn coins', '2024-05-14', 'New Users', 'On Hold', 'Low');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (10, '47', 'Holiday Schedule', 'We''ve updated our terms of service', '2023-08-04', 'Loyalty Members', 'Dismissed', 'Medium');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (11, '72', 'Loyalty Tier Adjustment', 'Order ahead and skip the line.', '2023-10-02', 'Loyalty Members', 'Closed', 'Medium');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (12, '42', 'Operating Hours Update', 'Welcome to CafeCoin!', '2024-08-31', 'Beta Testers', 'Open', 'Medium');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (13, '60', 'Rewards Expiry Notice', 'New merchant partners added', '2024-01-30', 'Merchants', 'Dismissed', 'High');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (14, '7', 'Service Interruption Notice', 'We''ve updated our terms of service', '2023-10-07', 'Merchants', 'Investigating', 'Medium');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (15, '24', 'Email Preferences Update.', 'New rewards program launched', '2024-01-13', 'Loyalty Members', 'Open', 'Low');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (16, '10', 'App Version Release', 'Stay safe: Avoid phishing scams', '2025-03-09', 'Employees', 'On Hold', 'Medium');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (17, '37', 'System Maintenance', 'Try our seasonal drinks!', '2025-02-24', 'Beta Testers', 'On Hold', 'Medium');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (18, '52', 'Feature Deactivation Notice', 'Order ahead and skip the line.', '2025-03-08', 'Merchants', 'Escalated', 'Low');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (19, '8', 'Temporary Feature Suspension', 'System maintenance scheduled tonight', '2023-09-05', 'All Users', 'On Hold', 'Low');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (20, '14', 'Coin Balance Adjustment', 'Order ahead and skip the line.', '2023-07-02', 'Customers', 'Open', 'High');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (21, '75', 'Account Verification Notice', 'Discount applied to your next purchase', '2023-10-12', 'Inactive Users', 'Awaiting Customer Response', 'Medium');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (22, '27', 'New Feature Launch', 'System maintenance scheduled tonight', '2024-01-27', 'Inactive Users', 'Investigating', 'Low');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (23, '58', 'Reward Limit Update', 'Refer a friend and earn coins', '2023-12-05', 'Support Team.', 'Resolved', 'High');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (24, '40', 'Scheduled Downtime', 'Faster support now available', '2023-09-13', 'Beta Testers', 'Open', 'High');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (25, '31', 'Transaction Delay Alert', 'New shop locations added', '2025-01-15', 'New Users', 'Open', 'Medium');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (26, '9', 'Data Usage Policy', 'Enjoy faster checkout with saved cards', '2023-12-08', 'Inactive Users', 'On Hold', 'High');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (27, '64', 'Loyalty Tier Adjustment', 'Check out your coin balance', '2023-03-24', 'Customers', 'On Hold', 'High');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (28, '62', 'App Version Release', 'New dashboard tools for merchants', '2024-11-05', 'Employees', 'Dismissed', 'Low');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (29, '32', 'Loyalty Tier Adjustment', 'Security settings changed', '2023-11-13', 'All Users', 'On Hold', 'High');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (30, '59', 'Email Preferences Update.', 'Don''t miss our spring event', '2025-03-17', 'Support Team.', 'Open', 'High');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (31, '6', 'Promo Code Alert', 'We''ve refreshed our menu!', '2024-02-14', 'Employees', 'Resolved', 'High');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (32, '33', 'App Version Release', 'Order ahead and skip the line.', '2024-10-16', 'Customers', 'Closed', 'High');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (33, '45', 'Temporary Feature Suspension', 'Account activity alert', '2023-04-14', 'New Users', 'Dismissed', 'Medium');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (34, '57', 'Subscription Reminder', 'Try our seasonal drinks!', '2023-06-28', 'Loyalty Members', 'Investigating', 'High');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (35, '80', 'New Store Opening', 'New shop locations added', '2023-06-23', 'All Users', 'Investigating', 'Low');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (36, '2', 'Temporary Feature Suspension', 'Reminder: Update your payment info', '2023-02-21', 'Support Team.', 'Dismissed', 'Medium');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (37, '36', 'Customer Support Downtime', 'New amenities added near you', '2023-10-28', 'New Users', 'Dismissed', 'Medium');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (38, '46', 'Feedback Survey Launch', 'CafeCoin turns one – celebrate with us!', '2023-09-05', 'Admins', 'Open', 'High');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (39, '11', 'Limited Time Offer', 'System maintenance scheduled tonight', '2024-07-09', 'Beta Testers', 'Investigating', 'High');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (40, '39', 'Feature Deactivation Notice', 'New feature: Order tracking', '2024-07-02', 'Inactive Users', 'Escalated', 'Low');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (41, '78', 'Temporary Feature Suspension', 'Welcome to CafeCoin!', '2023-10-11', 'Loyalty Members', 'Dismissed', 'Medium');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (42, '30', 'App Version Release', 'Community spotlight: Featured merchants', '2024-04-29', 'Inactive Users', 'Resolved', 'Low');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (43, '65', 'Operating Hours Update', 'We''ve refreshed our menu!', '2024-09-22', 'Employees', 'On Hold', 'Medium');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (44, '63', 'Auto-Reload Changes', 'CafeCoin turns one – celebrate with us!', '2024-04-10', 'Loyalty Members', 'Investigating', 'Medium');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (45, '49', 'Delivery Area Expansion', 'CafeCoin turns one – celebrate with us!', '2024-02-03', 'Support Team.', 'Resolved', 'Medium');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (46, '73', 'Bug Fix Announcement', 'New rewards program launched', '2024-01-31', 'Inactive Users', 'Closed', 'High');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (47, '51', 'Bug Fix Announcement', 'Your order has shipped', '2025-03-13', 'Customers', 'Dismissed', 'Low');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (48, '50', 'Limited Time Offer', 'You''re close to earning a reward!', '2024-06-22', 'Merchants', 'Awaiting Customer Response', 'High');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (49, '4', 'Loyalty Program Update', 'Account activity alert', '2024-09-09', 'Admins', 'Awaiting Customer Response', 'Medium');
INSERT INTO Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) VALUES (50, '76', 'App Version Release', 'New amenities added near you', '2023-05-14', 'Support Team.', 'Resolved', 'High');

-- Amenities
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (1, 'Seasonal Menu', 'Temperature-controlled environment');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (2, 'Fireplace Lounge', 'Soft lounge seating');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (3, 'Gluten-Free', 'Drive-thru order and pickup service');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (4, 'Organic Options', 'Soft lounge seating');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (5, 'Loyalty Program', 'Designated tables for studying');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (6, 'Open Late', 'Comfortable indoor seating');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (7, 'Seasonal Menu', 'Drive-thru order and pickup service');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (8, 'Air Conditioning', 'Bring your own cup for a discount');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (9, 'Live Music', 'Self-service ordering kiosk');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (10, 'Vegan', 'Comfortable indoor seating');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (11, 'Open Late', 'Quiet area ideal for studying or work');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (12, 'Fireplace Lounge', 'Fair trade certified coffee options');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (13, 'Air Conditioning', 'Comfortable indoor seating');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (14, 'Art Display', 'Soft lounge seating');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (15, 'Wi-Fi', 'Rotating seasonal offerings');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (16, 'Loyalty Program', 'Temperature-controlled environment');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (17, 'Live Music', 'Access to rooftop seating or views');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (18, 'Self-Serve Kiosk', 'Bulletin board for events and ads');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (19, 'Fair Trade Coffee', 'USB and outlet charging stations');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (20, 'Fireplace Lounge', 'Bulletin board for events and ads');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (21, 'Indoor Seating', 'Earn rewards with purchases');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (22, 'Barista Classes', 'Comfortable indoor seating');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (23, 'Podcast Studio', 'Bulletin board for events and ads');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (24, 'Podcast Studio', 'Soft lounge seating');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (25, 'Podcast Studio', 'Quiet area ideal for studying or work');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (26, 'Art Display', 'Locally roasted coffee beans');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (27, 'Live Music', 'Changing table in restroom');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (28, 'Seasonal Menu', 'Discount for students with ID');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (29, 'Rooftop Access', 'Live music on select days');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (30, 'Gluten-Free Pastries', 'Workshops to learn barista skills');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (31, 'Free Samples', 'Bins for compostable waste');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (32, 'Scenic Views', 'Wide selection of teas');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (33, 'Charging Stations', 'Changing table in restroom');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (34, 'Reusable Cups', 'Gluten-free pastries available');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (35, 'Study Tables', 'Access to rooftop seating or views');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (36, 'Live Music', 'Lounge area near a fireplace');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (37, 'Student Discount', 'High-speed internet access for all customers');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (38, 'Self-Serve Kiosk', 'Temperature-controlled environment');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (39, 'Reusable Cups', 'Changing table in restroom');
INSERT INTO Amenities (AmenityId, Name, Description) VALUES (40, 'Rooftop Access', 'Bulletin board for events and ads');

-- StoreAmenities
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (13, 9);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (12, 15);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (5, 27);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (1, 34);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (7, 36);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (6, 3);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (4, 22);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (13, 37);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (10, 26);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (8, 25);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (14, 14);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (13, 5);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (3, 2);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (9, 40);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (11, 29);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (3, 18);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (10, 7);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (3, 28);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (6, 12);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (11, 1);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (12, 35);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (10, 6);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (9, 19);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (11, 23);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (2, 21);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (12, 33);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (9, 39);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (8, 11);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (10, 30);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (5, 38);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (12, 16);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (5, 10);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (7, 17);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (11, 4);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (1, 13);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (3, 8);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (10, 24);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (3, 31);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (15, 32);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (9, 20);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (5, 35);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (8, 31);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (9, 22);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (4, 17);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (12, 13);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (15, 2);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (1, 39);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (4, 5);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (2, 8);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (13, 11);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (9, 12);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (15, 34);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (3, 24);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (4, 7);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (2, 25);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (9, 18);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (1, 29);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (9, 14);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (9, 4);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (14, 6);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (1, 3);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (14, 38);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (13, 27);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (9, 33);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (5, 26);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (11, 28);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (7, 40);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (2, 15);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (7, 1);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (4, 9);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (6, 32);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (14, 20);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (15, 36);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (5, 23);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (11, 21);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (1, 30);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (11, 19);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (6, 10);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (4, 16);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (2, 37);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (7, 39);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (8, 30);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (8, 5);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (1, 10);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (2, 31);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (15, 39);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (6, 28);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (6, 20);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (14, 13);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (11, 12);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (14, 17);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (11, 22);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (9, 2);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (14, 36);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (14, 32);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (3, 37);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (8, 26);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (6, 35);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (9, 16);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (5, 9);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (12, 40);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (1, 33);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (9, 29);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (5, 24);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (7, 19);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (6, 21);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (11, 27);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (13, 7);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (8, 14);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (14, 25);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (6, 11);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (6, 8);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (9, 6);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (12, 18);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (7, 15);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (14, 3);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (8, 23);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (12, 4);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (3, 34);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (8, 38);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (7, 34);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (12, 1);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (6, 37);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (8, 29);
INSERT INTO StoreAmenities (AmenityId, MerchantId) VALUES (12, 26);

-- CustAmentPref
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (8, 26);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (38, 8);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (15, 2);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (30, 19);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (16, 14);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (40, 23);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (36, 40);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (22, 3);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (12, 39);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (17, 7);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (28, 30);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (24, 32);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (11, 1);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (3, 34);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (6, 29);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (24, 4);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (6, 27);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (1, 11);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (4, 6);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (2, 13);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (6, 16);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (25, 20);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (38, 35);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (10, 25);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (29, 31);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (27, 33);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (18, 17);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (2, 10);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (31, 37);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (20, 15);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (31, 22);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (29, 5);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (6, 21);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (39, 38);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (9, 28);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (35, 9);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (9, 24);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (3, 36);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (10, 18);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (7, 12);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (30, 35);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (5, 20);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (14, 21);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (30, 14);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (8, 30);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (31, 31);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (12, 4);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (9, 40);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (4, 17);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (40, 22);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (11, 33);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (29, 13);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (11, 7);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (13, 8);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (23, 18);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (5, 36);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (5, 5);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (12, 24);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (40, 15);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (34, 2);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (40, 10);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (34, 26);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (38, 37);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (7, 29);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (6, 9);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (11, 25);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (17, 34);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (8, 39);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (27, 28);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (25, 16);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (13, 27);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (10, 32);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (16, 38);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (13, 19);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (35, 23);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (2, 12);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (11, 3);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (22, 11);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (13, 6);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (34, 11);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (9, 18);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (25, 11);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (12, 25);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (26, 14);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (18, 36);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (11, 5);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (16, 20);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (27, 35);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (38, 19);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (24, 11);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (23, 7);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (28, 28);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (37, 3);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (20, 17);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (27, 13);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (29, 39);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (15, 32);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (34, 40);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (15, 24);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (16, 9);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (22, 12);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (17, 38);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (28, 33);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (40, 31);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (7, 16);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (12, 29);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (35, 26);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (21, 21);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (3, 4);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (28, 8);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (15, 6);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (14, 22);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (32, 2);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (10, 23);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (18, 27);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (27, 15);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (8, 34);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (26, 10);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (3, 37);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (26, 30);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (14, 33);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (10, 7);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (19, 36);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (25, 27);
INSERT INTO CustAmenityPrefs (AmenityId, CustomerId) VALUES (23, 31);