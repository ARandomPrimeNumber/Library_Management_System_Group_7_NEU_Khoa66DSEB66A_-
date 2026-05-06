-- Create the DB
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
    ReaderID INT PRIMARY KEY,
    ReaderName VARCHAR(100),
    Address VARCHAR(255),
    PhoneNumber VARCHAR(15)
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
    BorrowID INT PRIMARY KEY,
    ReaderID INT,
    BookID INT,
    BorrowDate DATE,
    ReturnDate DATE,
    FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
);
