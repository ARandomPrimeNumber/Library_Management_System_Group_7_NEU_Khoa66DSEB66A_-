import hashlib
from src.db_connector import db
from src.config import AES_SECRET_KEY

def authenticate_user(username, password):
    """Check credentials against Accounts table."""
    password_hash = hashlib.sha256(password.encode()).hexdigest()
    query = "SELECT * FROM Accounts WHERE Username = %s AND PasswordHash = %s"
    result = db.execute_query(query, (username, password_hash))
    if result and len(result) > 0:
        return result[0]
    return None

def get_all_books():
    """Fetch all books using the vw_AvailableBooks view for simplicity, or Books table."""
    query = "SELECT * FROM vw_AvailableBooks"
    return db.execute_query(query)

def get_reader_profile(reader_id):
    """Fetch reader profile, decrypting Address and PhoneNumber natively in MySQL."""
    query = """
        SELECT 
            ReaderID, 
            ReaderName, 
            CAST(AES_DECRYPT(Address, %s) AS CHAR) AS Address,
            CAST(AES_DECRYPT(PhoneNumber, %s) AS CHAR) AS PhoneNumber
        FROM Readers
        WHERE ReaderID = %s
    """
    result = db.execute_query(query, (AES_SECRET_KEY, AES_SECRET_KEY, reader_id))
    if result and len(result) > 0:
        return result[0]
    return None

def get_reader_borrows(reader_id):
    """Fetch active (unreturned) borrows with due date, overdue status, and estimated fine."""
    query = """
        SELECT 
            br.BorrowID,
            b.BookName,
            br.BorrowDate,
            br.DueDate,
            DATEDIFF(CURDATE(), br.BorrowDate) AS DaysBorrowed,
            CASE WHEN br.DueDate < CURDATE() THEN 1 ELSE 0 END AS IsOverdue,
            GREATEST(DATEDIFF(CURDATE(), br.DueDate), 0) * 5000 AS EstimatedFine
        FROM Borrowing br
        JOIN Books b ON br.BookID = b.BookID
        WHERE br.ReaderID = %s AND br.ReturnDate IS NULL
    """
    return db.execute_query(query, (reader_id,))

def check_overdue_warning(reader_id):
    """Check if reader has any overdue borrows. Returns list of overdue items for login warning."""
    query = """
        SELECT 
            b.BookName,
            br.DueDate,
            DATEDIFF(CURDATE(), br.DueDate) AS DaysOverdue,
            DATEDIFF(CURDATE(), br.DueDate) * 5000 AS EstimatedFine
        FROM Borrowing br
        JOIN Books b ON br.BookID = b.BookID
        WHERE br.ReaderID = %s AND br.ReturnDate IS NULL AND br.DueDate < CURDATE()
    """
    return db.execute_query(query, (reader_id,))

def get_reader_fines(reader_id):
    """Fetch fine history for a specific reader."""
    query = """
        SELECT 
            fl.FineID,
            b.BookName,
            fl.FineAmount,
            fl.FineDate,
            br.BorrowDate,
            br.ReturnDate
        FROM FineLedger fl
        JOIN Borrowing br ON fl.BorrowID = br.BorrowID
        JOIN Books b ON br.BookID = b.BookID
        WHERE fl.ReaderID = %s
        ORDER BY fl.FineDate DESC
    """
    return db.execute_query(query, (reader_id,))
