import sys
import os

# Ensure src modules can be imported
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from src.crud import authenticate_user, get_reader_profile, get_all_books
from src.transactions import borrow_book, return_book, register_reader
from src.reports import get_overdue_borrows

def librarian_menu():
    while True:
        print("\n=== LIBRARIAN MENU ===")
        print("1. View Overdue Borrows")
        print("2. Process Book Return")
        print("3. Register New Reader")
        print("4. Logout")
        
        choice = input("Select an option: ")
        if choice == '1':
            overdue = get_overdue_borrows()
            print("\n--- Overdue Books ---")
            if overdue:
                for row in overdue:
                    print(f"BorrowID: {row['BorrowID']} | Reader: {row['ReaderName']} | Days Overdue: {row['DaysOverdue']}")
            else:
                print("No overdue books.")
        elif choice == '2':
            borrow_id = int(input("Enter Borrow ID to return: "))
            result = return_book(borrow_id)
            print(f"\nResult: {result['message']}")
            print(f"Fine applied: {result['fine']} VND")
        elif choice == '3':
            print("\n--- Register New Reader ---")
            username = input("New Username: ")
            password = input("New Password (Hash): ")
            name = input("Reader Full Name: ")
            address = input("Address: ")
            phone = input("Phone Number: ")
            msg = register_reader(username, password, name, address, phone)
            print(f"Result: {msg}")
        elif choice == '4':
            break
        else:
            print("Invalid option.")

def reader_menu(reader_id):
    while True:
        print("\n=== READER MENU ===")
        print("1. View My Profile")
        print("2. View Available Books")
        print("3. Borrow a Book")
        print("4. Logout")
        
        choice = input("Select an option: ")
        if choice == '1':
            profile = get_reader_profile(reader_id)
            if profile:
                print("\n--- Profile Information ---")
                print(f"Name:    {profile['ReaderName']}")
                print(f"Address: {profile['Address']}")
                print(f"Phone:   {profile['PhoneNumber']}")
            else:
                print("Could not load profile.")
        elif choice == '2':
            books = get_all_books()
            print("\n--- Available Books ---")
            for b in books:
                print(f"ID: {b['BookID']} | {b['BookName']} ({b['Quantity']} available)")
        elif choice == '3':
            print("\n--- Borrow a Book ---")
            book_id = int(input("Enter Book ID to borrow: "))
            # In a real app, BorrowID is auto-generated, but the SP expects it here
            borrow_id = int(input("Enter a new 4-digit Borrow ID (e.g. 1007): "))
            msg = borrow_book(borrow_id, reader_id, book_id)
            print(f"Result: {msg}")
        elif choice == '4':
            break
        else:
            print("Invalid option.")

def main():
    print("========================================")
    print("Welcome to the Library Management System")
    print("========================================")
    while True:
        print("\n1. Login")
        print("2. Exit")
        opt = input("Choose an option: ")
        if opt == '2':
            print("Exiting system. Goodbye!")
            sys.exit()
        elif opt != '1':
            print("Invalid option.")
            continue
            
        print("\n--- Login ---")
        username = input("Username: ")
        password = input("Password: ")
        
        user = authenticate_user(username, password)
        if user:
            print(f"\nLogin successful! Welcome, {username}.")
            if user['Role'] in ('Librarian', 'Admin', 'BackendDev'):
                librarian_menu()
            elif user['Role'] == 'Reader':
                reader_menu(user['ReaderID'])
        else:
            print("Invalid username or password.")

if __name__ == "__main__":
    main()
