from src.db_connector import DatabaseManager
from src.config import AES_SECRET_KEY

db = DatabaseManager()

def authenticate_user(username, password):
    """Check credentials against Accounts table."""
    query = "SELECT * FROM Accounts WHERE Username = %s AND PasswordHash = %s"
    result = db.execute_query(query, (username, password))
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
