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
    SubmitDate DATETIME DEFAULT CURRENT TIMESTAMP,
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
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (1, 'Jasper', 'Finch', 'siwanicki0@wix.com', '520-637-2899', '57 Myrtle Court', '14th Floor', 'Prescott', 'Arizona', '86305', 51, 38, '2024-06-19', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (2, 'Sander', 'Valde', 'svalde1@utexas.edu', '352-968-2822', '2 Algoma Park', 'Room 1095', 'Spring Hill', 'Florida', '34611', 36, 44, '2024-05-14', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (3, 'Berny', 'Avent', 'bavent2@yolasite.com', '510-559-2810', '2 Magdeline Pass', 'Apt 1175', 'Oakland', 'California', '94660', 52, 36, '2024-05-02', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (4, 'Teressa', 'Blogg', 'tblogg3@cnn.com', '313-901-1433', '001 Fieldstone Point', 'Apt 2000', 'Detroit', 'Michigan', '48232', 91, 9, '2024-05-17', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (5, 'Ransom', 'Loads', 'rloads4@skyrock.com', '203-580-1272', '31986 Rusk Avenue', 'Room 1232', 'Fairfield', 'Connecticut', '06825', 97, 27, '2024-06-08', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (6, 'Simonne', 'Gussin', 'sgussin5@nsw.gov.au', '504-411-1785', '4 Sachs Avenue', 'PO Box 52254', 'Metairie', 'Louisiana', '70005', 41, 2, '2025-03-05', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (7, 'Lorrie', 'Quene', 'lquene6@fc2.com', '571-293-5437', '8230 Marquette Parkway', 'Apt 749', 'Fairfax', 'Virginia', '22036', 72, 97, '2025-01-16', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (8, 'Fletcher', 'Shurville', 'fshurville7@illinois.edu', '509-588-6958', '17370 Spaight Junction', 'Room 179', 'Yakima', 'Washington', '98907', 186, 46, '2025-02-13', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (9, 'Gertrudis', 'Brownfield', 'gbrownfield8@ebay.co.uk', '718-453-9805', '1 Northport Crossing', '14th Floor', 'Brooklyn', 'New York', '11220', 74, 47, '2025-01-25', true, 7);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (10, 'Nora', 'Beadnall', 'nbeadnall9@ted.com', '850-711-1279', '88494 Clyde Gallagher Lane', 'Room 1149', 'Panama City', 'Florida', '32405', 28, 63, '2024-12-01', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (11, 'Stanislaus', 'Izkoveski', 'sizkoveskia@wp.com', '316-623-0814', '1684 Superior Terrace', 'Apt 1366', 'Wichita', 'Kansas', '67230', 96, 78, '2024-11-06', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (12, 'Brietta', 'Scourge', 'bscourgeb@creativecommons.org', '213-139-8491', '7038 Mendota Trail', 'PO Box 9283', 'Los Angeles', 'California', '90030', 65, 17, '2025-01-18', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (13, 'Fernandina', 'Spurden', 'fspurdenc@friendfeed.com', '509-314-8059', '7846 Oriole Point', 'PO Box 16775', 'Spokane', 'Washington', '99260', 49, 54, '2024-10-06', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (14, 'Brendon', 'Berge', 'bberged@yolasite.com', '256-368-3893', '1677 Clove Way', 'Room 1594', 'Huntsville', 'Alabama', '35815', 24, 19, '2025-02-27', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (15, 'Elinore', 'Strangeways', 'estrangewayse@sakura.ne.jp', '818-133-6654', '503 Canary Crossing', 'Room 1400', 'Torrance', 'California', '90510', 299, 79, '2024-07-14', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (16, 'Harriott', 'Hallgarth', 'hhallgarthf@com.com', '615-532-5825', '50845 Northfield Lane', '2nd Floor', 'Nashville', 'Tennessee', '37250', 322, 5, '2024-10-02', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (17, 'Rurik', 'Pemberton', 'rpembertong@hhs.gov', '330-838-9811', '3 Green Point', 'Room 838', 'Akron', 'Ohio', '44310', 99, 90, '2024-05-08', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (18, 'Rafaelita', 'Hamelyn', 'rhamelynh@archive.org', '803-713-8627', '54230 Riverside Lane', 'Suite 6', 'Columbia', 'South Carolina', '29215', 31, 38, '2025-02-26', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (19, 'Brett', 'Cundy', 'bcundyi@themeforest.net', '202-956-2563', '1112 Dapin Park', 'Suite 90', 'Washington', 'District of Columbia', '20409', 52, 38, '2025-01-21', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (20, 'Elissa', 'Moryson', 'emorysonj@smh.com.au', '561-625-5251', '41 Mockingbird Circle', 'PO Box 53454', 'West Palm Beach', 'Florida', '33405', 29, 6, '2024-09-09', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (21, 'Henderson', 'Gillitt', 'hgillittk@example.com', '515-136-0596', '60482 Schlimgen Trail', 'Room 282', 'Des Moines', 'Iowa', '50347', 36, 10, '2025-03-23', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (22, 'Marley', 'Cricket', 'mcricketl@xrea.com', '202-445-5306', '03 Moulton Street', 'Apt 1884', 'Washington', 'District of Columbia', '20010', 4, 62, '2025-03-30', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (23, 'Berna', 'Bagwell', 'bbagwellm@economist.com', '937-742-2810', '58508 Dixon Road', '19th Floor', 'Dayton', 'Ohio', '45419', 77, 55, '2024-08-19', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (24, 'Blinny', 'Eyles', 'beylesn@cnn.com', '318-401-7384', '0424 Merrick Plaza', 'Apt 1774', 'Shreveport', 'Louisiana', '71151', 90, 30, '2024-06-04', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (25, 'Robbie', 'McAvin', 'rmcavino@csmonitor.com', '804-779-8687', '13 Bartillon Terrace', 'Apt 972', 'Richmond', 'Virginia', '23260', 0, 98, '2024-05-11', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (26, 'Mirilla', 'Pozzi', 'mpozzip@forbes.com', '850-415-7836', '0 Cody Lane', 'Room 1929', 'Pensacola', 'Florida', '32511', 99, 39, '2024-12-22', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (27, 'Kippie', 'Steffan', 'ksteffanq@reference.com', '816-650-3033', '2929 Kensington Drive', 'Suite 89', 'Kansas City', 'Missouri', '64199', 16, 1, '2024-11-11', false, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (28, 'Romain', 'Chessill', 'rchessillr@liveinternet.ru', '484-114-0055', '089 Farmco Plaza', 'PO Box 82635', 'Bethlehem', 'Pennsylvania', '18018', 81, 25, '2024-09-30', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (29, 'Paten', 'Pimm', 'ppimms@dagondesign.com', '937-986-1761', '3 Sunfield Junction', 'Suite 33', 'Dayton', 'Ohio', '45470', 87, 3, '2024-10-14', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (30, 'Deanne', 'Ruane', 'druanet@uol.com.br', '831-614-8913', '12 Gateway Road', 'Room 1210', 'Santa Cruz', 'California', '95064', 65, 59, '2024-08-14', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (31, 'Josephine', 'Boothe', 'jbootheu@epa.gov', '208-568-0763', '98 Hallows Drive', 'Apt 343', 'Idaho Falls', 'Idaho', '83405', 48, 88, '2024-07-24', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (32, 'Marsiella', 'Paul', 'mpaulv@example.com', '775-927-8902', '5290 Sachs Circle', 'Suite 94', 'Reno', 'Nevada', '89550', 323, 31, '2024-04-11', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (33, 'Lianna', 'Stracey', 'lstraceyw@shareasale.com', '316-407-4591', '1 Park Meadow Plaza', 'Room 360', 'Wichita', 'Kansas', '67236', 89, 63, '2024-09-22', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (34, 'Aloisia', 'Marie', 'amariex@chron.com', '360-925-3043', '028 Maywood Park', '10th Floor', 'Seattle', 'Washington', '98121', 94, 45, '2024-05-07', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (35, 'Victoria', 'Blessed', 'vblessedy@google.fr', '860-345-2431', '59 Arrowood Place', 'PO Box 78394', 'Hartford', 'Connecticut', '06140', 32, 3, '2025-02-28', false, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (36, 'Nanon', 'Hammarberg', 'nhammarbergz@ask.com', '956-697-6475', '72 Mcbride Street', '13th Floor', 'Laredo', 'Texas', '78044', 300, 27, '2024-06-22', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (37, 'Camilla', 'Duchateau', 'cduchateau10@usda.gov', '626-633-7187', '84 Lunder Alley', 'Suite 30', 'Pasadena', 'California', '91109', 71, 34, '2024-07-12', true, 17);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (38, 'Heidi', 'MacCoughen', 'hmaccoughen11@phoca.cz', '724-775-9252', '271 Sundown Terrace', '12th Floor', 'Pittsburgh', 'Pennsylvania', '15210', 97, 49, '2025-02-06', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (39, 'Kev', 'Cohn', 'kcohn12@nbcnews.com', '314-979-7351', '065 Montana Junction', '7th Floor', 'Saint Louis', 'Missouri', '63150', 63, 35, '2024-12-22', true, 0);
insert into Customers (CustomerID, FirstName, LastName, Email, Phone, StreetAddress, Apartment, City, State, ZipCode, CoinBalance, AccountBalance, DateJoined, IsActive, AutoReloadAmt) values (40, 'Malissa', 'Bielfeldt', 'mbielfeldt13@reverbnation.com', '972-861-4815', '17012 Valley Edge Hill', 'Room 1869', 'Dallas', 'Texas', '75251', 52, 34, '2024-06-09', true, 0);

-- Merchants
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (1, 'CafeCoin', 'CafeCoin', NULL, 'estalman0@meetup.com', '508-474-2771', '08 2nd Crossing', '18th Floor', 'Newton', 'Massachusetts', '02162', 42.3319, -71.254, 'msn.com', 'Elwin', 'Stalman', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (2, 'The Brew Spot', 'Collective Member', 'Silver', 'dpaeckmeyer1@yellowpages.com', '217-212-8066', '15 Hintze Drive', 'PO Box 62357', 'Springfield', 'Illinois', '62705', 39.7495, -89.606, 'weebly.com', 'Danica', 'Paeckmeyer', 'Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (3, 'Urban Grind', 'Collective Member', 'Gold', 'rbichard2@theatlantic.com', '214-173-8702', '42828 Sunnyside Avenue', 'Suite 90', 'Dallas', 'Texas', '75379', 32.7673, -96.7776, 'devhub.com', 'Read', 'Bichard', 'Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (4, 'Cozy Corner Cafe', 'Collective Member', 'Bronze', 'gmartinon3@nymag.com', '253-266-7139', '59 Namekagon Plaza', '13th Floor', 'Tacoma', 'Washington', '98411', 47.0662, -122.1132, 'wp.com', 'Garold', 'Martinon', 'Nulla justo.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (5, 'The Daily Drip', 'Collective Member', 'Silver', 'nsoares4@prnewswire.com', '413-899-2498', '9057 Oak Valley Trail', 'PO Box 70724', 'Springfield', 'Massachusetts', '01114', 42.1707, -72.6048, 'deviantart.com', 'Niko', 'Soares', 'In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (6, 'Java Junction', 'Collective Member', 'Gold', 'krooney5@huffingtonpost.com', '210-872-0938', '1483 Summerview Park', 'Room 1030', 'San Antonio', 'Texas', '78205', 29.4237, -98.4925, 'businesswire.com', 'Kelcie', 'Rooney', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (7, 'The Roasted Bean', 'Collective Member', 'Bronze', 'agumbley6@friendfeed.com', '515-665-5676', '925 Myrtle Center', 'Suite 55', 'Des Moines', 'Iowa', '50330', 41.6727, -93.5722, 'i2i.jp', 'Ashley', 'Gumbley', 'Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (8, 'The Coffee Loft', 'Collective Member', 'Silver', 'cbubbins7@boston.com', '305-556-6477', '52 Steensland Hill', '6th Floor', 'Miami Beach', 'Florida', '33141', 25.8486, -80.1446, 'pinterest.com', 'Carce', 'Bubbins', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (9, 'The Perk Place', 'Collective Member', 'Gold', 'kjonsson8@statcounter.com', '480-496-4530', '4 Erie Alley', 'Apt 1345', 'Phoenix', 'Arizona', '85045', 33.3022, -112.1226, 'gov.uk', 'Kristal', 'Jonsson', 'In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (10, 'Brewed Awakening', 'Collective Member', 'Bronze', 'cshrigley9@prlog.org', '502-906-6618', '24 Toban Avenue', 'Apt 1224', 'Louisville', 'Kentucky', '40233', 38.189, -85.6768, 'google.nl', 'Coriss', 'Shrigley', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (11, 'Caffeine & Co.', 'Collective Member', 'Silver', 'tkhilkova@newyorker.com', '763-327-8583', '05 Oakridge Way', 'PO Box 73011', 'Monticello', 'Minnesota', '55585', 45.2009, -93.8881, 'barnesandnoble.com', 'Tedi', 'Khilkov', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (12, 'Steam & Beans', 'Collective Member', 'Gold', 'ealabasterb@wikia.com', '952-915-8248', '808 Bunker Hill Place', 'PO Box 78990', 'Maple Plain', 'Minnesota', '55579', 45.0159, -93.4719, 'studiopress.com', 'Ellswerth', 'Alabaster', 'Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (13, 'The Java House', 'Collective Member', 'Bronze', 'cfinec@dmoz.org', '862-298-0624', '5052 Pine View Hill', 'Apt 580', 'Newark', 'New Jersey', '07195', 40.7918, -74.2452, 'vistaprint.com', 'Cordey', 'Fine', 'Duis aliquam convallis nunc.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (14, 'The Beanery', 'Collective Member', 'Silver', 'ggarcid@phpbb.com', '562-208-4478', '621 Leroy Park', 'Apt 1137', 'Long Beach', 'California', '90847', 33.7866, -118.2987, 'vk.com', 'Giffie', 'Garci', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', false);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (15, 'Steamy Sips', 'Collective Member', 'Gold', 'ewestnagee@chron.com', '214-579-5386', '256 Sugar Alley', '15th Floor', 'Mesquite', 'Texas', '75185', 32.7403, -96.5618, 'diigo.com', 'Esther', 'Westnage', 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (16, 'The Grindhouse', 'Collective Member', 'Bronze', 'kmcgorleyf@technorati.com', '202-800-7387', '1 Clyde Gallagher Road', 'Suite 20', 'Washington', 'District of Columbia', '20073', 38.897, -77.0251, 'hexun.com', 'Kriste', 'Mc Gorley', 'Vestibulum ac est lacinia nisi venenatis tristique.', false);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (17, 'Mocha Moments', 'Collective Member', 'Silver', 'lgasparrog@wiley.com', '763-890-1393', '96389 Alpine Hill', '11th Floor', 'Minneapolis', 'Minnesota', '55402', 44.9762, -93.2759, 'woothemes.com', 'Lionel', 'Gasparro', 'Nunc purus. Phasellus in felis. Donec semper sapien a libero.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (18, 'Cup of Joy', 'Collective Member', 'Gold', 'hshalesh@amazon.co.jp', '903-525-3436', '825 Sundown Avenue', 'PO Box 69402', 'Longview', 'Texas', '75605', 32.5547, -94.7767, 'yellowpages.com', 'Heinrik', 'Shales', 'Morbi quis tortor id nulla ultrices aliquet.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (19, 'The Morning Buzz', 'Collective Member', 'Bronze', 'cdrablei@yolasite.com', '315-367-2712', '7245 Gina Center', 'PO Box 92459', 'Syracuse', 'New York', '13205', 43.0123, -76.1452, 'cisco.com', 'Chryste', 'Drable', 'Curabitur gravida nisi at nibh.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (20, 'Grind & Brew', 'Collective Member', 'Silver', 'wgiralj@guardian.co.uk', '201-934-2823', '77658 Crest Line Avenue', 'Suite 47', 'Jersey City', 'New Jersey', '07305', 40.702, -74.089, 'google.cn', 'Wendy', 'Giral', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (21, 'Espresso Express', 'Collective Member', 'Gold', 'bcreswellk@ox.ac.uk', '972-306-7972', '49 Elmside Center', 'Room 150', 'Dallas', 'Texas', '75236', 32.69, -96.9177, 'engadget.com', 'Bell', 'Creswell', 'Donec semper sapien a libero. Nam dui.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (22, 'Roasty Toasty Cafe', 'Collective Member', 'Bronze', 'jharbourl@rakuten.co.jp', '201-477-8083', '7904 Annamark Center', 'PO Box 3467', 'Paterson', 'New Jersey', '07522', 40.9252, -74.1781, 'com.com', 'Janaye', 'Harbour', 'Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo.', false);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (23, 'Bean Town Cafe', 'Collective Member', 'Silver', 'vbluesm@house.gov', '509-669-8454', '2378 Butternut Circle', '16th Floor', 'Yakima', 'Washington', '98907', 46.6288, -120.574, 'scribd.com', 'Vite', 'Blues', 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (24, 'The Java Joint', 'Collective Member', 'Gold', 'lmarplen@hexun.com', '571-829-5706', '14 Graedel Junction', 'Suite 15', 'Arlington', 'Virginia', '22234', 38.8808, -77.113, 'techcrunch.com', 'Leila', 'Marple', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (25, 'The Steaming Cup', 'Collective Member', 'Bronze', 'swheatero@google.co.jp', '360-288-8918', '4 Melvin Street', 'Suite 46', 'Seattle', 'Washington', '98166', 47.4511, -122.353, 'google.es', 'Susann', 'Wheater', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum.', false);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (26, 'Bold Brews', 'Collective Member', 'Silver', 'dcaistorp@com.com', '561-995-2178', '8977 Ryan Court', 'Apt 296', 'West Palm Beach', 'Florida', '33411', 26.6644, -80.1741, 'goodreads.com', 'Daryl', 'Caistor', 'Nulla justo. Aliquam quis turpis eget elit sodales scelerisque.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (27, 'Caffeine Central', 'Collective Member', 'Gold', 'eprovestq@whitehouse.gov', '626-906-9117', '87387 Carey Parkway', 'Room 1179', 'Pasadena', 'California', '91103', 34.1669, -118.1551, 'sciencedaily.com', 'Ethelyn', 'Provest', 'Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (28, 'Brewed Bliss', 'Collective Member', 'Bronze', 'crappoportr@slideshare.net', '561-926-7793', '53799 Scoville Court', 'PO Box 17741', 'West Palm Beach', 'Florida', '33411', 26.6644, -80.1741, 'hibu.com', 'Cullin', 'Rappoport', 'Donec quis orci eget orci vehicula condimentum.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (29, 'The Cozy Mug', 'Collective Member', 'Silver', 'tgarrishs@zdnet.com', '757-524-7551', '6 Glendale Pass', 'Apt 1767', 'Suffolk', 'Virginia', '23436', 36.8926, -76.5142, 'google.com.hk', 'Thorpe', 'Garrish', 'Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (30, 'The Sipping Station', 'Collective Member', 'Gold', 'fsillyt@hhs.gov', '612-621-0582', '573 East Junction', '10th Floor', 'Minneapolis', 'Minnesota', '55417', 44.9054, -93.2361, 'biglobe.ne.jp', 'Felecia', 'Silly', 'Suspendisse accumsan tortor quis turpis. Sed ante.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (31, 'Pour Over Paradise', 'Collective Member', 'Bronze', 'ccatonnetu@forbes.com', '505-759-4253', '902 Lien Road', 'Apt 1723', 'Albuquerque', 'New Mexico', '87201', 35.0443, -106.6729, 'nsw.gov.au', 'Cornelle', 'Catonnet', 'Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (32, 'Sip & Savor', 'Collective Member', 'Silver', 'bjerransv@princeton.edu', '619-290-3016', '17709 Arrowood Crossing', '3rd Floor', 'San Diego', 'California', '92165', 33.0169, -116.846, 'php.net', 'Blake', 'Jerrans', 'Nulla ut erat id mauris vulputate elementum. Nullam varius.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (33, 'The Daily Grind', 'Collective Member', 'Gold', 'bhaighw@statcounter.com', '772-580-3663', '33203 Crescent Oaks Parkway', 'Room 903', 'Vero Beach', 'Florida', '32969', 27.709, -80.5726, 'paypal.com', 'Bibbie', 'Haigh', 'Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (34, 'The Brew Crew', 'Collective Member', 'Bronze', 'kmallindinex@nymag.com', '607-134-7511', '9 Warner Street', 'PO Box 95551', 'Elmira', 'New York', '14905', 42.0869, -76.8397, 'so-net.ne.jp', 'Kristien', 'Mallindine', 'Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (35, 'Steeped & Steamy', 'Collective Member', 'Silver', 'mmarcusseny@illinois.edu', '212-620-7919', '5328 Florence Avenue', 'Apt 1921', 'Jamaica', 'New York', '11431', 40.6869, -73.8501, 'bing.com', 'Marinna', 'Marcussen', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (36, 'The Roasting Room', 'Collective Member', 'Gold', 'haylenz@microsoft.com', '814-318-0490', '7 Manley Avenue', 'PO Box 41362', 'Erie', 'Pennsylvania', '16505', 42.1109, -80.1534, 'merriam-webster.com', 'Hilary', 'Aylen', 'Vestibulum sed magna at nunc commodo placerat.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (37, 'Bean & Barrel', 'Collective Member', 'Bronze', 'ihatrey10@chronoengine.com', '651-144-5097', '23263 Hallows Lane', '19th Floor', 'Minneapolis', 'Minnesota', '55417', 44.9054, -93.2361, 'comcast.net', 'Iorgo', 'Hatrey', 'In hac habitasse platea dictumst.', false);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (38, 'Sip City', 'Collective Member', 'Silver', 'alebang11@nhs.uk', '941-131-6168', '6 Clove Junction', '19th Floor', 'Naples', 'Florida', '34102', 26.134, -81.7953, 'freewebs.com', 'Aryn', 'Lebang', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', true);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (39, 'The Coffee Cartel', 'Collective Member', 'Gold', 'trosendahl12@youku.com', '571-951-4042', '9 Northridge Lane', 'Room 608', 'Reston', 'Virginia', '22096', 38.8318, -77.2888, 'elpais.com', 'Terri-jo', 'Rosendahl', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', false);
insert into Merchants (MerchantID, MerchantName, MerchantType, MembershipLvl, Email, Phone, StreetAddress, Suite, City, State, ZipCode, Lat, Lon, Website, OwnerFirst, OwnerLast, OwnerComment, IsActive) values (40, 'Brewtopia', 'Collective Member', 'Bronze', 'boatley13@prweb.com', '480-823-8189', '1682 Parkside Lane', '12th Floor', 'Phoenix', 'Arizona', '85025', 33.4226, -111.7236, 'facebook.com', 'Barnabas', 'Oatley', 'Cras pellentesque volutpat dui.', true);

-- Employees
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (1, '11', 'Steven', 'McKitterick', 'smckitterick0@blinklist.com', '303-794-5400', 'CafeCoin', '2024-10-21', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (2, '29', 'Lorraine', 'Gabitis', 'lgabitis1@ebay.com', '422-924-6520', 'CafeCoin', '2024-10-06', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (3, '37', 'Mil', 'Flight', 'mflight2@timesonline.co.uk', '931-487-8790', 'Store', '2024-11-03', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (4, '18', 'Gerald', 'Ashpole', 'gashpole3@china.com.cn', '872-677-5466', 'Store', '2024-11-14', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (5, '24', 'Mead', 'Stedman', 'mstedman4@zimbio.com', '108-789-0589', 'Store', '2025-01-21', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (6, '6', 'Spike', 'Judge', 'sjudge5@github.com', '214-645-8154', 'CafeCoin', '2024-12-24', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (7, '38', 'Lyndsey', 'Lyles', 'llyles6@ask.com', '606-797-8710', 'CafeCoin', '2024-06-05', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (8, '15', 'Baldwin', 'Leopold', 'bleopold7@fema.gov', '910-847-5697', 'CafeCoin', '2024-12-19', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (9, '16', 'Willy', 'Inge', 'winge8@wikia.com', '410-344-0804', 'CafeCoin', '2025-01-30', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (10, '14', 'Ximenes', 'Jarville', 'xjarville9@themeforest.net', '684-887-9922', 'Store', '2025-03-04', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (11, '31', 'Sapphire', 'Bacchus', 'sbacchusa@shinystat.com', '970-596-0150', 'Store', '2024-09-27', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (12, '17', 'Kirstin', 'Brunker', 'kbrunkerb@si.edu', '907-600-2118', 'Store', '2025-03-12', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (13, '20', 'Ariadne', 'Arlott', 'aarlottc@weather.com', '962-423-5124', 'Store', '2024-06-25', false);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (14, '23', 'Tabbi', 'Jeacocke', 'tjeacocked@springer.com', '216-625-8586', 'Store', '2025-03-03', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (15, '12', 'Herschel', 'Covotto', 'hcovottoe@epa.gov', '214-412-7778', 'CafeCoin', '2024-08-13', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (16, '28', 'Avictor', 'Glazzard', 'aglazzardf@gizmodo.com', '214-158-9993', 'CafeCoin', '2025-03-10', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (17, '33', 'Hermina', 'Shelly', 'hshellyg@shutterfly.com', '882-992-7839', 'CafeCoin', '2024-06-21', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (18, '19', 'Kane', 'Granger', 'kgrangerh@prnewswire.com', '526-568-5393', 'CafeCoin', '2024-06-27', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (19, '26', 'Moyra', 'Antecki', 'manteckii@nba.com', '620-267-7924', 'Store', '2024-07-11', false);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (20, '7', 'Arther', 'Blakeman', 'ablakemanj@example.com', '208-838-4387', 'CafeCoin', '2024-06-11', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (21, '9', 'Renard', 'Pentecust', 'rpentecustk@cmu.edu', '950-977-7908', 'Store', '2024-12-27', false);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (22, '27', 'Jayme', 'Goulden', 'jgouldenl@mtv.com', '801-131-5288', 'Store', '2024-04-09', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (23, '10', 'Lisette', 'Cawood', 'lcawoodm@linkedin.com', '163-910-9869', 'Store', '2025-02-08', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (24, '3', 'Karlie', 'Haslegrave', 'khaslegraven@huffingtonpost.com', '480-465-3817', 'CafeCoin', '2024-05-27', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (25, '5', 'Thorn', 'Curston', 'tcurstono@blogspot.com', '306-285-8014', 'CafeCoin', '2024-06-22', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (26, '34', 'Ned', 'Crush', 'ncrushp@house.gov', '165-987-2399', 'Store', '2024-10-05', false);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (27, '8', 'Tessi', 'Reade', 'treadeq@google.com', '654-890-3243', 'Store', '2024-09-11', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (28, '40', 'Marybeth', 'Alti', 'maltir@simplemachines.org', '418-985-1448', 'CafeCoin', '2024-11-09', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (29, '13', 'Ingunna', 'Holstein', 'iholsteins@1und1.de', '595-163-0150', 'Store', '2025-02-01', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (30, '2', 'Gwenneth', 'Malacrida', 'gmalacridat@digg.com', '746-360-8411', 'CafeCoin', '2024-07-01', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (31, '30', 'Tannie', 'Neil', 'tneilu@amazonaws.com', '970-969-0219', 'Store', '2025-02-18', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (32, '35', 'Mellisa', 'Beverstock', 'mbeverstockv@eventbrite.com', '387-165-5273', 'Store', '2024-06-26', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (33, '21', 'Gilles', 'Barbery', 'gbarberyw@independent.co.uk', '259-849-0945', 'Store', '2025-02-01', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (34, '1', 'Aliza', 'Handrok', 'ahandrokx@odnoklassniki.ru', '198-643-3210', 'Store', '2025-01-22', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (35, '22', 'Darsey', 'Masdin', 'dmasdiny@weibo.com', '802-325-8796', 'Store', '2024-10-17', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (36, '25', 'Fiona', 'Quilliam', 'fquilliamz@yahoo.com', '896-467-8808', 'CafeCoin', '2024-06-29', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (37, '39', 'Eunice', 'Collen', 'ecollen10@multiply.com', '819-779-0335', 'Store', '2024-07-28', false);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (38, '32', 'Serena', 'Bailes', 'sbailes11@ihg.com', '169-342-7899', 'CafeCoin', '2024-04-18', false);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (39, '36', 'Dawna', 'Benediktovich', 'dbenediktovich12@fotki.com', '904-322-4593', 'Store', '2024-04-22', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (40, '4', 'Con', 'Mourgue', 'cmourgue13@cbsnews.com', '214-500-0406', 'CafeCoin', '2024-06-14', false);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (41, '7', 'Grete', 'Harrowell', 'gharrowell14@spotify.com', '254-227-2704', 'CafeCoin', '2024-08-09', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (42, '15', 'Paule', 'Vayne', 'pvayne15@mozilla.com', '161-997-6939', 'CafeCoin', '2025-01-01', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (43, '20', 'Torrence', 'Bowser', 'tbowser16@ucoz.ru', '610-109-6939', 'Store', '2024-08-10', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (44, '24', 'Armand', 'Hanmore', 'ahanmore17@prweb.com', '699-860-7354', 'CafeCoin', '2025-03-11', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (45, '32', 'Sadye', 'Scamal', 'sscamal18@sohu.com', '775-861-4980', 'CafeCoin', '2024-11-25', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (46, '12', 'Augy', 'Godsal', 'agodsal19@ovh.net', '962-399-9210', 'CafeCoin', '2024-10-28', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (47, '30', 'Mil', 'Nanuccioi', 'mnanuccioi1a@dropbox.com', '322-459-1610', 'Store', '2025-03-03', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (48, '16', 'Jonis', 'Cushion', 'jcushion1b@ow.ly', '582-500-5138', 'CafeCoin', '2025-01-04', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (49, '21', 'Raynard', 'Rayson', 'rrayson1c@yandex.ru', '547-855-1371', 'CafeCoin', '2024-10-08', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (50, '35', 'Donetta', 'Bottinelli', 'dbottinelli1d@ezinearticles.com', '188-206-9169', 'Store', '2025-01-21', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (51, '10', 'Francine', 'Asals', 'fasals1e@wordpress.com', '905-112-1148', 'CafeCoin', '2024-12-09', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (52, '19', 'Rozamond', 'Beecham', 'rbeecham1f@unesco.org', '410-307-9092', 'Store', '2024-10-16', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (53, '4', 'Adiana', 'Kilban', 'akilban1g@sciencedaily.com', '667-685-0711', 'CafeCoin', '2024-09-17', false);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (54, '37', 'Mandie', 'Ruoss', 'mruoss1h@disqus.com', '975-114-8281', 'CafeCoin', '2024-07-08', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (55, '40', 'Eldon', 'Wyvill', 'ewyvill1i@reddit.com', '604-972-6866', 'Store', '2024-07-22', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (56, '33', 'Sue', 'Bryett', 'sbryett1j@bigcartel.com', '665-819-4839', 'Store', '2024-08-06', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (57, '27', 'Willyt', 'Newby', 'wnewby1k@drupal.org', '743-643-9910', 'CafeCoin', '2024-12-08', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (58, '22', 'Ronna', 'Camm', 'rcamm1l@blog.com', '244-744-6988', 'Store', '2025-01-20', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (59, '17', 'Mariya', 'McGrath', 'mmcgrath1m@nps.gov', '428-754-3915', 'CafeCoin', '2025-02-28', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (60, '1', 'Lorie', 'Fears', 'lfears1n@i2i.jp', '826-405-4224', 'Store', '2025-03-13', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (61, '23', 'Hercule', 'Shadrach', 'hshadrach1o@si.edu', '171-282-5851', 'CafeCoin', '2025-01-10', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (62, '2', 'Herta', 'Nolot', 'hnolot1p@123-reg.co.uk', '894-222-6944', 'CafeCoin', '2024-10-13', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (63, '18', 'Alys', 'Keiling', 'akeiling1q@hhs.gov', '830-539-0342', 'CafeCoin', '2025-04-02', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (64, '14', 'Clare', 'Verty', 'cverty1r@merriam-webster.com', '218-703-5963', 'CafeCoin', '2025-02-09', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (65, '25', 'Kati', 'Redler', 'kredler1s@addthis.com', '554-942-8266', 'CafeCoin', '2024-09-16', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (66, '26', 'Micky', 'Wissbey', 'mwissbey1t@paginegialle.it', '870-779-7889', 'CafeCoin', '2024-06-02', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (67, '34', 'Melicent', 'Phinnessy', 'mphinnessy1u@altervista.org', '602-426-8667', 'Store', '2024-07-25', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (68, '9', 'Derward', 'Whetnell', 'dwhetnell1v@mac.com', '503-963-0317', 'Store', '2024-11-13', false);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (69, '13', 'Thibaud', 'MacGahy', 'tmacgahy1w@rakuten.co.jp', '384-756-1545', 'CafeCoin', '2025-02-23', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (70, '11', 'Madelon', 'Rubega', 'mrubega1x@nydailynews.com', '906-219-9824', 'Store', '2024-10-20', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (71, '36', 'Katine', 'Weston', 'kweston1y@jimdo.com', '713-622-7957', 'CafeCoin', '2025-04-01', false);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (72, '31', 'Brandice', 'Walklot', 'bwalklot1z@drupal.org', '477-881-7953', 'Store', '2024-06-20', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (73, '38', 'Rochell', 'Courtin', 'rcourtin20@cdbaby.com', '253-734-2255', 'Store', '2024-06-02', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (74, '8', 'Elena', 'Clinton', 'eclinton21@diigo.com', '395-464-9490', 'CafeCoin', '2024-05-24', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (75, '5', 'Arlie', 'Boraston', 'aboraston22@com.com', '652-145-5378', 'CafeCoin', '2025-02-20', false);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (76, '3', 'Ramona', 'Deeks', 'rdeeks23@cbsnews.com', '104-817-9965', 'CafeCoin', '2024-05-11', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (77, '6', 'Cybil', 'Devil', 'cdevil24@ezinearticles.com', '160-901-9598', 'CafeCoin', '2024-07-09', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (78, '29', 'Rollins', 'Mealand', 'rmealand25@discuz.net', '846-183-2448', 'Store', '2024-04-21', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (79, '28', 'Basia', 'Newey', 'bnewey26@gnu.org', '425-455-3982', 'CafeCoin', '2025-01-24', true);
insert into Employees (EmployeeID, MerchantID, FirstName, LastName, Email, Phone, EmployeeType, StartDate, IsActive) values (80, '39', 'Stanislas', 'Scogin', 'sscogin27@ihg.com', '796-110-0184', 'CafeCoin', '2025-03-31', true);


-- DPM
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (1, '1', 'Mastercard', 'Mariam Furbank', '5048376235365506', '2025-06-13');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (2, '2', 'Amex', 'Agneta Larkby', '5048378257889983', '2028-03-18');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (3, '3', 'Visa', 'Lucita Icke', '5048376306089530', '2027-06-23');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (4, '4', 'Other', 'Georgena Antonomolii', '5108753537917951', '2027-06-15');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (5, '5', 'Visa', 'Odie Castagno', '5108758221757365', '2026-09-12');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (6, '6', 'Visa', 'Alano Hacking', '5108751924676040', '2027-07-04');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (7, '7', 'Other', 'Liva Borland', '5048372926539988', '2027-07-06');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (8, '8', 'Mastercard', 'Birk Goatman', '5108753419971746', '2025-06-25');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (9, '9', 'Mastercard', 'Golda Fobidge', '5048372923656009', '2028-04-18');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (10, '10', 'Mastercard', 'Doria Overthrow', '5108752850064086', '2028-08-22');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (11, '11', 'Visa', 'Rollin Banaszewski', '5048371926845668', '2026-12-12');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (12, '12', 'Other', 'Lockwood McGebenay', '5108754960991703', '2026-03-24');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (13, '13', 'Other', 'Cary Gibson', '5048371248954370', '2025-05-17');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (14, '14', 'Mastercard', 'Tuck Beaulieu', '5048370892400102', '2028-01-20');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (15, '15', 'Mastercard', 'Alverta Leall', '5108755739412269', '2026-09-20');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (16, '16', 'Visa', 'Lia Tumility', '5108750542045216', '2026-01-19');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (17, '17', 'Mastercard', 'Buddie Heinrici', '5108756014019332', '2028-05-11');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (18, '18', 'Amex', 'Ardyth O''Regan', '5108758884713069', '2026-05-11');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (19, '19', 'Amex', 'Sacha McPhee', '5108759362869720', '2028-08-11');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (20, '20', 'Mastercard', 'Griffith Olivelli', '5048376981313429', '2025-07-06');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (21, '21', 'Other', 'Dean Jamieson', '5108754334597707', '2027-04-22');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (22, '22', 'Amex', 'Consuela Haet', '5048376470125748', '2025-06-17');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (23, '23', 'Mastercard', 'Cher Handasyde', '5048372766548339', '2025-07-01');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (24, '24', 'Mastercard', 'Ninette Torbet', '5108751372976843', '2029-04-02');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (25, '25', 'Mastercard', 'Cindee Clilverd', '5108755089180805', '2025-09-03');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (26, '26', 'Mastercard', 'Sterne Elstone', '5048376147358185', '2027-08-14');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (27, '27', 'Other', 'Courtney Wooff', '5048376240387354', '2028-07-01');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (28, '28', 'Visa', 'Kassia Clemente', '5048377856365700', '2027-03-16');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (29, '29', 'Other', 'Michelle Toulson', '5108755586375387', '2027-04-29');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (30, '30', 'Amex', 'Emlyn Van Eeden', '5108750392035895', '2026-07-07');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (31, '31', 'Other', 'Carmine Rumgay', '5108755063951049', '2025-07-06');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (32, '32', 'Visa', 'Sara-ann Eginton', '5108759075293721', '2026-11-13');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (33, '33', 'Other', 'Quint Hasnip', '5048378275078189', '2028-07-26');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (34, '34', 'Other', 'Rosalind Letty', '5108757988292533', '2027-02-06');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (35, '35', 'Mastercard', 'Brittni Zanolli', '5048379990328917', '2028-11-08');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (36, '36', 'Amex', 'Padriac Pitson', '5108752677498590', '2028-01-05');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (37, '37', 'Other', 'Jana Couper', '5108758203297802', '2028-07-19');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (38, '38', 'Mastercard', 'Valaria Castro', '5108759828627746', '2027-12-12');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (39, '39', 'Visa', 'Huntley Moscone', '5108753863517102', '2028-12-25');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (40, '40', 'Other', 'Gibbie Marczyk', '5108757897851908', '2026-02-15');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (41, '1', 'Visa', 'Kailey Belfitt', '5048372454885894', '2027-03-13');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (42, '2', 'Other', 'Elton Pruce', '5048372959970274', '2026-01-28');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (43, '3', 'Amex', 'Mirilla Gallico', '5048377776093556', '2028-01-31');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (44, '4', 'Other', 'Lorie Sparey', '5048377231163564', '2027-12-26');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (45, '5', 'Other', 'Cookie Dabrowski', '5048379708343356', '2027-06-30');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (46, '6', 'Other', 'Keeley Sole', '5108757221846863', '2027-01-31');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (47, '7', 'Other', 'Zorine Sabbin', '5048370427057161', '2026-11-15');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (48, '8', 'Amex', 'Ranice Doust', '5048374581471317', '2025-06-25');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (49, '9', 'Other', 'Aron Lidgertwood', '5048379093840008', '2026-11-08');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (50, '10', 'Other', 'Nappie Ivel', '5108751849239734', '2028-08-29');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (51, '11', 'Other', 'Roxie Copcutt', '5108756090342384', '2027-07-28');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (52, '12', 'Visa', 'Jesse Cawsey', '5108753845043441', '2029-03-09');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (53, '13', 'Mastercard', 'Abby Scoles', '5108755905604178', '2028-12-15');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (54, '14', 'Mastercard', 'Florencia Liddle', '5108759895831791', '2026-11-05');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (55, '15', 'Other', 'Cathrin Eccleshall', '5048377062320473', '2027-04-11');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (56, '16', 'Visa', 'Mada Harvett', '5108757119685241', '2025-11-19');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (57, '17', 'Other', 'Tiffie Gotts', '5108759638263997', '2025-06-08');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (58, '18', 'Amex', 'Hanson Dionisii', '5048379223233165', '2028-07-07');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (59, '19', 'Other', 'Georgetta Figge', '5048373456029689', '2027-01-30');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (60, '20', 'Mastercard', 'Filia Iacobetto', '5108754892308828', '2026-07-26');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (61, '21', 'Amex', 'Jody Fysh', '5048377546091377', '2026-05-22');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (62, '22', 'Mastercard', 'Marcel Catton', '5108751137675946', '2026-01-30');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (63, '23', 'Visa', 'Harrietta Kyme', '5048372893884359', '2029-01-05');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (64, '24', 'Mastercard', 'Beret Humburton', '5048371430509412', '2026-05-23');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (65, '25', 'Mastercard', 'Marga Edmonson', '5048371118372695', '2029-03-23');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (66, '26', 'Visa', 'Aluin Gyles', '5048373743595161', '2027-08-15');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (67, '27', 'Mastercard', 'Robb Sakins', '5108750526015102', '2028-01-05');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (68, '28', 'Mastercard', 'Artur Mesant', '5108750399424381', '2025-09-20');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (69, '29', 'Amex', 'Odey Arnowicz', '5048373552799763', '2026-03-01');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (70, '30', 'Amex', 'Reena McLarnon', '5108751928871316', '2027-01-30');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (71, '31', 'Amex', 'Abby MacPake', '5048377186231374', '2027-11-29');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (72, '32', 'Mastercard', 'Selinda Willman', '5108754441837020', '2025-09-10');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (73, '33', 'Other', 'Arlana Poate', '5108757896934606', '2028-08-30');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (74, '34', 'Visa', 'Chantal Chitty', '5048371391128483', '2029-03-22');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (75, '35', 'Mastercard', 'Alvan Stode', '5048379746039958', '2027-01-24');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (76, '36', 'Visa', 'Jamie Ortells', '5108754812232751', '2028-08-30');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (77, '37', 'Visa', 'Austine Sarney', '5108753083668156', '2025-06-28');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (78, '38', 'Visa', 'Skippie Styan', '5048376558888985', '2027-01-19');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (79, '39', 'Amex', 'Hyacintha Klimkovich', '5048379136392611', '2027-09-23');
insert into DigitalPaymentMethods (MethodID, CustomerID, CardType, NameOnCard, CardNumber, Expiration) values (80, '40', 'Mastercard', 'Carol Haburne', '5108753378992055', '2027-09-18');

-- Transactions
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (1, '1', '33', 'card', null, '2024-06-22', 'purchase', 3.49);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (2, '2', '28', 'accountbalance', null, '2024-05-11', 'purchase', 29.94);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (3, '3', '40', 'card', null, '2024-08-28', 'purchase', 61.67);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (4, '4', '31', 'accountbalance', null, '2024-08-24', 'purchase', 54.12);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (5, '5', '25', 'accountbalance', null, '2024-10-13', 'purchase', 66.86);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (6, '6', '17', 'card', null, '2025-02-26', 'purchase', 16.7);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (7, '7', '27', 'accountbalance', null, '2024-08-31', 'purchase', 38.27);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (8, '8', '10', 'accountbalance', null, '2024-06-06', 'purchase', 34.37);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (9, '9', '12', 'card', null, '2024-06-16', 'purchase', 42.83);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (10, '10', '20', 'card', null, '2024-08-27', 'purchase', 62.01);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (11, '11', '1', 'accountbalance', null, '2024-08-01', 'purchase', 5.98);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (12, '12', '29', 'accountbalance', null, '2024-04-30', 'purchase', 7.14);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (13, '13', '2', 'accountbalance', null, '2024-09-07', 'purchase', 54.7);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (14, '14', '9', 'card', null, '2024-05-31', 'purchase', 81.7);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (15, '15', '5', 'accountbalance', null, '2024-10-03', 'purchase', 7.84);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (16, '16', '39', 'accountbalance', null, '2025-01-12', 'purchase', 99.22);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (17, '17', '21', 'accountbalance', null, '2025-02-10', 'purchase', 69.51);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (18, '18', '3', 'accountbalance', null, '2025-02-02', 'purchase', 32.68);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (19, '19', '32', 'card', null, '2025-01-14', 'balancereload', 96.61);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (20, '20', '36', 'accountbalance', null, '2025-03-25', 'purchase', 22.46);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (21, '21', '35', 'accountbalance', null, '2024-06-01', 'purchase', 79.04);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (22, '22', '7', 'accountbalance', null, '2024-11-09', 'purchase', 14.33);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (23, '23', '8', 'accountbalance', null, '2025-02-22', 'purchase', 83.31);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (24, '24', '4', 'accountbalance', null, '2024-11-13', 'purchase', 71.64);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (25, '25', '13', 'card', null, '2025-03-11', 'purchase', 22.93);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (26, '26', '11', 'card', null, '2024-08-20', 'purchase', 7.01);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (27, '27', '15', 'accountbalance', null, '2025-02-21', 'purchase', 39.33);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (28, '28', '16', 'card', null, '2024-11-27', 'purchase', 18.8);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (29, '29', '22', 'accountbalance', null, '2024-06-11', 'purchase', 7.16);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (30, '30', '14', 'accountbalance', null, '2024-04-12', 'purchase', 98.15);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (31, '31', '38', 'card', null, '2024-10-01', 'balancereload', 31.7);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (32, '32', '30', 'card', null, '2024-12-05', 'balancereload', 52.97);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (33, '33', '34', 'card', null, '2024-06-04', 'balancereload', 16.18);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (34, '34', '24', 'accountbalance', null, '2024-10-14', 'purchase', 24.85);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (35, '35', '18', 'accountbalance', null, '2025-01-03', 'purchase', 54.14);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (36, '36', '6', 'accountbalance', null, '2024-05-28', 'purchase', 60.17);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (37, '37', '23', 'accountbalance', null, '2024-05-22', 'purchase', 94.46);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (38, '38', '26', 'accountbalance', null, '2024-11-22', 'purchase', 83.34);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (39, '39', '37', 'accountbalance', null, '2024-05-23', 'purchase', 20.42);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (40, '40', '19', 'accountbalance', null, '2025-03-05', 'purchase', 15.46);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (41, '1', '27', 'card', null, '2025-01-08', 'purchase', 58.04);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (42, '2', '40', 'accountbalance', null, '2025-01-26', 'purchase', 29.99);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (43, '3', '39', 'accountbalance', null, '2024-05-05', 'purchase', 47.84);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (44, '4', '5', 'card', null, '2024-05-31', 'purchase', 9.87);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (45, '5', '12', 'accountbalance', null, '2024-09-23', 'purchase', 23.72);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (46, '6', '30', 'card', null, '2024-10-21', 'purchase', 47.05);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (47, '7', '26', 'accountbalance', null, '2025-03-08', 'purchase', 19.85);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (48, '8', '35', 'card', null, '2025-02-20', 'purchase', 52.65);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (49, '9', '21', 'accountbalance', null, '2024-06-14', 'purchase', 78.48);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (50, '10', '7', 'accountbalance', null, '2024-10-21', 'purchase', 39.73);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (51, '11', '37', 'accountbalance', null, '2024-06-14', 'purchase', 89.26);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (52, '12', '18', 'card', null, '2024-06-04', 'purchase', 52.75);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (53, '13', '16', 'card', null, '2024-11-28', 'purchase', 39.71);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (54, '14', '11', 'accountbalance', null, '2024-11-07', 'purchase', 59.01);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (55, '15', '6', 'card', null, '2024-06-28', 'balancereload', 89.34);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (56, '16', '14', 'accountbalance', null, '2024-12-10', 'purchase', 62.81);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (57, '17', '34', 'accountbalance', null, '2024-05-21', 'purchase', 23.72);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (58, '18', '3', 'accountbalance', null, '2024-07-10', 'purchase', 21.22);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (59, '19', '38', 'card', null, '2024-11-06', 'balancereload', 80.62);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (60, '20', '13', 'accountbalance', null, '2024-07-15', 'purchase', 98.48);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (61, '21', '25', 'accountbalance', null, '2025-02-21', 'purchase', 84.03);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (62, '22', '24', 'accountbalance', null, '2024-07-26', 'purchase', 89.57);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (63, '23', '28', 'accountbalance', null, '2024-06-23', 'purchase', 0.06);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (64, '24', '29', 'accountbalance', null, '2024-05-16', 'purchase', 84.02);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (65, '25', '9', 'card', null, '2024-10-10', 'purchase', 38.47);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (66, '26', '32', 'accountbalance', null, '2025-03-15', 'purchase', 8.28);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (67, '27', '36', 'card', null, '2024-05-25', 'purchase', 54.7);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (68, '28', '10', 'card', null, '2024-10-07', 'purchase', 11.06);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (69, '29', '22', 'card', null, '2025-02-08', 'purchase', 31.34);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (70, '30', '4', 'accountbalance', null, '2024-06-15', 'purchase', 87.77);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (71, '31', '23', 'accountbalance', null, '2024-06-01', 'purchase', 74.76);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (72, '32', '2', 'accountbalance', null, '2025-01-04', 'purchase', 62.69);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (73, '33', '15', 'card', null, '2024-05-01', 'purchase', 43.08);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (74, '34', '17', 'card', null, '2024-05-26', 'balancereload', 13.92);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (75, '35', '1', 'card', null, '2024-08-21', 'balancereload', 96.08);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (76, '36', '20', 'accountbalance', null, '2024-06-15', 'purchase', 92.16);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (77, '37', '19', 'accountbalance', null, '2024-10-23', 'purchase', 91.17);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (78, '38', '31', 'accountbalance', null, '2024-06-15', 'purchase', 51.64);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (79, '39', '33', 'accountbalance', null, '2024-12-26', 'purchase', 2.16);
insert into Transactions (TransactionID, CustomerID, MerchantID, PaymentMethod, CardUsed, Date, TransactionType, AmountPaid) values (80, '40', '8', 'accountbalance', null, '2025-03-17', 'purchase', 82.69);

-- MenuItems
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (1, '1', 'nulla nisl', 2.2, 'Quisque id justo sit amet sapien dignissim vestibulum.', 'Merchandise', true, false);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (2, '2', 'cubilia curae donec', 1.33, 'Morbi ut odio.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (3, '3', 'metus', 5.36, 'Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante.', 'Beverage', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (4, '4', 'vestibulum aliquet ultrices', 3.79, 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla.', 'Food', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (5, '5', 'libero convallis', 4.31, 'Aliquam erat volutpat.', 'Beverage', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (6, '6', 'sem mauris', 9.38, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi.', 'Food', true, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (7, '7', 'quisque porta', 3.55, 'Aliquam non mauris.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (8, '8', 'justo etiam pretium', 4.45, 'Nam nulla.', 'Merchandise', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (9, '9', 'pretium', 7.41, 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', 'Food', true, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (10, '10', 'quisque erat', 7.61, 'Proin risus.', 'Merchandise', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (11, '11', 'ligula sit amet', 8.07, 'Duis aliquam convallis nunc.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (12, '12', 'pharetra', 4.13, 'Duis consequat dui nec nisi volutpat eleifend.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (13, '13', 'erat vestibulum sed', 1.94, 'Etiam justo.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (14, '14', 'posuere', 3.9, 'In eleifend quam a odio.', 'Beverage', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (15, '15', 'luctus ultricies', 5.36, 'In quis justo.', 'Beverage', true, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (16, '16', 'vestibulum velit id', 7.92, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam.', 'Merchandise', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (17, '17', 'in eleifend', 4.08, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam.', 'Packaged', true, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (18, '18', 'ligula sit', 1.18, 'Cras non velit nec nisi vulputate nonummy.', 'Food', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (19, '19', 'felis ut', 4.6, 'Integer ac leo.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (20, '20', 'eu', 4.26, 'Suspendisse accumsan tortor quis turpis.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (21, '21', 'proin', 1.21, 'Suspendisse accumsan tortor quis turpis.', 'Food', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (22, '22', 'lectus aliquam sit', 2.56, 'Duis bibendum.', 'Food', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (23, '23', 'quam', 8.92, 'Proin eu mi.', 'Merchandise', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (24, '24', 'in porttitor', 8.16, 'Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante.', 'Beverage', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (25, '25', 'fusce congue diam', 4.89, 'Aenean fermentum.', 'Merchandise', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (26, '26', 'metus arcu adipiscing', 4.83, 'Vivamus vel nulla eget eros elementum pellentesque.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (27, '27', 'aliquet', 4.4, 'In est risus, auctor sed, tristique in, tempus sit amet, sem.', 'Beverage', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (28, '28', 'ante', 4.08, 'Integer ac leo.', 'Food', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (29, '29', 'velit', 3.21, 'Duis consequat dui nec nisi volutpat eleifend.', 'Beverage', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (30, '30', 'nulla eget', 9.67, 'Cras non velit nec nisi vulputate nonummy.', 'Merchandise', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (31, '31', 'eleifend', 1.47, 'Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (32, '32', 'faucibus cursus', 7.75, 'Donec ut dolor.', 'Beverage', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (33, '33', 'ornare', 7.82, 'Integer ac leo.', 'Beverage', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (34, '34', 'vel', 8.18, 'Nulla ut erat id mauris vulputate elementum.', 'Food', true, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (35, '35', 'dui maecenas tristique', 3.3, 'Praesent blandit lacinia erat.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (36, '36', 'aliquam quis', 8.5, 'Pellentesque eget nunc.', 'Merchandise', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (37, '37', 'auctor gravida sem', 2.79, 'Nulla mollis molestie lorem.', 'Merchandise', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (38, '38', 'sit', 4.57, 'Nunc rhoncus dui vel sem.', 'Beverage', true, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (39, '39', 'in porttitor pede', 1.22, 'Nullam porttitor lacus at turpis.', 'Packaged', false, false);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (40, '40', 'metus aenean', 6.77, 'Nulla tempus.', 'Beverage', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (41, '1', 'faucibus', 3.8, 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa.', 'Merchandise', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (42, '2', 'non ligula', 1.61, 'Morbi porttitor lorem id ligula.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (43, '3', 'tincidunt ante vel', 9.75, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (44, '4', 'consectetuer eget rutrum', 4.63, 'Duis mattis egestas metus.', 'Merchandise', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (45, '5', 'interdum venenatis turpis', 2.49, 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla.', 'Beverage', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (46, '6', 'ante', 9.73, 'Nulla ut erat id mauris vulputate elementum.', 'Beverage', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (47, '7', 'vestibulum', 6.11, 'Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', 'Merchandise', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (48, '8', 'vulputate elementum nullam', 7.66, 'Integer non velit.', 'Merchandise', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (49, '9', 'mauris sit amet', 7.96, 'Vestibulum rutrum rutrum neque.', 'Food', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (50, '10', 'sed ante', 9.55, 'Nulla tempus.', 'Food', true, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (51, '11', 'fusce lacus purus', 9.94, 'Aenean lectus.', 'Beverage', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (52, '12', 'quisque porta', 9.79, 'Donec semper sapien a libero.', 'Beverage', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (53, '13', 'vestibulum', 1.7, 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa.', 'Merchandise', false, false);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (54, '14', 'sollicitudin vitae consectetuer', 3.37, 'In hac habitasse platea dictumst.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (55, '15', 'vel', 1.0, 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (56, '16', 'nulla sed accumsan', 6.61, 'In sagittis dui vel nisl.', 'Food', true, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (57, '17', 'non pretium quis', 1.97, 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (58, '18', 'fermentum justo nec', 3.58, 'Pellentesque viverra pede ac diam.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (59, '19', 'eros elementum pellentesque', 5.19, 'Duis bibendum.', 'Packaged', false, false);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (60, '20', 'eget massa tempor', 5.65, 'Cras in purus eu magna vulputate luctus.', 'Merchandise', true, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (61, '21', 'ut at dolor', 9.65, 'Cras pellentesque volutpat dui.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (62, '22', 'lacinia aenean', 4.4, 'Pellentesque at nulla.', 'Beverage', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (63, '23', 'in purus eu', 4.0, 'Vestibulum ac est lacinia nisi venenatis tristique.', 'Beverage', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (64, '24', 'tempor turpis nec', 9.47, 'Vivamus tortor.', 'Food', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (65, '25', 'luctus nec', 9.78, 'In hac habitasse platea dictumst.', 'Packaged', false, false);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (66, '26', 'nunc nisl', 4.87, 'Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante.', 'Beverage', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (67, '27', 'justo etiam', 2.75, 'Morbi vel lectus in quam fringilla rhoncus.', 'Food', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (68, '28', 'neque', 8.32, 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante.', 'Food', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (69, '29', 'enim blandit', 3.56, 'Ut tellus.', 'Beverage', true, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (70, '30', 'augue', 9.65, 'Aenean auctor gravida sem.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (71, '31', 'sem sed sagittis', 8.0, 'Curabitur gravida nisi at nibh.', 'Beverage', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (72, '32', 'metus aenean', 9.08, 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (73, '33', 'aliquet pulvinar', 1.14, 'Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 'Merchandise', false, false);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (74, '34', 'malesuada in imperdiet', 5.5, 'Maecenas rhoncus aliquam lacus.', 'Beverage', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (75, '35', 'vulputate', 8.81, 'Mauris ullamcorper purus sit amet nulla.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (76, '36', 'commodo', 4.93, 'Vivamus vel nulla eget eros elementum pellentesque.', 'Beverage', true, false);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (77, '37', 'leo', 9.11, 'Nunc rhoncus dui vel sem.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (78, '38', 'ultrices mattis', 3.45, 'In est risus, auctor sed, tristique in, tempus sit amet, sem.', 'Merchandise', true, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (79, '39', 'amet', 5.3, 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', 'Packaged', false, true);
insert into MenuItems (ItemID, MerchantID, ItemName, CurrentPrice, Description, ItemType, IsRewardItem, IsActive) values (80, '40', 'odio justo', 9.64, 'Maecenas ut massa quis augue luctus tincidunt.', 'Packaged', false, true);

-- RewardItems
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (1, null, '29', '2024-04-15', '2058-11-24');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (2, null, '18', '2023-04-25', '2090-10-09');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (3, null, '12', '2024-01-08', '2060-07-20');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (4, null, '33', '2024-06-15', '2047-05-04');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (5, null, '11', '2024-09-26', '2048-03-14');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (6, null, '5', '2023-07-05', '2064-06-20');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (7, null, '20', '2024-08-28', '2062-07-08');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (8, null, '35', '2023-01-23', '2066-03-27');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (9, null, '14', '2023-11-10', '2091-07-14');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (10, null, '9', '2024-05-11', '2028-03-22');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (11, null, '32', '2023-02-10', '2087-02-18');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (12, null, '4', '2023-02-05', '2037-01-12');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (13, null, '22', '2024-12-29', '2057-04-08');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (14, null, '16', '2023-07-20', '2063-04-07');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (15, null, '2', '2024-02-20', '2071-10-05');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (16, null, '28', '2023-04-28', '2094-11-02');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (17, null, '7', '2024-08-30', '2073-01-26');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (18, null, '21', '2024-05-13', '2088-09-29');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (19, null, '15', '2023-05-30', '2092-05-16');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (20, null, '38', '2024-12-02', '2099-11-25');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (21, null, '10', '2025-02-20', '2043-12-21');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (22, null, '26', '2023-05-06', '2050-10-30');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (23, null, '30', '2024-10-25', '2036-10-30');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (24, null, '36', '2024-07-29', '2055-07-16');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (25, null, '39', '2023-08-24', '2032-05-05');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (26, null, '34', '2023-05-06', '2080-06-23');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (27, null, '19', '2023-03-18', '2089-04-02');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (28, null, '40', '2023-08-01', '2054-11-23');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (29, null, '6', '2023-01-19', '2095-06-22');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (30, null, '8', '2024-08-18', '2043-09-18');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (31, null, '25', '2023-09-05', '2037-03-21');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (32, null, '3', '2024-05-13', '2072-06-22');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (33, null, '31', '2023-12-09', '2105-02-10');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (34, null, '27', '2024-01-07', '2062-02-15');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (35, null, '13', '2024-10-08', '2094-09-22');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (36, null, '37', '2023-04-12', '2089-07-14');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (37, null, '17', '2023-05-10', '2099-03-08');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (38, null, '1', '2023-03-24', '2069-12-03');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (39, null, '23', '2024-04-03', '2081-09-11');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (40, null, '24', '2023-06-20', '2030-03-29');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (41, null, '26', '2025-03-08', '2093-05-21');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (42, null, '38', '2024-12-16', '2059-05-19');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (43, null, '40', '2024-08-25', '2093-10-26');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (44, null, '30', '2025-02-03', '2068-06-29');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (45, null, '2', '2023-09-11', '2030-04-02');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (46, null, '11', '2025-01-02', '2046-10-23');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (47, null, '12', '2023-05-20', '2072-07-18');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (48, null, '7', '2023-11-16', '2061-12-12');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (49, null, '14', '2023-05-08', '2036-09-28');
insert into RewardItems (RewardId, ItemId, MerchantId, StartDate, EndDate) values (50, null, '24', '2024-02-03', '2043-10-29');

-- Order Details
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (1, null, null, 49.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (2, null, null, 3.69, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (3, null, null, 5.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (4, null, null, 39.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (5, null, null, 0.89, true, 0.89);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (6, null, null, 25, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (7, null, null, 89, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (8, null, null, 49.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (9, null, null, 45.99, true, 45.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (10, null, null, 2.79, true, 2.79);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (11, null, null, 39.99, true, 39.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (12, null, null, 14.99, true, 14.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (13, null, null, 5.49, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (14, null, null, 15.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (15, null, null, 4.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (16, null, null, 4.79, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (17, null, null, 19.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (18, null, null, 79.99, true, 79.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (19, null, null, 14.99, true, 14.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (20, null, null, 1.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (21, null, null, 44.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (22, null, null, 29.99, true, 29.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (23, null, null, 1.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (24, null, null, 39.99, true, 39.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (25, null, null, 14.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (26, null, null, 99.99, true, 99.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (27, null, null, 39.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (28, null, null, 49.99, true, 49.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (29, null, null, 49.99, true, 49.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (30, null, null, 49.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (31, null, null, 1.99, true, 1.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (32, null, null, 5.49, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (33, null, null, 24.99, true, 24.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (34, null, null, 4.29, true, 4.29);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (35, null, null, 29.99, true, 29.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (36, null, null, 22.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (37, null, null, 24.99, true, 24.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (38, null, null, 4.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (39, null, null, 3.99, true, 3.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (40, null, null, 199.99, true, 199.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (41, null, null, 19.99, true, 19.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (42, null, null, 12.99, true, 12.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (43, null, null, 4.49, true, 4.49);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (44, null, null, 19.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (45, null, null, 29.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (46, null, null, 4.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (47, null, null, 3.99, true, 3.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (48, null, null, 39.99, true, 39.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (49, null, null, 299.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (50, null, null, 6.99, true, 6.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (51, null, null, 4.49, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (52, null, null, 39.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (53, null, null, 5.99, true, 5.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (54, null, null, 5.99, true, 5.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (55, null, null, 89.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (56, null, null, 22.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (57, null, null, 34.99, true, 34.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (58, null, null, 2.99, true, 2.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (59, null, null, 49.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (60, null, null, 3.99, true, 3.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (61, null, null, 7.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (62, null, null, 2.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (63, null, null, 3.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (64, null, null, 1.29, true, 1.29);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (65, null, null, 19.99, true, 19.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (66, null, null, 34.99, true, 34.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (67, null, null, 3.29, true, 3.29);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (68, null, null, 2.99, false, 0);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (69, null, null, 5.99, true, 5.99);
insert into OrderDetails (OrderItem#, TransactionId, ItemId, Price, RewardRedeemed, Discount) values (70, null, null, 3.29, true, 3.29);

-- ComplaintTickets
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (1, '32', '44', '2023-01-26', 'Order Delay', 'Order took longer than expected to arrive', 'In Progress', 'High');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (2, '10', '22', '2024-07-31', 'App Crash', 'App stopped working during use', 'Resolved', 'Critical');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (3, '19', '33', '2024-10-22', 'Wrong Order', 'Received incorrect item', 'Escalated', 'Urgent');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (4, '16', '47', '2023-03-01', 'Payment Issue', 'Problem occurred while processing payment', 'Closed', 'Low');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (5, '11', '62', '2023-12-25', 'Missing Items', 'Some items were missing from the order', 'Escalated', 'Medium');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (6, '6', '50', '2024-12-13', 'Order Delay', 'Order took longer than expected to arrive', 'Closed', 'Critical');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (7, '21', '20', '2024-06-16', 'App Crash', 'App stopped working during use', 'Escalated', 'High');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (8, '20', '58', '2023-07-08', 'Wrong Order', 'Received incorrect item', 'Escalated', 'Low');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (9, '8', '69', '2023-08-16', 'Payment Issue', 'Problem occurred while processing payment', 'Resolved', 'Medium');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (10, '4', '78', '2023-08-01', 'Missing Items', 'Some items were missing from the order', 'Open', 'Urgent');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (11, '5', '43', '2023-03-07', 'Order Delay', 'Order took longer than expected to arrive', 'Closed', 'Urgent');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (12, '14', '49', '2025-03-16', 'App Crash', 'App stopped working during use', 'Open', 'Critical');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (13, '38', '7', '2024-01-14', 'Wrong Order', 'Received incorrect item', 'Open', 'Urgent');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (14, '1', '15', '2024-02-15', 'Payment Issue', 'Problem occurred while processing payment', 'Escalated', 'Urgent');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (15, '36', '17', '2024-08-04', 'Missing Items', 'Some items were missing from the order', 'Resolved', 'Medium');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (16, '40', '55', '2023-10-23', 'Order Delay', 'Order took longer than expected to arrive', 'In Progress', 'Medium');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (17, '17', '60', '2024-11-30', 'App Crash', 'App stopped working during use', 'In Progress', 'Critical');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (18, '22', '65', '2024-02-01', 'Wrong Order', 'Received incorrect item', 'Open', 'Critical');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (19, '13', '2', '2023-07-23', 'Payment Issue', 'Problem occurred while processing payment', 'Resolved', 'Critical');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (20, '35', '13', '2023-10-08', 'Missing Items', 'Some items were missing from the order', 'Open', 'High');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (21, '24', '73', '2023-02-22', 'Order Delay', 'Order took longer than expected to arrive', 'In Progress', 'Medium');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (22, '2', '72', '2025-03-08', 'App Crash', 'App stopped working during use', 'Open', 'Low');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (23, '9', '31', '2023-03-17', 'Wrong Order', 'Received incorrect item', 'In Progress', 'Low');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (24, '3', '37', '2023-01-13', 'Payment Issue', 'Problem occurred while processing payment', 'Escalated', 'Low');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (25, '29', '56', '2024-06-11', 'Missing Items', 'Some items were missing from the order', 'In Progress', 'High');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (26, '34', '68', '2023-11-06', 'Order Delay', 'Order took longer than expected to arrive', 'Open', 'Critical');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (27, '23', '9', '2024-07-01', 'App Crash', 'App stopped working during use', 'Escalated', 'Low');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (28, '31', '59', '2024-02-20', 'Wrong Order', 'Received incorrect item', 'In Progress', 'Low');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (29, '7', '28', '2023-07-04', 'Payment Issue', 'Problem occurred while processing payment', 'Resolved', 'Urgent');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (30, '33', '3', '2025-02-16', 'Missing Items', 'Some items were missing from the order', 'Open', 'Urgent');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (31, '39', '54', '2023-03-07', 'Order Delay', 'Order took longer than expected to arrive', 'Resolved', 'Critical');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (32, '28', '4', '2024-04-24', 'App Crash', 'App stopped working during use', 'Resolved', 'Critical');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (33, '15', '16', '2024-10-13', 'Wrong Order', 'Received incorrect item', 'Open', 'Critical');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (34, '27', '70', '2023-10-22', 'Payment Issue', 'Problem occurred while processing payment', 'Escalated', 'Medium');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (35, '25', '40', '2024-07-05', 'Missing Items', 'Some items were missing from the order', 'Closed', 'Medium');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (36, '37', '74', '2023-11-11', 'Order Delay', 'Order took longer than expected to arrive', 'Open', 'Urgent');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (37, '18', '6', '2023-05-26', 'App Crash', 'App stopped working during use', 'Escalated', 'High');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (38, '30', '21', '2025-01-11', 'Wrong Order', 'Received incorrect item', 'Open', 'Critical');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (39, '26', '1', '2023-05-10', 'Payment Issue', 'Problem occurred while processing payment', 'Open', 'Medium');
insert into ComplaintTickets (TicketId, CustomerId, AssignedToEmp, CreatedAt, Category, Description, Status, Priority) values (40, '12', '77', '2025-04-11', 'Missing Items', 'Some items were missing from the order', 'Open', 'Urgent');

-- Surveys
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (1, '36', 'What is your least favorite item?', '2023-08-24');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (2, '35', 'Do you feel the pricing is fair?', '2023-07-24');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (3, '24', 'What is your favorite menu item?', '2024-02-29');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (4, '1', 'What is your least favorite item?', '2023-02-15');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (5, '53', 'Have you used the CafeCoin rewards?', '2023-03-10');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (6, '80', 'How would you rate the value for your money?', '2023-01-26');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (7, '66', 'Any additional comments?', '2024-12-02');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (8, '50', 'What is your favorite menu item?', '2024-06-11');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (9, '52', 'Was the wait time acceptable?', '2024-06-15');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (10, '75', 'Are you satisfied with the loyalty program?', '2023-04-06');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (11, '31', 'How often do you visit this cafe?', '2024-07-27');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (12, '73', 'Do you follow us on social media?', '2023-02-12');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (13, '5', 'Do you order ahead or in-store?', '2024-08-13');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (14, '65', 'How would you rate the ambiance?', '2023-11-21');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (15, '79', 'Was the wait time acceptable?', '2023-12-11');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (16, '77', 'Was your mobile order ready on time?', '2023-02-20');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (17, '63', 'Do you order ahead or in-store?', '2024-05-11');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (18, '9', 'How often do you visit this cafe?', '2024-01-06');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (19, '15', 'Was your order prepared correctly?', '2024-05-25');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (20, '38', 'Was the wait time acceptable?', '2024-04-10');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (21, '46', 'Any additional comments?', '2023-04-22');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (22, '3', 'Any additional comments?', '2024-11-24');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (23, '64', 'Have you used the CafeCoin rewards?', '2024-11-13');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (24, '25', 'Do you find the app easy to use?', '2024-02-13');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (25, '22', 'How satisfied are you with the selection of drinks?', '2023-04-04');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (26, '14', 'Would you like to receive special birthday offers?', '2025-02-25');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (27, '62', 'Do you use digital payments?', '2023-07-30');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (28, '58', 'Would you attend a community coffee tasting?', '2024-11-09');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (29, '49', 'Have you encountered any technical issues with the app?', '2023-05-17');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (30, '19', 'What can we improve?', '2024-10-01');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (31, '10', 'Do you follow us on social media?', '2024-05-09');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (32, '67', 'Do you feel the pricing is fair?', '2023-12-01');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (33, '20', 'Do you feel CafeCoin adds value to your visits?', '2024-02-08');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (34, '60', 'Would you like more gluten-free options?', '2024-03-26');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (35, '11', 'Do you use digital payments?', '2023-01-27');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (36, '2', 'Would you like to see more local events at this cafe?', '2024-10-14');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (37, '40', 'How satisfied are you with your recent purchase?', '2024-10-02');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (38, '71', 'Are our hours of operation convenient?', '2023-05-02');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (39, '74', 'Would you prefer more seasonal items?', '2023-12-13');
insert into Surveys (SurveyId, CreatedByEmp, Question, DateSent) values (40, '41', 'Is the shop environment comfortable?', '2024-10-21');

-- SurveyResponses
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (1, 35, '12', 'The app is glitchy.', '2024-04-19');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (2, 22, '1', 'This location is always clean.', '2023-04-13');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (3, 14, '15', 'Excellent tea options!', '2025-01-07');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (4, 23, '30', 'This location is always clean.', '2023-11-16');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (5, 9, '32', 'Would love more promotions.', '2023-12-13');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (6, 31, '9', 'This is my go-to cafe.', '2023-04-06');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (7, 16, '27', 'Not user friendly.', '2024-02-04');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (8, 18, '21', 'It''s convenient and easy.', '2025-01-11');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (9, 24, '10', 'Too sweet for me.', '2024-08-18');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (10, 19, '6', 'I like the outdoor seating.', '2025-04-03');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (11, 22, '22', 'I like how fast it was.', '2024-08-12');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (12, 18, '5', 'The app is glitchy.', '2024-04-30');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (13, 11, '16', 'Love the rewards program.', '2025-02-05');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (14, 29, '20', 'Will definitely return!', '2023-03-24');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (15, 15, '28', 'My order was incorrect.', '2023-08-12');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (16, 34, '29', 'Love the new app update!', '2024-03-18');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (17, 3, '35', 'Everything was clean.', '2023-11-01');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (18, 1, '8', 'Too crowded.', '2024-09-02');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (19, 11, '7', 'Would love more promotions.', '2023-09-18');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (20, 30, '36', 'Would love more promotions.', '2023-11-07');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (21, 19, '4', 'More dairy-free milk options would be great.', '2025-04-06');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (22, 21, '14', 'Rewards take too long to earn.', '2023-04-03');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (23, 18, '26', 'It’s always busy here.', '2024-03-26');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (24, 19, '19', 'I didn’t know about the app.', '2023-03-05');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (25, 5, '25', 'Staff was incredibly kind!', '2023-11-21');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (26, 18, '18', 'The app is glitchy.', '2023-04-22');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (27, 21, '3', 'I like the outdoor seating.', '2024-11-21');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (28, 39, '31', 'I couldn’t find parking.', '2025-01-10');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (29, 10, '2', 'Love the rewards program.', '2023-10-30');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (30, 19, '23', 'I like how fast it was.', '2023-05-07');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (31, 12, '17', 'The coffee was perfect.', '2023-03-20');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (32, 10, '39', 'Would love more promotions.', '2024-09-25');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (33, 9, '38', 'The wifi didn’t work.', '2023-05-09');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (34, 30, '11', 'I come here every week.', '2025-02-06');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (35, 37, '24', 'Too crowded.', '2023-12-04');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (36, 40, '37', 'I love this place!', '2024-07-23');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (37, 25, '40', 'Didn’t get my receipt.', '2025-02-02');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (38, 11, '33', 'Excellent tea options!', '2023-04-29');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (39, 1, '13', 'Keep up the great work!', '2024-06-11');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (40, 28, '34', 'I prefer another shop nearby.', '2023-07-28');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (41, 17, '19', 'This is my go-to cafe.', '2023-01-25');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (42, 33, '35', 'I had to wait too long.', '2025-02-23');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (43, 2, '1', 'It’s always busy here.', '2024-07-17');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (44, 27, '24', 'Not enough seating.', '2024-03-23');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (45, 33, '9', 'Not enough seating.', '2025-02-24');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (46, 1, '4', 'I got my order quickly.', '2023-03-27');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (47, 11, '13', 'Perfect spot to study.', '2023-09-12');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (48, 37, '34', 'Too sweet for me.', '2024-01-25');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (49, 6, '7', 'Not enough seating.', '2024-07-22');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (50, 28, '30', 'Not enough seating.', '2024-09-17');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (51, 30, '21', 'I prefer another shop nearby.', '2025-02-11');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (52, 18, '31', 'Music was too loud.', '2024-05-13');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (53, 29, '36', 'It’s overpriced.', '2023-12-04');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (54, 21, '23', 'The wifi didn’t work.', '2023-11-09');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (55, 5, '25', 'Will definitely return!', '2024-03-07');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (56, 24, '40', 'Love the latte art!', '2024-02-19');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (57, 34, '28', 'It feels overpriced.', '2024-05-27');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (58, 14, '20', 'Didn’t get my receipt.', '2024-04-10');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (59, 27, '12', 'I would recommend it.', '2023-03-29');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (60, 17, '33', 'Not user friendly.', '2023-10-14');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (61, 6, '37', 'Will definitely return!', '2024-03-04');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (62, 34, '16', 'I’m not sure I’d return.', '2023-07-14');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (63, 31, '29', 'Rewards take too long to earn.', '2024-08-04');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (64, 24, '18', 'It’s always busy here.', '2023-12-18');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (65, 27, '22', 'I come here every week.', '2023-07-11');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (66, 16, '6', 'It’s overpriced.', '2024-09-22');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (67, 31, '10', 'The app is glitchy.', '2024-07-27');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (68, 34, '2', 'I got my order quickly.', '2024-01-22');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (69, 10, '14', 'This is my go-to cafe.', '2024-07-23');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (70, 1, '38', 'Service was slow.', '2024-12-04');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (71, 34, '17', 'Keep up the great work!', '2023-04-18');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (72, 7, '32', 'Love the new app update!', '2023-03-30');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (73, 9, '5', 'Payment process was smooth.', '2025-01-08');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (74, 2, '11', 'Payment process was smooth.', '2024-05-23');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (75, 27, '3', 'My order was incorrect.', '2024-12-29');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (76, 10, '27', 'I didn’t know about the app.', '2025-03-11');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (77, 9, '15', 'Keep up the great work!', '2023-08-02');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (78, 12, '39', 'I prefer another shop nearby.', '2025-01-24');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (79, 19, '8', 'Excellent tea options!', '2023-12-08');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (80, 27, '26', 'I love the seasonal drinks.', '2024-11-02');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (81, 25, '39', 'It’s overpriced.', '2023-04-14');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (82, 18, '17', 'I love the seasonal drinks.', '2025-04-04');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (83, 7, '31', 'More plant-based options please.', '2024-01-01');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (84, 30, '4', 'Love the community feel here.', '2023-12-10');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (85, 27, '12', 'Love the new app update!', '2023-02-05');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (86, 30, '5', 'Rewards take too long to earn.', '2023-11-25');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (87, 36, '38', 'It''s convenient and easy.', '2023-05-31');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (88, 39, '40', 'Everything was great!', '2023-10-14');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (89, 3, '35', 'Staff was incredibly kind!', '2023-07-29');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (90, 24, '32', 'Didn’t get my receipt.', '2023-02-03');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (91, 33, '15', 'Love the cozy vibe.', '2025-02-20');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (92, 13, '10', 'Please bring back the old menu.', '2023-02-25');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (93, 22, '14', 'I didn’t enjoy the latte.', '2024-10-13');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (94, 37, '2', 'Very cozy environment.', '2023-09-28');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (95, 39, '22', 'App crashed during checkout.', '2024-02-14');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (96, 12, '30', 'Will definitely return!', '2023-05-09');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (97, 7, '28', 'I love the seasonal drinks.', '2024-11-07');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (98, 38, '33', 'Please expand the vegan menu.', '2024-07-12');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (99, 12, '7', 'Too sweet for me.', '2023-12-13');
insert into SurveyResponses (ResponseId, SurveyId, CustomerId, Response, SubmitDate) values (100, 17, '29', 'Not user friendly.', '2024-11-27');

-- CustomerComms
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (1, '1', 'Promo', 'Limited-time offer or sale', '2024-08-13');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (2, '2', 'Update', 'Business or app changes', '2024-04-21');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (3, '3', 'Event', 'Upcoming in-store or virtual event', '2023-02-14');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (4, '4', 'Reminder', 'Friendly nudge for action', '2023-10-24');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (5, '5', 'Survey', 'Request for customer feedback', '2023-02-26');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (6, '6', 'Alert', 'Important or urgent notice', '2023-05-30');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (7, '7', 'Newsletter', 'Regular info and tips', '2023-01-28');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (8, '8', 'Discount', 'Price cut or special deal', '2023-12-15');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (9, '9', 'Thank You', 'Appreciation message', '2024-10-15');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (10, '10', 'Feature Launch', 'New feature or product release', '2024-04-11');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (11, '11', 'Promo', 'Limited-time offer or sale', '2024-05-12');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (12, '12', 'Update', 'Business or app changes', '2023-01-07');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (13, '13', 'Event', 'Upcoming in-store or virtual event', '2024-01-22');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (14, '14', 'Reminder', 'Friendly nudge for action', '2024-11-23');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (15, '15', 'Survey', 'Request for customer feedback', '2023-10-11');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (16, '16', 'Alert', 'Important or urgent notice', '2024-08-08');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (17, '17', 'Newsletter', 'Regular info and tips', '2023-07-12');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (18, '18', 'Discount', 'Price cut or special deal', '2024-07-25');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (19, '19', 'Thank You', 'Appreciation message', '2024-12-13');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (20, '20', 'Feature Launch', 'New feature or product release', '2023-05-07');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (21, '21', 'Promo', 'Limited-time offer or sale', '2023-08-22');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (22, '22', 'Update', 'Business or app changes', '2024-10-30');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (23, '23', 'Event', 'Upcoming in-store or virtual event', '2024-03-10');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (24, '24', 'Reminder', 'Friendly nudge for action', '2024-03-04');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (25, '25', 'Survey', 'Request for customer feedback', '2024-01-03');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (26, '26', 'Alert', 'Important or urgent notice', '2024-04-09');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (27, '27', 'Newsletter', 'Regular info and tips', '2023-11-08');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (28, '28', 'Discount', 'Price cut or special deal', '2024-12-26');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (29, '29', 'Thank You', 'Appreciation message', '2025-02-03');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (30, '30', 'Feature Launch', 'New feature or product release', '2023-08-13');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (31, '31', 'Promo', 'Limited-time offer or sale', '2025-01-31');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (32, '32', 'Update', 'Business or app changes', '2023-09-26');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (33, '33', 'Event', 'Upcoming in-store or virtual event', '2023-03-14');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (34, '34', 'Reminder', 'Friendly nudge for action', '2024-11-25');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (35, '35', 'Survey', 'Request for customer feedback', '2024-10-27');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (36, '36', 'Alert', 'Important or urgent notice', '2023-02-26');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (37, '37', 'Newsletter', 'Regular info and tips', '2025-04-03');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (38, '38', 'Discount', 'Price cut or special deal', '2024-01-17');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (39, '39', 'Thank You', 'Appreciation message', '2024-09-11');
insert into CustomerComms (PromoId, MerchantId, Type, Content, DateSent) values (40, '40', 'Feature Launch', 'New feature or product release', '2023-03-11');

-- CommsSubscribers
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('37', '8', '2025-04-01');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('7', '30', '2024-03-22');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('40', '38', '2023-07-11');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('9', '15', '2023-02-27');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('2', '6', '2025-03-01');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('12', '2', '2024-11-14');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('6', '10', '2025-03-27');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('21', '23', '2023-08-21');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('5', '1', '2025-04-11');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('35', '11', '2024-09-02');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('15', '35', '2024-03-25');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('10', '5', '2024-04-02');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('3', '37', '2023-12-20');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('34', '4', '2025-01-23');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('38', '33', '2024-01-18');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('28', '16', '2023-09-08');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('8', '22', '2025-03-18');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('25', '12', '2023-05-14');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('14', '40', '2025-03-05');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('24', '25', '2024-10-22');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('11', '36', '2023-11-03');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('30', '18', '2024-09-18');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('27', '14', '2024-04-27');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('39', '34', '2023-04-30');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('29', '32', '2023-10-05');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('31', '19', '2025-01-03');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('16', '31', '2023-08-18');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('33', '24', '2024-05-29');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('4', '29', '2023-02-22');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('17', '3', '2023-10-18');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('13', '39', '2025-02-18');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('23', '27', '2023-02-10');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('32', '21', '2023-06-28');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('20', '28', '2024-08-02');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('22', '20', '2023-12-16');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('36', '26', '2024-07-30');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('19', '13', '2023-08-12');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('1', '9', '2023-08-07');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('18', '7', '2024-12-30');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('26', '17', '2023-08-08');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('22', '7', '2024-11-23');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('18', '36', '2024-06-08');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('28', '30', '2023-07-02');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('27', '13', '2024-09-27');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('39', '10', '2024-08-12');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('37', '24', '2025-01-17');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('14', '23', '2024-11-29');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('12', '16', '2023-08-29');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('35', '12', '2024-06-14');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('15', '40', '2023-04-06');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('19', '32', '2025-03-11');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('25', '4', '2024-02-15');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('32', '33', '2023-08-22');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('38', '29', '2025-02-20');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('4', '26', '2024-06-29');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('36', '28', '2024-08-19');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('21', '8', '2023-06-17');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('2', '1', '2023-04-10');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('34', '25', '2024-11-06');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('7', '31', '2023-12-21');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('6', '3', '2024-12-04');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('33', '18', '2024-04-26');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('16', '37', '2024-04-03');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('8', '9', '2024-06-03');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('29', '20', '2023-12-15');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('20', '27', '2024-12-25');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('3', '11', '2023-04-09');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('9', '39', '2024-06-03');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('23', '38', '2024-08-20');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('11', '14', '2023-08-24');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('5', '5', '2023-09-27');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('40', '22', '2023-05-09');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('30', '15', '2024-02-24');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('1', '2', '2024-11-03');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('17', '35', '2023-09-16');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('31', '19', '2024-02-03');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('24', '34', '2023-05-28');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('13', '6', '2024-11-29');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('26', '21', '2024-12-07');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('10', '17', '2025-03-07');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('19', '10', '2023-11-23');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('16', '6', '2023-03-02');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('28', '31', '2023-02-03');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('35', '32', '2025-02-15');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('4', '36', '2024-04-02');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('30', '39', '2024-04-13');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('39', '7', '2025-02-16');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('15', '29', '2024-04-22');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('23', '16', '2023-07-12');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('1', '34', '2023-06-08');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('10', '30', '2025-01-06');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('24', '3', '2024-01-27');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('34', '21', '2024-07-31');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('5', '33', '2023-04-17');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('32', '37', '2025-01-18');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('8', '23', '2024-03-08');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('26', '35', '2024-03-27');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('20', '11', '2023-12-30');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('11', '28', '2024-12-04');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('27', '22', '2024-10-14');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('29', '40', '2023-09-29');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('2', '4', '2024-04-06');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('6', '27', '2024-05-10');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('9', '19', '2024-01-04');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('40', '17', '2024-02-12');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('14', '1', '2025-01-11');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('12', '14', '2023-02-18');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('13', '20', '2023-05-07');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('25', '18', '2024-05-17');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('7', '13', '2024-12-05');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('22', '15', '2024-08-24');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('38', '9', '2023-09-16');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('31', '24', '2023-01-03');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('37', '5', '2024-03-29');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('33', '2', '2023-08-10');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('17', '26', '2024-08-25');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('36', '38', '2024-11-22');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('18', '25', '2024-09-04');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('21', '8', '2023-06-27');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('3', '12', '2023-04-10');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('6', '20', '2023-07-13');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('19', '34', '2024-06-18');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('18', '15', '2024-12-31');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('4', '18', '2023-02-28');
insert into CommsSubscribers (CustomerId, MerchantId, DateSubscribed) values ('15', '23', '2023-07-05');

-- Leads
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (1, '23', 'Voolia', 'Lorrayne', 'Habberjam', 'lhabberjam0@blogs.com', '336-834-1151', '972 Fairview Circle', 'berkeley.edu/massa/quis.html', 'In Review', 'Forwarded deck', '2023-10-04', 42, 'Greensboro', 'North Carolina', 35820);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (2, '11', 'Wikizz', 'Yuri', 'Olennikov', 'yolennikov1@360.cn', '915-926-6576', '5488 Dawn Avenue', 'tinyurl.com/venenatis/tristique.jsp', 'Closed Lost', 'Interested in joining', '2023-09-16', 52, 'El Paso', 'Texas', 67294);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (3, '52', 'Lajo', 'Costanza', 'Yaneev', 'cyaneev2@springer.com', '719-675-6691', '7 Fremont Avenue', 'go.com/primis/in/faucibus/orci.html', 'New', 'Not the right time', '2024-08-20', 58, 'Colorado Springs', 'Colorado', 66356);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (4, '7', 'Oyoyo', 'Ferdinand', 'Hulk', 'fhulk3@barnesandnoble.com', '865-649-0953', '0 Ramsey Alley', 'buzzfeed.com/et/eros/vestibulum/ac/est/lacinia/nisi.jpg', 'New', 'Introduced to second decision-maker', '2023-11-14', 57, 'Knoxville', 'Tennessee', 87302);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (5, '27', 'Yodo', 'Honoria', 'Knolles-Green', 'hknollesgreen4@dmoz.org', '305-429-0646', '10 Del Sol Place', 'moonfruit.com/lectus.json', 'In Review', 'Needs Q2 launch', '2024-07-23', 64, 'Hialeah', 'Florida', 79802);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (6, '63', 'Devpulse', 'Rosalinda', 'McAvey', 'rmcavey5@multiply.com', '913-746-5763', '9 Everett Pass', 'independent.co.uk/massa/volutpat/convallis/morbi/odio/odio/elementum.json', 'Closed Won', 'Forwarded deck', '2024-04-02', 77, 'Shawnee Mission', 'Kansas', 29298);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (7, '26', 'Tazz', 'Ahmad', 'Hill', 'ahill6@usatoday.com', '304-103-1395', '3036 Crest Line Plaza', 'addthis.com/vulputate/nonummy/maecenas/tincidunt/lacus.jsp', 'Closed Lost', 'Sent intro email', '2024-11-11', 41, 'Charleston', 'West Virginia', 24089);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (8, '41', 'Bubblebox', 'Avrom', 'Matuszinski', 'amatuszinski7@npr.org', '432-251-6722', '75 Derek Park', 'over-blog.com/turpis/donec/posuere/metus/vitae.html', 'Contacted', 'Wants more examples', '2023-10-07', 100, 'Midland', 'Texas', 17201);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (9, '61', 'Realbuzz', 'Lorie', 'Daffey', 'ldaffey8@miibeian.gov.cn', '602-773-0257', '513 Gateway Pass', 'ihg.com/donec.html', 'In Review', 'Scheduled follow-up call', '2024-04-23', 23, 'Glendale', 'Arizona', 77589);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (10, '62', 'Fanoodle', 'Parnell', 'Bellew', 'pbellew9@yandex.ru', '571-193-3141', '99673 Laurel Alley', 'wp.com/amet/lobortis.html', 'In Review', 'Interested in free trial', '2025-02-19', 54, 'Alexandria', 'Virginia', 35585);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (11, '70', 'Demimbu', 'Cobb', 'Jacob', 'cjacoba@1688.com', '757-442-7948', '14 Riverside Alley', 'harvard.edu/erat/curabitur/gravida.aspx', 'Negotiating', 'Circle back next quarter', '2023-08-27', 59, 'Norfolk', 'Virginia', 31513);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (12, '66', 'Kamba', 'Emmeline', 'Cotelard', 'ecotelardb@pen.io', '404-304-0148', '53058 Butterfield Terrace', 'cdbaby.com/augue.png', 'Negotiating', 'Interested in joining', '2025-01-22', 3, 'Decatur', 'Georgia', 14779);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (13, '57', 'Topicware', 'Christophe', 'Kenshole', 'ckensholec@state.gov', '318-658-7837', '3 Crest Line Terrace', 'japanpost.jp/mi/pede/malesuada/in.aspx', 'Contacted', 'Opened email no reply', '2023-12-30', 21, 'Monroe', 'Louisiana', 75551);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (14, '35', 'Topicshots', 'Bernie', 'Dolby', 'bdolbyd@nyu.edu', '860-753-9969', '17 Eastwood Road', 'photobucket.com/diam/nam/tristique.aspx', 'Negotiating', 'No answer on call', '2024-06-27', 49, 'Hartford', 'Connecticut', 70335);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (15, '78', 'Mybuzz', 'Magda', 'Wisden', 'mwisdene@home.pl', '260-182-4775', '7029 Di Loreto Terrace', 'github.io/auctor.js', 'In Review', 'Said to reach back next week', '2024-08-02', 10, 'Fort Wayne', 'Indiana', 96055);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (16, '34', 'Lazz', 'Nehemiah', 'Anselm', 'nanselmf@whitehouse.gov', '202-897-2053', '794 Spohn Way', '163.com/ut/nulla/sed/accumsan.png', 'New', 'Shared use case', '2024-02-22', 4, 'Washington', 'District of Columbia', 70064);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (17, '9', 'Leexo', 'Gwendolin', 'Poulsen', 'gpoulseng@plala.or.jp', '804-860-5178', '997 Reinke Circle', 'drupal.org/nulla.aspx', 'Negotiating', 'Scheduled follow-up call', '2024-08-31', 91, 'Richmond', 'Virginia', 15226);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (18, '20', 'Topicstorm', 'Kean', 'Shadwick', 'kshadwickh@illinois.edu', '513-781-1151', '0012 Barnett Way', 'newyorker.com/habitasse/platea/dictumst/etiam/faucibus.png', 'Contacted', 'Asked for technical details', '2023-12-20', 50, 'Cincinnati', 'Ohio', 95541);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (19, '73', 'Roomm', 'Dredi', 'Augur', 'dauguri@trellian.com', '603-255-6759', '2 Kings Plaza', 'aol.com/tellus/nulla/ut/erat/id/mauris.jsp', 'In Review', 'Sent onboarding overview', '2024-12-30', 29, 'Manchester', 'New Hampshire', 55772);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (20, '77', 'Browsetype', 'Ignace', 'Manson', 'imansonj@soundcloud.com', '318-775-5623', '88776 Magdeline Circle', 'gravatar.com/pellentesque/eget/nunc/donec/quis/orci/eget.json', 'Closed Lost', 'Passed along to partner', '2024-04-19', 29, 'Shreveport', 'Louisiana', 87680);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (21, '50', 'Zoomzone', 'Ashlie', 'Mallam', 'amallamk@china.com.cn', '530-792-2342', '356 Scofield Street', 'arizona.edu/orci/mauris/lacinia/sapien/quis/libero/nullam.html', 'Contacted', 'Asked about custom plan', '2024-04-05', 72, 'Sacramento', 'California', 24928);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (22, '30', 'Ailane', 'Marline', 'Buche', 'mbuchel@census.gov', '404-928-4583', '6 Maple Wood Court', 'bbb.org/nisl/nunc/rhoncus.png', 'Negotiating', 'Sent intro email', '2024-08-31', 70, 'Atlanta', 'Georgia', 23679);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (23, '65', 'Feedmix', 'Bernete', 'Lots', 'blotsm@comcast.net', '201-459-4867', '39619 Hoffman Lane', 'apple.com/pulvinar/lobortis/est/phasellus/sit.jsp', 'Closed Lost', 'Needs executive buy-in', '2023-06-10', 82, 'Jersey City', 'New Jersey', 90251);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (24, '79', 'Dablist', 'Rem', 'Fintoph', 'rfintophn@opensource.org', '323-378-5165', '44 Merchant Way', 'princeton.edu/justo/nec/condimentum/neque.jpg', 'New', 'Rescheduled call', '2024-07-14', 39, 'Inglewood', 'California', 80668);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (25, '22', 'Nlounge', 'Ody', 'Pischoff', 'opischoffo@webnode.com', '404-132-1543', '46003 Fulton Avenue', 'stanford.edu/vel/nulla/eget/eros/elementum/pellentesque.aspx', 'Contacted', 'Not the right time', '2023-08-22', 31, 'Alpharetta', 'Georgia', 24904);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (26, '4', 'Gabcube', 'Alwin', 'Bushell', 'abushellp@eepurl.com', '205-665-2992', '4 Kim Park', 'aol.com/volutpat/dui/maecenas/tristique/est/et.png', 'In Review', 'Asked for technical details', '2024-03-08', 48, 'Birmingham', 'Alabama', 35464);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (27, '68', 'Pixoboo', 'Corrinne', 'Caudrey', 'ccaudreyq@nytimes.com', '806-611-4639', '4 Grasskamp Circle', 'usgs.gov/nullam/sit/amet.js', 'Contacted', 'Sent intro email', '2023-03-27', 38, 'Lubbock', 'Texas', 40942);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (28, '51', 'Feedmix', 'Willyt', 'Runsey', 'wrunseyr@creativecommons.org', '704-409-0437', '9916 Springview Drive', 'miitbeian.gov.cn/ligula/suspendisse/ornare/consequat/lectus/in/est.xml', 'Contacted', 'Rescheduled call', '2024-06-10', 93, 'Charlotte', 'North Carolina', 87505);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (29, '13', 'Lazzy', 'Amitie', 'Petchey', 'apetcheys@theatlantic.com', '559-237-3789', '8644 Sloan Street', 'jigsy.com/sapien/a.js', 'In Review', 'Said to reach back next week', '2024-07-23', 10, 'Fresno', 'California', 22610);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (30, '28', 'Flipstorm', 'Colette', 'Stone Fewings', 'cstonefewingst@pinterest.com', '281-268-1945', '775 Moose Court', 'phpbb.com/volutpat/sapien/arcu/sed/augue/aliquam.png', 'In Review', 'Asked for technical details', '2024-03-11', 92, 'Houston', 'Texas', 68699);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (31, '69', 'Brightdog', 'Vevay', 'Simpson', 'vsimpsonu@webmd.com', '516-601-1252', '2 Russell Terrace', 'theglobeandmail.com/odio/consequat/varius.html', 'New', 'Reviewing with manager', '2024-03-01', 58, 'Jamaica', 'New York', 12401);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (32, '59', 'Eare', 'Rodrick', 'Steanyng', 'rsteanyngv@icio.us', '717-932-9435', '72344 Pennsylvania Circle', 'ucla.edu/ipsum.aspx', 'New', 'Checking internal resources', '2025-01-20', 55, 'Lancaster', 'Pennsylvania', 49236);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (33, '54', 'Kayveo', 'Sigismond', 'O''Glassane', 'soglassanew@drupal.org', '408-686-1460', '37622 North Park', 'nsw.gov.au/non/interdum/in.jsp', 'Closed Won', 'Introduced to second decision-maker', '2023-04-05', 64, 'San Jose', 'California', 99209);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (34, '44', 'Oyoba', 'Marinna', 'Du Fray', 'mdufrayx@google.com.br', '702-784-0125', '2 Florence Place', 'booking.com/magnis/dis.png', 'Contacted', 'Needs legal review', '2023-02-01', 30, 'Las Vegas', 'Nevada', 19242);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (35, '5', 'Lajo', 'Henka', 'Pegram', 'hpegramy@squidoo.com', '727-373-0204', '0518 Anthes Street', 'xinhuanet.com/vehicula/condimentum.jsp', 'Negotiating', 'Requested pricing info', '2025-01-09', 81, 'Saint Petersburg', 'Florida', 88515);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (36, '71', 'Innotype', 'Gill', 'Whitewood', 'gwhitewoodz@nhs.uk', '480-111-0098', '7141 Moulton Way', 'ezinearticles.com/in/ante/vestibulum/ante/ipsum/primis.js', 'New', 'Shared use case', '2023-01-16', 87, 'Scottsdale', 'Arizona', 34794);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (37, '2', 'Livetube', 'Nancee', 'Darby', 'ndarby10@amazon.de', '515-331-5676', '6512 Dottie Pass', 'about.com/suspendisse/ornare.json', 'Negotiating', 'Scheduled follow-up call', '2024-05-07', 34, 'Des Moines', 'Iowa', 96920);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (38, '31', 'Yamia', 'Katti', 'Pithcock', 'kpithcock11@nifty.com', '303-259-0065', '8 Shasta Hill', 'imgur.com/ante.png', 'Contacted', 'Asked for technical details', '2023-01-13', 74, 'Boulder', 'Colorado', 70009);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (39, '45', 'Trilith', 'Felita', 'Owers', 'fowers12@gmpg.org', '718-581-3300', '41502 Summer Ridge Road', 'typepad.com/quam/turpis/adipiscing/lorem.xml', 'Negotiating', 'Requested pricing info', '2023-01-14', 20, 'Staten Island', 'New York', 19748);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (40, '48', 'Twinte', 'Birdie', 'Sapseed', 'bsapseed13@ihg.com', '706-967-8971', '108 Upham Drive', 'vimeo.com/eget/elit/sodales/scelerisque/mauris/sit.aspx', 'Contacted', 'Needs executive buy-in', '2023-06-29', 59, 'Cumming', 'Georgia', 82997);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (41, '42', 'Kazio', 'Fina', 'Brisley', 'fbrisley14@ocn.ne.jp', '410-691-7959', '9 Claremont Avenue', 'topsy.com/adipiscing.js', 'Closed Won', 'Wants to see case studies', '2024-11-30', 66, 'Baltimore', 'Maryland', 35931);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (42, '32', 'Realpoint', 'Merill', 'Cosens', 'mcosens15@tuttocitta.it', '510-157-8952', '74 Maryland Avenue', 'engadget.com/sit/amet/sem/fusce.html', 'Negotiating', 'Wants more examples', '2024-06-16', 8, 'Berkeley', 'California', 41353);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (43, '16', 'Kazio', 'Bevin', 'Cloy', 'bcloy16@reddit.com', '562-372-8822', '16496 Scoville Junction', 'seattletimes.com/eget.png', 'New', 'Negotiating pricing', '2025-02-17', 20, 'Los Angeles', 'California', 57445);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (44, '75', 'Camido', 'Robbyn', 'Strangman', 'rstrangman17@wikispaces.com', '202-808-8923', '9457 Heath Park', 'rediff.com/viverra/dapibus/nulla/suscipit.xml', 'In Review', 'Interested in joining', '2023-05-10', 97, 'Washington', 'District of Columbia', 19987);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (45, '56', 'Eidel', 'Elspeth', 'Sherar', 'esherar18@howstuffworks.com', '707-906-2555', '03 Buhler Alley', 'si.edu/vulputate/luctus/cum/sociis/natoque.jpg', 'Closed Won', 'Opened email no reply', '2023-05-17', 78, 'Petaluma', 'California', 67714);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (46, '47', 'Linklinks', 'Valaria', 'Isacke', 'visacke19@ibm.com', '210-295-4348', '005 Macpherson Parkway', 'nyu.edu/sapien/varius/ut/blandit/non.jsp', 'New', 'Interested in free trial', '2024-03-10', 32, 'San Antonio', 'Texas', 37743);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (47, '53', 'Feedfish', 'Merralee', 'Lamplough', 'mlamplough1a@wordpress.org', '205-805-9513', '9 Namekagon Crossing', 'google.fr/donec/posuere.js', 'Closed Won', 'Asked for technical details', '2023-02-23', 51, 'Birmingham', 'Alabama', 93243);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (48, '3', 'Demivee', 'Curtice', 'Arrowsmith', 'carrowsmith1b@e-recht24.de', '832-823-2555', '93745 Dennis Terrace', 'youku.com/aliquam/sit/amet/diam.jpg', 'In Review', 'Sent intro email', '2023-06-01', 6, 'Houston', 'Texas', 34030);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (49, '76', 'Plajo', 'Dasi', 'Waterstone', 'dwaterstone1c@hexun.com', '330-822-4741', '6 Dwight Center', 'nifty.com/non/mattis/pulvinar.json', 'Contacted', 'Asked about custom plan', '2024-08-27', 51, 'Akron', 'Ohio', 51665);
insert into Leads (LeadId, AssignedToEmp, BusinessName, OwnerFirst, OwnerLast, Email, PhoneNumber, Address, Website, Status, Notes, LastContactedAt, Suite, City, State, Zip) values (50, '80', 'Yadel', 'Towny', 'Lakey', 'tlakey1d@stanford.edu', '803-304-7785', '4 Carberry Point', 'altervista.org/nec/nisi/vulputate/nonummy/maecenas/tincidunt/lacus.js', 'Negotiating', 'Interested in free trial', '2023-01-27', 6, 'Columbia', 'South Carolina', 80066);

-- FraudTickets
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (1, '16', '2024-11-01', 'Duplicate transaction entries', 'Open');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (2, '42', '2024-07-02', 'Data tampering suspected', 'Awaiting Customer Response');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (3, '79', '2024-09-02', 'Unusual high-value transaction', 'Closed');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (4, '55', '2024-04-17', 'Data tampering suspected', 'Closed');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (5, '56', '2024-12-27', 'Data tampering suspected', 'Dismissed');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (6, '3', '2023-07-23', 'Multiple reports from same user', 'Dismissed');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (7, '54', '2023-08-19', 'Inconsistent location data', 'Escalated');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (8, '60', '2025-01-23', 'Complaints of unauthorized purchase', 'On Hold');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (9, '27', '2023-05-14', 'Sudden coin drain', 'Resolved');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (10, '61', '2023-08-27', 'Duplicate transaction entries', 'On Hold');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (11, '15', '2024-03-28', 'Order placed and canceled repeatedly', 'On Hold');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (12, '77', '2023-07-14', 'Multiple failed login attempts', 'Escalated');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (13, '57', '2025-02-18', 'System flagged abnormal usage', 'Open');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (14, '2', '2025-01-17', 'Sudden coin drain', 'Open');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (15, '64', '2023-03-09', 'Data tampering suspected', 'Dismissed');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (16, '20', '2024-11-14', 'Sudden coin drain', 'Escalated');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (17, '53', '2023-12-26', 'Reward item redeemed multiple times', 'Escalated');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (18, '10', '2024-08-13', 'System flagged abnormal usage', 'Resolved');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (19, '45', '2023-10-04', 'Data tampering suspected', 'Closed');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (20, '17', '2023-10-03', 'Customer denying transactions', 'Awaiting Customer Response');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (21, '4', '2024-03-10', 'Customer denying transactions', 'Awaiting Customer Response');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (22, '22', '2024-01-05', 'Data tampering suspected', 'Dismissed');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (23, '19', '2023-07-05', 'System flagged abnormal usage', 'Resolved');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (24, '65', '2025-01-27', 'Customer denying transactions', 'Escalated');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (25, '46', '2023-11-26', 'Multiple chargebacks', 'On Hold');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (26, '11', '2025-03-06', 'Card used in multiple cities', 'Awaiting Customer Response');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (27, '62', '2024-12-12', 'Customer denying transactions', 'On Hold');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (28, '76', '2024-12-13', 'Multiple chargebacks', 'Investigating');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (29, '25', '2023-10-08', 'Suspicious refund activity', 'Closed');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (30, '33', '2024-09-16', 'Account accessed from unknown device', 'Open');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (31, '36', '2024-10-21', 'Account accessed from unknown device', 'Closed');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (32, '23', '2023-03-12', 'Suspected fake account', 'Investigating');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (33, '30', '2023-04-06', 'Multiple failed login attempts', 'Open');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (34, '1', '2023-03-29', 'Duplicate transaction entries', 'On Hold');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (35, '12', '2023-09-18', 'Multiple chargebacks', 'Awaiting Customer Response');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (36, '38', '2025-01-18', 'Card used in multiple cities', 'Resolved');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (37, '49', '2025-03-10', 'Inconsistent location data', 'Dismissed');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (38, '34', '2024-01-08', 'Order placed and canceled repeatedly', 'Dismissed');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (39, '28', '2023-10-09', 'Multiple failed login attempts', 'On Hold');
insert into FraudTickets (TicketId, AssignedToEmp, CreatedAt, Description, Status) values (40, '63', '2024-02-13', 'Data tampering suspected', 'Awaiting Customer Response');

-- Alerts
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (1, '79', 'Staff Training Announcement', 'CafeCoin turns one – celebrate with us!', '2023-04-15', 'Support Team.', 'Open', 'Low');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (2, '23', 'System Maintenance', 'Limited-time offer available', '2024-07-07', 'Beta Testers', 'Investigating', 'High');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (3, '35', 'Delivery Area Expansion', 'Order ahead and skip the line.', '2023-09-10', 'Merchants', 'Investigating', 'Low');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (4, '19', 'Limited Time Offer', 'Refer a friend and earn coins', '2024-01-22', 'Employees', 'Open', 'Low');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (5, '12', 'Transaction Delay Alert', 'New merchant partners added', '2023-01-26', 'All Users', 'Dismissed', 'Low');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (6, '70', 'Data Usage Policy', 'System maintenance scheduled tonight', '2024-05-29', 'Customers', 'On Hold', 'Medium');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (7, '48', 'Coin Balance Adjustment', 'Limited-time offer available', '2023-09-28', 'All Users', 'On Hold', 'High');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (8, '5', 'Limited Time Offer', 'New rewards program launched', '2024-06-19', 'Support Team.', 'Dismissed', 'Medium');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (9, '38', 'Website Maintenance', 'Refer a friend and earn coins', '2024-05-14', 'New Users', 'On Hold', 'Low');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (10, '47', 'Holiday Schedule', 'We''ve updated our terms of service', '2023-08-04', 'Loyalty Members', 'Dismissed', 'Medium');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (11, '72', 'Loyalty Tier Adjustment', 'Order ahead and skip the line.', '2023-10-02', 'Loyalty Members', 'Closed', 'Medium');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (12, '42', 'Operating Hours Update', 'Welcome to CafeCoin!', '2024-08-31', 'Beta Testers', 'Open', 'Medium');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (13, '60', 'Rewards Expiry Notice', 'New merchant partners added', '2024-01-30', 'Merchants', 'Dismissed', 'High');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (14, '7', 'Service Interruption Notice', 'We''ve updated our terms of service', '2023-10-07', 'Merchants', 'Investigating', 'Medium');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (15, '24', 'Email Preferences Update.', 'New rewards program launched', '2024-01-13', 'Loyalty Members', 'Open', 'Low');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (16, '10', 'App Version Release', 'Stay safe: Avoid phishing scams', '2025-03-09', 'Employees', 'On Hold', 'Medium');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (17, '37', 'System Maintenance', 'Try our seasonal drinks!', '2025-02-24', 'Beta Testers', 'On Hold', 'Medium');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (18, '52', 'Feature Deactivation Notice', 'Order ahead and skip the line.', '2025-03-08', 'Merchants', 'Escalated', 'Low');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (19, '8', 'Temporary Feature Suspension', 'System maintenance scheduled tonight', '2023-09-05', 'All Users', 'On Hold', 'Low');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (20, '14', 'Coin Balance Adjustment', 'Order ahead and skip the line.', '2023-07-02', 'Customers', 'Open', 'High');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (21, '75', 'Account Verification Notice', 'Discount applied to your next purchase', '2023-10-12', 'Inactive Users', 'Awaiting Customer Response', 'Medium');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (22, '27', 'New Feature Launch', 'System maintenance scheduled tonight', '2024-01-27', 'Inactive Users', 'Investigating', 'Low');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (23, '58', 'Reward Limit Update', 'Refer a friend and earn coins', '2023-12-05', 'Support Team.', 'Resolved', 'High');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (24, '40', 'Scheduled Downtime', 'Faster support now available', '2023-09-13', 'Beta Testers', 'Open', 'High');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (25, '31', 'Transaction Delay Alert', 'New shop locations added', '2025-01-15', 'New Users', 'Open', 'Medium');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (26, '9', 'Data Usage Policy', 'Enjoy faster checkout with saved cards', '2023-12-08', 'Inactive Users', 'On Hold', 'High');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (27, '64', 'Loyalty Tier Adjustment', 'Check out your coin balance', '2023-03-24', 'Customers', 'On Hold', 'High');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (28, '62', 'App Version Release', 'New dashboard tools for merchants', '2024-11-05', 'Employees', 'Dismissed', 'Low');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (29, '32', 'Loyalty Tier Adjustment', 'Security settings changed', '2023-11-13', 'All Users', 'On Hold', 'High');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (30, '59', 'Email Preferences Update.', 'Don''t miss our spring event', '2025-03-17', 'Support Team.', 'Open', 'High');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (31, '6', 'Promo Code Alert', 'We''ve refreshed our menu!', '2024-02-14', 'Employees', 'Resolved', 'High');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (32, '33', 'App Version Release', 'Order ahead and skip the line.', '2024-10-16', 'Customers', 'Closed', 'High');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (33, '45', 'Temporary Feature Suspension', 'Account activity alert', '2023-04-14', 'New Users', 'Dismissed', 'Medium');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (34, '57', 'Subscription Reminder', 'Try our seasonal drinks!', '2023-06-28', 'Loyalty Members', 'Investigating', 'High');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (35, '80', 'New Store Opening', 'New shop locations added', '2023-06-23', 'All Users', 'Investigating', 'Low');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (36, '2', 'Temporary Feature Suspension', 'Reminder: Update your payment info', '2023-02-21', 'Support Team.', 'Dismissed', 'Medium');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (37, '36', 'Customer Support Downtime', 'New amenities added near you', '2023-10-28', 'New Users', 'Dismissed', 'Medium');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (38, '46', 'Feedback Survey Launch', 'CafeCoin turns one – celebrate with us!', '2023-09-05', 'Admins', 'Open', 'High');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (39, '11', 'Limited Time Offer', 'System maintenance scheduled tonight', '2024-07-09', 'Beta Testers', 'Investigating', 'High');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (40, '39', 'Feature Deactivation Notice', 'New feature: Order tracking', '2024-07-02', 'Inactive Users', 'Escalated', 'Low');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (41, '78', 'Temporary Feature Suspension', 'Welcome to CafeCoin!', '2023-10-11', 'Loyalty Members', 'Dismissed', 'Medium');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (42, '30', 'App Version Release', 'Community spotlight: Featured merchants', '2024-04-29', 'Inactive Users', 'Resolved', 'Low');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (43, '65', 'Operating Hours Update', 'We''ve refreshed our menu!', '2024-09-22', 'Employees', 'On Hold', 'Medium');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (44, '63', 'Auto-Reload Changes', 'CafeCoin turns one – celebrate with us!', '2024-04-10', 'Loyalty Members', 'Investigating', 'Medium');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (45, '49', 'Delivery Area Expansion', 'CafeCoin turns one – celebrate with us!', '2024-02-03', 'Support Team.', 'Resolved', 'Medium');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (46, '73', 'Bug Fix Announcement', 'New rewards program launched', '2024-01-31', 'Inactive Users', 'Closed', 'High');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (47, '51', 'Bug Fix Announcement', 'Your order has shipped', '2025-03-13', 'Customers', 'Dismissed', 'Low');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (48, '50', 'Limited Time Offer', 'You''re close to earning a reward!', '2024-06-22', 'Merchants', 'Awaiting Customer Response', 'High');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (49, '4', 'Loyalty Program Update', 'Account activity alert', '2024-09-09', 'Admins', 'Awaiting Customer Response', 'Medium');
insert into Alerts (AlertId, CreatedByEmp, Title, Message, SentAt, Audience, Status, Priority) values (50, '76', 'App Version Release', 'New amenities added near you', '2023-05-14', 'Support Team.', 'Resolved', 'High');

-- Amenities
insert into Amenities (AmenityId, Name, Description) values (1, 'Seasonal Menu', 'Temperature-controlled environment');
insert into Amenities (AmenityId, Name, Description) values (2, 'Fireplace Lounge', 'Soft lounge seating');
insert into Amenities (AmenityId, Name, Description) values (3, 'Gluten-Free', 'Drive-thru order and pickup service');
insert into Amenities (AmenityId, Name, Description) values (4, 'Organic Options', 'Soft lounge seating');
insert into Amenities (AmenityId, Name, Description) values (5, 'Loyalty Program', 'Designated tables for studying');
insert into Amenities (AmenityId, Name, Description) values (6, 'Open Late', 'Comfortable indoor seating');
insert into Amenities (AmenityId, Name, Description) values (7, 'Seasonal Menu', 'Drive-thru order and pickup service');
insert into Amenities (AmenityId, Name, Description) values (8, 'Air Conditioning', 'Bring your own cup for a discount');
insert into Amenities (AmenityId, Name, Description) values (9, 'Live Music', 'Self-service ordering kiosk');
insert into Amenities (AmenityId, Name, Description) values (10, 'Vegan', 'Comfortable indoor seating');
insert into Amenities (AmenityId, Name, Description) values (11, 'Open Late', 'Quiet area ideal for studying or work');
insert into Amenities (AmenityId, Name, Description) values (12, 'Fireplace Lounge', 'Fair trade certified coffee options');
insert into Amenities (AmenityId, Name, Description) values (13, 'Air Conditioning', 'Comfortable indoor seating');
insert into Amenities (AmenityId, Name, Description) values (14, 'Art Display', 'Soft lounge seating');
insert into Amenities (AmenityId, Name, Description) values (15, 'Wi-Fi', 'Rotating seasonal offerings');
insert into Amenities (AmenityId, Name, Description) values (16, 'Loyalty Program', 'Temperature-controlled environment');
insert into Amenities (AmenityId, Name, Description) values (17, 'Live Music', 'Access to rooftop seating or views');
insert into Amenities (AmenityId, Name, Description) values (18, 'Self-Serve Kiosk', 'Bulletin board for events and ads');
insert into Amenities (AmenityId, Name, Description) values (19, 'Fair Trade Coffee', 'USB and outlet charging stations');
insert into Amenities (AmenityId, Name, Description) values (20, 'Fireplace Lounge', 'Bulletin board for events and ads');
insert into Amenities (AmenityId, Name, Description) values (21, 'Indoor Seating', 'Earn rewards with purchases');
insert into Amenities (AmenityId, Name, Description) values (22, 'Barista Classes', 'Comfortable indoor seating');
insert into Amenities (AmenityId, Name, Description) values (23, 'Podcast Studio', 'Bulletin board for events and ads');
insert into Amenities (AmenityId, Name, Description) values (24, 'Podcast Studio', 'Soft lounge seating');
insert into Amenities (AmenityId, Name, Description) values (25, 'Podcast Studio', 'Quiet area ideal for studying or work');
insert into Amenities (AmenityId, Name, Description) values (26, 'Art Display', 'Locally roasted coffee beans');
insert into Amenities (AmenityId, Name, Description) values (27, 'Live Music', 'Changing table in restroom');
insert into Amenities (AmenityId, Name, Description) values (28, 'Seasonal Menu', 'Discount for students with ID');
insert into Amenities (AmenityId, Name, Description) values (29, 'Rooftop Access', 'Live music on select days');
insert into Amenities (AmenityId, Name, Description) values (30, 'Gluten-Free Pastries', 'Workshops to learn barista skills');
insert into Amenities (AmenityId, Name, Description) values (31, 'Free Samples', 'Bins for compostable waste');
insert into Amenities (AmenityId, Name, Description) values (32, 'Scenic Views', 'Wide selection of teas');
insert into Amenities (AmenityId, Name, Description) values (33, 'Charging Stations', 'Changing table in restroom');
insert into Amenities (AmenityId, Name, Description) values (34, 'Reusable Cups', 'Gluten-free pastries available');
insert into Amenities (AmenityId, Name, Description) values (35, 'Study Tables', 'Access to rooftop seating or views');
insert into Amenities (AmenityId, Name, Description) values (36, 'Live Music', 'Lounge area near a fireplace');
insert into Amenities (AmenityId, Name, Description) values (37, 'Student Discount', 'High-speed internet access for all customers');
insert into Amenities (AmenityId, Name, Description) values (38, 'Self-Serve Kiosk', 'Temperature-controlled environment');
insert into Amenities (AmenityId, Name, Description) values (39, 'Reusable Cups', 'Changing table in restroom');
insert into Amenities (AmenityId, Name, Description) values (40, 'Rooftop Access', 'Bulletin board for events and ads');

-- StoreAmenities
insert into StoreAmenities (AmenityId, MerchantId) values (13, '9');
insert into StoreAmenities (AmenityId, MerchantId) values (12, '15');
insert into StoreAmenities (AmenityId, MerchantId) values (5, '27');
insert into StoreAmenities (AmenityId, MerchantId) values (1, '34');
insert into StoreAmenities (AmenityId, MerchantId) values (7, '36');
insert into StoreAmenities (AmenityId, MerchantId) values (6, '3');
insert into StoreAmenities (AmenityId, MerchantId) values (4, '22');
insert into StoreAmenities (AmenityId, MerchantId) values (13, '37');
insert into StoreAmenities (AmenityId, MerchantId) values (10, '26');
insert into StoreAmenities (AmenityId, MerchantId) values (8, '25');
insert into StoreAmenities (AmenityId, MerchantId) values (14, '14');
insert into StoreAmenities (AmenityId, MerchantId) values (13, '5');
insert into StoreAmenities (AmenityId, MerchantId) values (3, '2');
insert into StoreAmenities (AmenityId, MerchantId) values (9, '40');
insert into StoreAmenities (AmenityId, MerchantId) values (11, '29');
insert into StoreAmenities (AmenityId, MerchantId) values (3, '18');
insert into StoreAmenities (AmenityId, MerchantId) values (10, '7');
insert into StoreAmenities (AmenityId, MerchantId) values (3, '28');
insert into StoreAmenities (AmenityId, MerchantId) values (6, '12');
insert into StoreAmenities (AmenityId, MerchantId) values (11, '1');
insert into StoreAmenities (AmenityId, MerchantId) values (12, '35');
insert into StoreAmenities (AmenityId, MerchantId) values (10, '6');
insert into StoreAmenities (AmenityId, MerchantId) values (9, '19');
insert into StoreAmenities (AmenityId, MerchantId) values (11, '23');
insert into StoreAmenities (AmenityId, MerchantId) values (2, '21');
insert into StoreAmenities (AmenityId, MerchantId) values (12, '33');
insert into StoreAmenities (AmenityId, MerchantId) values (9, '39');
insert into StoreAmenities (AmenityId, MerchantId) values (8, '11');
insert into StoreAmenities (AmenityId, MerchantId) values (10, '30');
insert into StoreAmenities (AmenityId, MerchantId) values (5, '38');
insert into StoreAmenities (AmenityId, MerchantId) values (12, '16');
insert into StoreAmenities (AmenityId, MerchantId) values (5, '10');
insert into StoreAmenities (AmenityId, MerchantId) values (7, '17');
insert into StoreAmenities (AmenityId, MerchantId) values (11, '4');
insert into StoreAmenities (AmenityId, MerchantId) values (1, '13');
insert into StoreAmenities (AmenityId, MerchantId) values (3, '8');
insert into StoreAmenities (AmenityId, MerchantId) values (10, '24');
insert into StoreAmenities (AmenityId, MerchantId) values (3, '31');
insert into StoreAmenities (AmenityId, MerchantId) values (15, '32');
insert into StoreAmenities (AmenityId, MerchantId) values (9, '20');
insert into StoreAmenities (AmenityId, MerchantId) values (5, '35');
insert into StoreAmenities (AmenityId, MerchantId) values (8, '31');
insert into StoreAmenities (AmenityId, MerchantId) values (9, '22');
insert into StoreAmenities (AmenityId, MerchantId) values (4, '17');
insert into StoreAmenities (AmenityId, MerchantId) values (12, '13');
insert into StoreAmenities (AmenityId, MerchantId) values (15, '2');
insert into StoreAmenities (AmenityId, MerchantId) values (1, '39');
insert into StoreAmenities (AmenityId, MerchantId) values (4, '5');
insert into StoreAmenities (AmenityId, MerchantId) values (2, '8');
insert into StoreAmenities (AmenityId, MerchantId) values (13, '11');
insert into StoreAmenities (AmenityId, MerchantId) values (9, '12');
insert into StoreAmenities (AmenityId, MerchantId) values (15, '34');
insert into StoreAmenities (AmenityId, MerchantId) values (3, '24');
insert into StoreAmenities (AmenityId, MerchantId) values (4, '7');
insert into StoreAmenities (AmenityId, MerchantId) values (2, '25');
insert into StoreAmenities (AmenityId, MerchantId) values (9, '18');
insert into StoreAmenities (AmenityId, MerchantId) values (1, '29');
insert into StoreAmenities (AmenityId, MerchantId) values (9, '14');
insert into StoreAmenities (AmenityId, MerchantId) values (9, '4');
insert into StoreAmenities (AmenityId, MerchantId) values (14, '6');
insert into StoreAmenities (AmenityId, MerchantId) values (1, '3');
insert into StoreAmenities (AmenityId, MerchantId) values (14, '38');
insert into StoreAmenities (AmenityId, MerchantId) values (13, '27');
insert into StoreAmenities (AmenityId, MerchantId) values (9, '33');
insert into StoreAmenities (AmenityId, MerchantId) values (5, '26');
insert into StoreAmenities (AmenityId, MerchantId) values (11, '28');
insert into StoreAmenities (AmenityId, MerchantId) values (7, '40');
insert into StoreAmenities (AmenityId, MerchantId) values (2, '15');
insert into StoreAmenities (AmenityId, MerchantId) values (7, '1');
insert into StoreAmenities (AmenityId, MerchantId) values (4, '9');
insert into StoreAmenities (AmenityId, MerchantId) values (6, '32');
insert into StoreAmenities (AmenityId, MerchantId) values (14, '20');
insert into StoreAmenities (AmenityId, MerchantId) values (15, '36');
insert into StoreAmenities (AmenityId, MerchantId) values (5, '23');
insert into StoreAmenities (AmenityId, MerchantId) values (11, '21');
insert into StoreAmenities (AmenityId, MerchantId) values (1, '30');
insert into StoreAmenities (AmenityId, MerchantId) values (11, '19');
insert into StoreAmenities (AmenityId, MerchantId) values (6, '10');
insert into StoreAmenities (AmenityId, MerchantId) values (4, '16');
insert into StoreAmenities (AmenityId, MerchantId) values (2, '37');
insert into StoreAmenities (AmenityId, MerchantId) values (7, '1');
insert into StoreAmenities (AmenityId, MerchantId) values (8, '30');
insert into StoreAmenities (AmenityId, MerchantId) values (8, '5');
insert into StoreAmenities (AmenityId, MerchantId) values (1, '10');
insert into StoreAmenities (AmenityId, MerchantId) values (2, '31');
insert into StoreAmenities (AmenityId, MerchantId) values (15, '39');
insert into StoreAmenities (AmenityId, MerchantId) values (6, '28');
insert into StoreAmenities (AmenityId, MerchantId) values (6, '20');
insert into StoreAmenities (AmenityId, MerchantId) values (14, '13');
insert into StoreAmenities (AmenityId, MerchantId) values (11, '12');
insert into StoreAmenities (AmenityId, MerchantId) values (14, '17');
insert into StoreAmenities (AmenityId, MerchantId) values (11, '22');
insert into StoreAmenities (AmenityId, MerchantId) values (9, '2');
insert into StoreAmenities (AmenityId, MerchantId) values (15, '36');
insert into StoreAmenities (AmenityId, MerchantId) values (14, '32');
insert into StoreAmenities (AmenityId, MerchantId) values (3, '37');
insert into StoreAmenities (AmenityId, MerchantId) values (8, '26');
insert into StoreAmenities (AmenityId, MerchantId) values (5, '35');
insert into StoreAmenities (AmenityId, MerchantId) values (9, '16');
insert into StoreAmenities (AmenityId, MerchantId) values (5, '9');
insert into StoreAmenities (AmenityId, MerchantId) values (12, '40');
insert into StoreAmenities (AmenityId, MerchantId) values (1, '33');
insert into StoreAmenities (AmenityId, MerchantId) values (9, '29');
insert into StoreAmenities (AmenityId, MerchantId) values (5, '24');
insert into StoreAmenities (AmenityId, MerchantId) values (7, '19');
insert into StoreAmenities (AmenityId, MerchantId) values (6, '21');
insert into StoreAmenities (AmenityId, MerchantId) values (11, '27');
insert into StoreAmenities (AmenityId, MerchantId) values (13, '7');
insert into StoreAmenities (AmenityId, MerchantId) values (8, '14');
insert into StoreAmenities (AmenityId, MerchantId) values (14, '25');
insert into StoreAmenities (AmenityId, MerchantId) values (6, '11');
insert into StoreAmenities (AmenityId, MerchantId) values (6, '8');
insert into StoreAmenities (AmenityId, MerchantId) values (9, '6');
insert into StoreAmenities (AmenityId, MerchantId) values (12, '18');
insert into StoreAmenities (AmenityId, MerchantId) values (7, '15');
insert into StoreAmenities (AmenityId, MerchantId) values (14, '3');
insert into StoreAmenities (AmenityId, MerchantId) values (8, '23');
insert into StoreAmenities (AmenityId, MerchantId) values (12, '4');
insert into StoreAmenities (AmenityId, MerchantId) values (3, '34');
insert into StoreAmenities (AmenityId, MerchantId) values (8, '38');
insert into StoreAmenities (AmenityId, MerchantId) values (7, '34');
insert into StoreAmenities (AmenityId, MerchantId) values (11, '1');
insert into StoreAmenities (AmenityId, MerchantId) values (2, '37');
insert into StoreAmenities (AmenityId, MerchantId) values (8, '29');
insert into StoreAmenities (AmenityId, MerchantId) values (10, '26');

-- CustAmentPref
insert into CustAmenityPrefs (AmenityId, CustomerId) values (6, '38');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (7, '8');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (12, '19');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (8, '15');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (10, '34');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (10, '4');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (13, '17');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (14, '25');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (14, '27');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (2, '16');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (15, '14');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (1, '29');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (8, '9');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (4, '39');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (3, '35');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (13, '36');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (2, '5');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (3, '10');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (8, '20');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (5, '2');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (4, '37');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (10, '1');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (4, '28');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (12, '13');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (1, '23');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (9, '30');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (7, '31');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (10, '22');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (2, '7');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (11, '11');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (14, '26');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (10, '32');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (2, '21');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (2, '3');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (8, '6');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (3, '40');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (10, '24');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (2, '18');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (8, '12');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (9, '33');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (4, '6');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (10, '40');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (7, '30');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (13, '39');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (10, '29');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (5, '37');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (2, '24');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (13, '27');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (10, '36');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (8, '28');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (12, '16');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (11, '11');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (10, '33');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (11, '9');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (3, '25');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (1, '20');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (14, '7');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (6, '32');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (13, '15');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (2, '22');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (3, '14');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (11, '12');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (15, '10');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (3, '23');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (2, '21');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (14, '17');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (9, '18');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (1, '2');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (4, '34');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (15, '19');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (11, '26');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (6, '3');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (13, '38');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (15, '31');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (13, '35');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (10, '4');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (5, '5');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (4, '13');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (6, '1');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (14, '8');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (6, '17');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (2, '16');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (7, '5');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (13, '24');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (14, '3');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (14, '15');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (6, '18');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (11, '26');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (8, '23');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (3, '29');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (2, '31');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (3, '6');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (4, '28');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (7, '4');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (14, '9');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (7, '37');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (14, '25');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (1, '33');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (7, '7');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (2, '10');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (7, '20');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (2, '13');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (1, '1');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (9, '30');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (12, '34');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (2, '35');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (13, '38');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (2, '36');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (15, '2');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (9, '27');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (5, '39');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (6, '21');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (8, '14');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (7, '11');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (1, '32');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (10, '12');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (5, '19');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (9, '22');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (4, '8');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (2, '40');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (12, '31');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (14, '32');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (12, '4');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (4, '29');
insert into CustAmenityPrefs (AmenityId, CustomerId) values (10, '23');
