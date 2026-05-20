import sys
import os

# Ensure src modules can be imported
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from src.crud import authenticate_user, get_reader_profile, get_all_books, get_reader_borrows, check_overdue_warning, get_reader_fines
from src.transactions import borrow_book, return_book, register_reader
from src.reports import get_overdue_borrows, get_all_fines

def get_int_input(prompt):
    """Safely get an integer from user input."""
    while True:
        try:
            return int(input(prompt))
        except ValueError:
            print("Invalid input. Please enter a number.")

def librarian_menu():
    while True:
        print("\n=== LIBRARIAN MENU ===")
        print("1. View Overdue Borrows")
        print("2. Process Book Return")
        print("3. Register New Reader")
        print("4. View Fine Ledger")
        print("5. Logout")
        
        choice = input("Select an option: ")
        if choice == '1':
            overdue = get_overdue_borrows()
            print("\n--- Overdue Books ---")
            if overdue:
                for row in overdue:
                    print(f"BorrowID: {row['BorrowID']} | Reader: {row['ReaderName']} | Book: {row['BookName']} | Due: {row['DueDate']} | {row['DaysOverdue']} days overdue")
            else:
                print("No overdue books.")
        elif choice == '2':
            borrow_id = get_int_input("Enter Borrow ID to return: ")
            result = return_book(borrow_id)
            print(f"\nResult: {result['message']}")
            if result['fine'] > 0:
                print(f"Fine applied: {result['fine']} VND (recorded in Fine Ledger)")
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
            fines = get_all_fines()
            print("\n--- Fine Ledger (All Readers) ---")
            if fines:
                total = 0
                for f in fines:
                    print(f"Fine #{f['FineID']} | {f['ReaderName']} | {f['BookName']} | {f['FineAmount']} VND | Date: {f['FineDate']}")
                    total += f['FineAmount']
                print(f"\nTotal fines collected: {total} VND")
            else:
                print("No fines recorded.")
        elif choice == '5':
            break
        else:
            print("Invalid option.")

def reader_menu(reader_id):
    while True:
        print("\n=== READER MENU ===")
        print("1. View My Profile")
        print("2. View Available Books")
        print("3. Borrow a Book")
        print("4. View My Borrowed Books")
        print("5. Return a Book")
        print("6. View My Fine History")
        print("7. Logout")
        
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
            if books:
                for b in books:
                    print(f"ID: {b['BookID']} | {b['BookName']} ({b['Quantity']} available)")
            else:
                print("No books available or could not load data.")
        elif choice == '3':
            print("\n--- Borrow a Book ---")
            book_id = get_int_input("Enter Book ID to borrow: ")
            msg = borrow_book(reader_id, book_id)
            print(f"Result: {msg}")
        elif choice == '4':
            borrows = get_reader_borrows(reader_id)
            print("\n--- My Borrowed Books ---")
            if borrows:
                for br in borrows:
                    status = f"OVERDUE ({br['EstimatedFine']} VND fine)" if br['IsOverdue'] else "On time"
                    print(f"BorrowID: {br['BorrowID']} | {br['BookName']} | Due: {br['DueDate']} | {status}")
            else:
                print("You have no active borrows.")
        elif choice == '5':
            borrows = get_reader_borrows(reader_id)
            print("\n--- Return a Book ---")
            if borrows:
                print("Your active borrows:")
                for br in borrows:
                    overdue_note = f" [OVERDUE - ~{br['EstimatedFine']} VND]" if br['IsOverdue'] else ""
                    print(f"  BorrowID: {br['BorrowID']} | {br['BookName']} | Due: {br['DueDate']}{overdue_note}")
                borrow_id = get_int_input("Enter Borrow ID to return: ")
                result = return_book(borrow_id)
                print(f"\nResult: {result['message']}")
                if result['fine'] > 0:
                    print(f"Late fine applied: {result['fine']} VND")
            else:
                print("You have no books to return.")
        elif choice == '6':
            fines = get_reader_fines(reader_id)
            print("\n--- My Fine History ---")
            if fines:
                total = 0
                for f in fines:
                    print(f"Fine #{f['FineID']} | {f['BookName']} | {f['FineAmount']} VND | Returned: {f['ReturnDate']}")
                    total += f['FineAmount']
                print(f"\nTotal fines: {total} VND")
            else:
                print("No fines on record. Keep it up!")
        elif choice == '7':
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
            if user['Role'] in ('Librarian', 'BackendDev'):
                librarian_menu()
            elif user['Role'] == 'Reader':
                # Check for overdue books and warn at login
                overdue = check_overdue_warning(user['ReaderID'])
                if overdue:
                    print(f"\n⚠ WARNING: You have {len(overdue)} overdue book(s)!")
                    for item in overdue:
                        print(f"  - {item['BookName']} | Due: {item['DueDate']} | {item['DaysOverdue']} days late | Fine: ~{item['EstimatedFine']} VND")
                reader_menu(user['ReaderID'])
        else:
            print("Invalid username or password.")

if __name__ == "__main__":
    main()
