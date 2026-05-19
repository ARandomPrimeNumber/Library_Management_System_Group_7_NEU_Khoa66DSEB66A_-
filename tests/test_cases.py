import unittest
import sys
import os

# Ensure src modules can be imported
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from src.crud import authenticate_user, get_reader_profile
from src.reports import get_available_books
from src.transactions import borrow_book, return_book

class LibrarySystemTests(unittest.TestCase):

    def test_01_authentication_success(self):
        """Test that a valid user can authenticate."""
        user = authenticate_user('dev_tung', 'hash_dev123')
        self.assertIsNotNone(user, "User should be found in the database.")
        self.assertEqual(user['Role'], 'BackendDev', "Role mismatch.")

    def test_02_authentication_failure(self):
        """Test that invalid credentials fail gracefully."""
        user = authenticate_user('wrong_user', 'wrong_pass')
        self.assertIsNone(user, "User should not be found.")

    def test_03_available_books(self):
        """Test that the view vw_AvailableBooks returns data."""
        books = get_available_books()
        self.assertIsNotNone(books, "Query returned None.")
        self.assertTrue(len(books) > 0, "No books available in the system.")
        
    def test_04_borrow_book_out_of_stock(self):
        """Test the stored procedure logic for an out of stock (or invalid) book."""
        # Using a dummy ID to trigger the out of stock logic in the SP
        result = borrow_book(9999, 1, 9999)
        self.assertIn('out of stock', result.lower(), "Should return out of stock error.")
        
    def test_05_decrypt_reader_profile(self):
        """Test that the reader profile decrypts Address and Phone correctly."""
        # User Alpha is ReaderID = 1
        profile = get_reader_profile(1)
        self.assertIsNotNone(profile, "Profile not found.")
        self.assertEqual(profile['PhoneNumber'], '555-0101', "Phone number did not decrypt correctly.")

if __name__ == '__main__':
    unittest.main()
