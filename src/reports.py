from src.db_connector import db

def get_available_books():
    """Fetch from vw_AvailableBooks."""
    return db.execute_query("SELECT * FROM vw_AvailableBooks")

def get_overdue_borrows():
    """Fetch from vw_OverdueBorrows view."""
    return db.execute_query("SELECT * FROM vw_OverdueBorrows")

def get_all_fines():
    """Fetch all fine records for librarian view."""
    query = """
        SELECT 
            fl.FineID,
            r.ReaderName,
            b.BookName,
            fl.FineAmount,
            fl.FineDate
        FROM FineLedger fl
        JOIN Readers r ON fl.ReaderID = r.ReaderID
        JOIN Borrowing br ON fl.BorrowID = br.BorrowID
        JOIN Books b ON br.BookID = b.BookID
        ORDER BY fl.FineDate DESC
    """
    return db.execute_query(query)
