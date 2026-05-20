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
(1, 'User Alpha', AES_ENCRYPT('Sector 1, Node A', 'library_secret_key_2026'), AES_ENCRYPT('555-0101', 'library_secret_key_2026')),
(2, 'User Beta', AES_ENCRYPT('Sector 2, Node B', 'library_secret_key_2026'), AES_ENCRYPT('555-0102', 'library_secret_key_2026')),
(3, 'User Gamma', AES_ENCRYPT('Sector 3, Node C', 'library_secret_key_2026'), AES_ENCRYPT('555-0103', 'library_secret_key_2026')),
(4, 'User Delta', AES_ENCRYPT('Sector 4, Node D', 'library_secret_key_2026'), AES_ENCRYPT('555-0104', 'library_secret_key_2026')),
(5, 'User Epsilon', AES_ENCRYPT('Sector 5, Node E', 'library_secret_key_2026'), AES_ENCRYPT('555-0105', 'library_secret_key_2026'));

-- Insert into Books
INSERT INTO Books (BookID, BookName, AuthorID, PublishYear, Quantity, CategoryID) VALUES
(101, 'The Quantum Paradox', 1, 2021, 5, 1),
(102, 'Dragons of the Void', 2, 2019, 3, 2),
(103, 'Understanding Deep Learning', 3, 2023, 10, 5),
(104, 'The Silent Echo', 4, 2020, 2, 4),
(105, 'History of Tomorrow', 5, 2022, 7, 3),
(106, 'Cybernetic Horizons', 1, 2024, 4, 1);

-- Insert into Borrowing (DueDate = BorrowDate + 14 days)
INSERT INTO Borrowing (BorrowID, ReaderID, BookID, BorrowDate, DueDate, ReturnDate) VALUES
(1001, 1, 101, '2023-10-01', '2023-10-15', '2023-10-15'),
(1002, 2, 103, '2023-10-05', '2023-10-19', '2023-10-19'),
(1003, 3, 104, '2023-10-10', '2023-10-24', '2023-10-28'), -- Returned 4 days late
(1004, 1, 102, '2023-10-12', '2023-10-26', '2023-10-26'),
(1005, 4, 105, DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_SUB(CURDATE(), INTERVAL 6 DAY), NULL), -- Active borrow: ~6 days overdue
(1006, 5, 106, DATE_SUB(CURDATE(), INTERVAL 16 DAY), DATE_SUB(CURDATE(), INTERVAL 2 DAY), NULL); -- Active borrow: ~2 days overdue

-- Insert into Accounts
-- Passwords are hashed using SHA2-256. The Python app hashes user input before comparing.
INSERT INTO Accounts (Username, PasswordHash, Role, ReaderID) VALUES
('lib_admin', SHA2('hash_admin123', 256), 'Librarian', NULL),
('dev_tung', SHA2('hash_dev123', 256), 'BackendDev', NULL),
('reader_alpha', SHA2('hash_pass1', 256), 'Reader', 1),
('reader_beta', SHA2('hash_pass2', 256), 'Reader', 2),
('reader_gamma', SHA2('hash_pass3', 256), 'Reader', 3),
('reader_delta', SHA2('hash_pass4', 256), 'Reader', 4),
('reader_epsilon', SHA2('hash_pass5', 256), 'Reader', 5);

-- Insert sample fine record (borrow 1003 was returned 4 days late: 4 x 5000 = 20000 VND)
INSERT INTO FineLedger (BorrowID, ReaderID, FineAmount, FineDate) VALUES
(1003, 3, 20000, '2023-10-28');
