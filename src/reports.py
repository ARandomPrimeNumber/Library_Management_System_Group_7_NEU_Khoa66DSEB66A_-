from src.db_connector import DatabaseManager

db = DatabaseManager()

def get_available_books():
    """Fetch from vw_AvailableBooks."""
    return db.execute_query("SELECT * FROM vw_AvailableBooks")

def get_overdue_borrows():
    """Fetch from vw_OverdueBorrows view."""
    return db.execute_query("SELECT * FROM vw_OverdueBorrows")
