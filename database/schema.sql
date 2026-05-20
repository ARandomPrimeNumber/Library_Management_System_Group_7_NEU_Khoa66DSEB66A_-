-- Create the database
CREATE DATABASE IF NOT EXISTS LibraryManagement;
USE LibraryManagement;

-- 1. Create Categories Table
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100)
);

-- 2. Create Authors Table
CREATE TABLE Authors (
    AuthorID INT PRIMARY KEY,
    AuthorName VARCHAR(100)
);

-- 3. Create Readers Table
CREATE TABLE Readers (
    ReaderID INT PRIMARY KEY AUTO_INCREMENT,
    ReaderName VARCHAR(100),
    Address VARBINARY(255),
    PhoneNumber VARBINARY(255)
);

-- 4. Create Books Table (References Authors and Categories)
CREATE TABLE Books (
    BookID INT PRIMARY KEY,
    BookName VARCHAR(200),
    AuthorID INT,
    PublishYear INT,
    Quantity INT,
    CategoryID INT,
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- 5. Create Borrowing Table (References Readers and Books)
CREATE TABLE Borrowing (
    BorrowID INT PRIMARY KEY AUTO_INCREMENT,
    ReaderID INT,
    BookID INT,
    BorrowDate DATE,
    DueDate DATE,
    ReturnDate DATE,
    FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
);

-- 6. Create Accounts Table (Application-level logins)
CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY AUTO_INCREMENT,
    Username VARCHAR(50) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Role ENUM('Librarian', 'Reader') NOT NULL,
    ReaderID INT,
    FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID)
);

-- 7. Create Fine Ledger Table (Persistent record of fines charged on return)
CREATE TABLE FineLedger (
    FineID INT PRIMARY KEY AUTO_INCREMENT,
    BorrowID INT NOT NULL,
    ReaderID INT NOT NULL,
    FineAmount INT NOT NULL,
    FineDate DATE NOT NULL,
    FOREIGN KEY (BorrowID) REFERENCES Borrowing(BorrowID),
    FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID)
);
