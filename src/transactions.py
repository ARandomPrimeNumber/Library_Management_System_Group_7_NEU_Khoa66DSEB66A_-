from src.db_connector import DatabaseManager

db = DatabaseManager()

def borrow_book(borrow_id, reader_id, book_id):
    """Call the sp_BorrowBook stored procedure."""
    args = (borrow_id, reader_id, book_id, '')
    result = db.call_procedure('sp_BorrowBook', args)
    if result:
        return result[3] # p_Message is the 4th OUT parameter (index 3)
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
    args = (username, password, name, address, phone, '')
    result = db.call_procedure('sp_RegisterReader', args)
    if result:
        return result[5]
    return "Error executing transaction."
