USE LibraryManagement;

-- ==============================================================================
-- 1. INDEXES
-- ==============================================================================
-- Optimize searching for books by their title
CREATE INDEX idx_books_title ON Books(BookName);

-- Optimize looking up borrowing history for a specific reader
CREATE INDEX idx_borrowing_reader ON Borrowing(ReaderID);

-- Optimize queries looking for unreturned books (where ReturnDate is NULL)
CREATE INDEX idx_borrowing_unreturned ON Borrowing(ReturnDate);


-- ==============================================================================
-- 2. VIEWS
-- ==============================================================================
-- View 1: Detailed view of all available books (joining Authors and Categories)
CREATE OR REPLACE VIEW vw_AvailableBooks AS
SELECT 
    b.BookID, 
    b.BookName, 
    a.AuthorName, 
    c.CategoryName, 
    b.PublishYear, 
    b.Quantity
FROM Books b
JOIN Authors a ON b.AuthorID = a.AuthorID
JOIN Categories c ON b.CategoryID = c.CategoryID
WHERE b.Quantity > 0;

-- View 2: Overdue Borrowing Records (uses stored DueDate column)
CREATE OR REPLACE VIEW vw_OverdueBorrows AS
SELECT 
    br.BorrowID,
    r.ReaderName,
    CAST(AES_DECRYPT(r.PhoneNumber, 'library_secret_key_2026') AS CHAR) AS PhoneNumber,
    b.BookName,
    br.BorrowDate,
    br.DueDate,
    DATEDIFF(CURDATE(), br.DueDate) AS DaysOverdue
FROM Borrowing br
JOIN Readers r ON br.ReaderID = r.ReaderID
JOIN Books b ON br.BookID = b.BookID
WHERE br.ReturnDate IS NULL 
AND br.DueDate < CURDATE();


-- ==============================================================================
-- 3. USER-DEFINED FUNCTIONS (UDF)
-- ==============================================================================
DELIMITER //

-- Function: Calculate Late Fine (e.g., 5000 currency units per day overdue)
DROP FUNCTION IF EXISTS fn_CalculateFine //
CREATE FUNCTION fn_CalculateFine(p_BorrowDate DATE, p_ReturnDate DATE) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_DaysBorrowed INT;
    DECLARE v_OverdueDays INT;
    DECLARE v_Fine INT DEFAULT 0;
    
    -- If not returned yet, calculate against current date
    IF p_ReturnDate IS NULL THEN
        SET v_DaysBorrowed = DATEDIFF(CURDATE(), p_BorrowDate);
    ELSE
        SET v_DaysBorrowed = DATEDIFF(p_ReturnDate, p_BorrowDate);
    END IF;
    
    SET v_OverdueDays = v_DaysBorrowed - 14; -- 14 days allowed
    
    IF v_OverdueDays > 0 THEN
        SET v_Fine = v_OverdueDays * 5000; -- Change 5000 to whatever fine amount you want
    END IF;
    
    RETURN v_Fine;
END //

DELIMITER ;


-- ==============================================================================
-- 4. STORED PROCEDURES
-- ==============================================================================
DELIMITER //

-- Procedure 1: Safely Borrow a Book
DROP PROCEDURE IF EXISTS sp_BorrowBook //
CREATE PROCEDURE sp_BorrowBook(
    IN p_ReaderID INT,
    IN p_BookID INT,
    OUT p_Message VARCHAR(100)
)
BEGIN
    DECLARE v_AvailableQuantity INT;
    
    -- Check if the book is available in stock
    SELECT Quantity INTO v_AvailableQuantity 
    FROM Books 
    WHERE BookID = p_BookID
    FOR UPDATE;
    
    IF v_AvailableQuantity > 0 THEN
        -- Insert into borrowing table (BorrowID is AUTO_INCREMENT)
        INSERT INTO Borrowing (ReaderID, BookID, BorrowDate, DueDate, ReturnDate) 
        VALUES (p_ReaderID, p_BookID, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), NULL);
        
        SET p_Message = 'Book borrowed successfully.';
    ELSE
        SET p_Message = 'Error: Book is currently out of stock.';
    END IF;
END //

-- Procedure 2: Safely Return a Book
DROP PROCEDURE IF EXISTS sp_ReturnBook //
CREATE PROCEDURE sp_ReturnBook(
    IN p_BorrowID INT,
    OUT p_Message VARCHAR(100),
    OUT p_FineAmount INT
)
BEGIN
    DECLARE v_BorrowDate DATE;
    DECLARE v_ReturnDate DATE;
    DECLARE v_ReaderID INT;
    
    -- Check if record exists and its return status
    SELECT BorrowDate, ReturnDate, ReaderID INTO v_BorrowDate, v_ReturnDate, v_ReaderID 
    FROM Borrowing 
    WHERE BorrowID = p_BorrowID;
    
    IF v_BorrowDate IS NULL THEN
        SET p_Message = 'Error: Borrow record not found.';
        SET p_FineAmount = 0;
    ELSEIF v_ReturnDate IS NOT NULL THEN
        SET p_Message = 'Error: Book has already been returned.';
        SET p_FineAmount = 0;
    ELSE
        -- Update the return date to today
        UPDATE Borrowing 
        SET ReturnDate = CURDATE() 
        WHERE BorrowID = p_BorrowID;
        
        -- Calculate fine using our UDF
        SET p_FineAmount = fn_CalculateFine(v_BorrowDate, CURDATE());
        
        -- Log the fine in the FineLedger if overdue
        IF p_FineAmount > 0 THEN
            INSERT INTO FineLedger (BorrowID, ReaderID, FineAmount, FineDate)
            VALUES (p_BorrowID, v_ReaderID, p_FineAmount, CURDATE());
        END IF;
        
        SET p_Message = 'Book returned successfully.';
    END IF;
END //

-- Procedure 3: Register a New Reader (App Account + Reader Profile)
DROP PROCEDURE IF EXISTS sp_RegisterReader //
CREATE PROCEDURE sp_RegisterReader(
    IN p_Username VARCHAR(50),
    IN p_PasswordHash VARCHAR(255),
    IN p_ReaderName VARCHAR(100),
    IN p_Address VARCHAR(255),
    IN p_PhoneNumber VARCHAR(15),
    OUT p_Message VARCHAR(100)
)
BEGIN
    DECLARE v_NewReaderID INT;
    DECLARE v_UserExists INT;
    
    -- Check if username is already taken
    SELECT COUNT(*) INTO v_UserExists FROM Accounts WHERE Username = p_Username;
    
    IF v_UserExists > 0 THEN
        SET p_Message = 'Error: Username already exists.';
    ELSE
        -- ReaderID is AUTO_INCREMENT; no manual ID generation needed
        INSERT INTO Readers (ReaderName, Address, PhoneNumber)
        VALUES (p_ReaderName, AES_ENCRYPT(p_Address, 'library_secret_key_2026'), AES_ENCRYPT(p_PhoneNumber, 'library_secret_key_2026'));
        
        SET v_NewReaderID = LAST_INSERT_ID();
        
        -- Insert the Login Account
        INSERT INTO Accounts (Username, PasswordHash, Role, ReaderID)
        VALUES (p_Username, p_PasswordHash, 'Reader', v_NewReaderID);
        
        SET p_Message = 'Reader registered successfully.';
    END IF;
END //

-- Procedure 4: Delete Reader Account (Revokes Login Access)
DROP PROCEDURE IF EXISTS sp_DeleteReaderAccount //
CREATE PROCEDURE sp_DeleteReaderAccount(
    IN p_AccountID INT,
    OUT p_Message VARCHAR(100)
)
BEGIN
    DECLARE v_AccountExists INT;
    
    SELECT COUNT(*) INTO v_AccountExists FROM Accounts WHERE AccountID = p_AccountID;
    
    IF v_AccountExists = 0 THEN
        SET p_Message = 'Error: Account not found.';
    ELSE
        -- We only delete the Account (login credentials). 
        -- The Reader profile stays intact to preserve the library's borrowing history.
        DELETE FROM Accounts WHERE AccountID = p_AccountID;
        SET p_Message = 'Account deleted successfully.';
    END IF;
END //

DELIMITER ;


-- ==============================================================================
-- 5. TRIGGERS
-- ==============================================================================
DELIMITER //

-- Trigger 1: Auto-Decrease book quantity when a book is borrowed
DROP TRIGGER IF EXISTS trg_AfterBorrow //
CREATE TRIGGER trg_AfterBorrow
AFTER INSERT ON Borrowing
FOR EACH ROW
BEGIN
    IF NEW.ReturnDate IS NULL THEN
        UPDATE Books 
        SET Quantity = Quantity - 1 
        WHERE BookID = NEW.BookID;
    END IF;
END //

-- Trigger 2: Auto-Increase book quantity when a book is returned
DROP TRIGGER IF EXISTS trg_AfterReturn //
CREATE TRIGGER trg_AfterReturn
AFTER UPDATE ON Borrowing
FOR EACH ROW
BEGIN
    -- If ReturnDate changes from NULL to a specific date
    IF OLD.ReturnDate IS NULL AND NEW.ReturnDate IS NOT NULL THEN
        UPDATE Books 
        SET Quantity = Quantity + 1 
        WHERE BookID = NEW.BookID;
    END IF;
END //

DELIMITER ;
