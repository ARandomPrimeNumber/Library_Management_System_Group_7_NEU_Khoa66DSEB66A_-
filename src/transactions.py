import hashlib
from src.db_connector import db

def borrow_book(reader_id, book_id):
    """Call the sp_BorrowBook stored procedure."""
    args = (reader_id, book_id, '')
    result = db.call_procedure('sp_BorrowBook', args)
    if result:
        return result[2] # p_Message is the 3rd OUT parameter (index 2)
    return "Error executing transaction."

def return_book(borrow_id):
    """Call the sp_ReturnBook stored procedure."""
    args = (borrow_id, '', 0)
    result = db.call_procedure('sp_ReturnBook', args)
    if result:
        return {"message": result[1], "fine": result[2]}
    return {"message": "Error executing transaction.", "fine": 0}

def register_reader(username, password, name, address, phone):
    """Call the sp_RegisterReader stored procedure.
    Note: The SP internally encrypts Address and PhoneNumber using AES_ENCRYPT.
    """
    password_hash = hashlib.sha256(password.encode()).hexdigest()
    args = (username, password_hash, name, address, phone, '')
    result = db.call_procedure('sp_RegisterReader', args)
    if result:
        return result[5]
    return "Error executing transaction."
