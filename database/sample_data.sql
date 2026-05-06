-- USE LibraryManagement database before inserting data
USE LibraryManagement;

-- ==========================================
-- INSERT DATA (5-10 records per table)
-- ==========================================

-- Insert into Categories
INSERT INTO Categories (CategoryID, CategoryName) VALUES
(1, 'Science Fiction'),
(2, 'Fantasy'),
(3, 'Non-Fiction'),
(4, 'Mystery'),
(5, 'Technology');

-- Insert into Authors
INSERT INTO Authors (AuthorID, AuthorName) VALUES
(1, 'Alex Mercer'),
(2, 'Jordan Sterling'),
(3, 'Casey Lin'),
(4, 'Riley Vance'),
(5, 'Morgan Thorne');

-- Insert into Readers
INSERT INTO Readers (ReaderID, ReaderName, Address, PhoneNumber) VALUES
(1, 'User Alpha', 'Sector 1, Node A', '555-0101'),
(2, 'User Beta', 'Sector 2, Node B', '555-0102'),
(3, 'User Gamma', 'Sector 3, Node C', '555-0103'),
(4, 'User Delta', 'Sector 4, Node D', '555-0104'),
(5, 'User Epsilon', 'Sector 5, Node E', '555-0105');

-- Insert into Books
INSERT INTO Books (BookID, BookName, AuthorID, PublishYear, Quantity, CategoryID) VALUES
(101, 'The Quantum Paradox', 1, 2021, 5, 1),
(102, 'Dragons of the Void', 2, 2019, 3, 2),
(103, 'Understanding Deep Learning', 3, 2023, 10, 5),
(104, 'The Silent Echo', 4, 2020, 2, 4),
(105, 'History of Tomorrow', 5, 2022, 7, 3),
(106, 'Cybernetic Horizons', 1, 2024, 4, 1);

-- Insert into Borrowing
INSERT INTO Borrowing (BorrowID, ReaderID, BookID, BorrowDate, ReturnDate) VALUES
(1001, 1, 101, '2023-10-01', '2023-10-15'),
(1002, 2, 103, '2023-10-05', '2023-10-19'),
(1003, 3, 104, '2023-10-10', '2023-10-24'),
(1004, 1, 102, '2023-10-12', '2023-10-26'),
(1005, 4, 105, '2023-10-15', NULL), -- NULL indicates it has not been returned yet
(1006, 5, 106, '2023-10-20', NULL);
