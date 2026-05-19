# Library Management System

A database-driven Library Management System built with MySQL and Python. It features a normalized database schema, advanced SQL objects (Stored Procedures, Triggers, Views), role-based access control, and AES data encryption.


## Features
- **Book Management:** Search and manage books and library inventory.
- **Reader Profiles:** Register readers with natively encrypted sensitive information (AES).
- **Transactions:** Safely borrow and return books. Includes automatic inventory triggers and late-fine calculations.
- **Role-Based Access:** Dedicated console interfaces for Librarians vs. Readers.
- **Security First:** Built-in SQL injection prevention via parameterized queries, data encryption, and strict MySQL RBAC permissions.

## Prerequisites
- **MySQL Server** (8.0 or newer recommended)
- **Python** (3.8 or newer)

## Installation & Setup

### 1. Database Initialization
You must set up the database using your local MySQL root (or admin) account. Open your terminal and run the following scripts in this **exact order**:

```bash
# 1. Create the schema and tables
mysql -u root -p < database/schema.sql

# 2. Create Views, Functions, Procedures, and Triggers
mysql -u root -p < database/advanced_objects.sql

# 3. Insert sample data (includes AES encryption)
mysql -u root -p < database/sample_data.sql

# 4. Set up security roles and users (creates the 'library_app' user)
mysql -u root -p < database/security.sql
```

### 2. Python Environment
Navigate to the root of the project and install the required Python database connector:

```bash
pip install -r requirements.txt
```

*Note: The application is pre-configured in `src/config.py` to connect using the `library_app` user created by the setup scripts. You do not need to expose your personal MySQL root password in the code.*

## Usage

To start the interactive Console User Interface, run:
```bash
python src/main.py
```

### Sample Login Accounts
You can log in to the application using any of the following pre-configured test accounts:
- **Librarian / Admin:** Username: `lib_admin` | Password: `hash_admin123`
- **Backend Developer:** Username: `dev_tung` | Password: `hash_dev123`
- **Reader (User Alpha):** Username: `reader_alpha` | Password: `hash_pass1`

## Running Tests

A standard `unittest` suite is included to verify database connections, user authentication, and core transaction logic. Run the tests via:
```bash
python -m unittest tests/test_cases.py
```

## Repository Structure

```text
├── database/                   
│   ├── schema.sql              # Table definitions
│   ├── sample_data.sql         # Initial mock data
│   ├── advanced_objects.sql    # Views, Procedures, Triggers, UDFs
│   └── security.sql            # Users, Roles, and Privileges
├── src/                        
│   ├── config.py               # DB connection settings
│   ├── db_connector.py         # MySQL connection manager
│   ├── crud.py                 # Core read operations & decryption
│   ├── transactions.py         # Stored procedure wrappers
│   ├── reports.py              # Analytics and view wrappers
│   └── main.py                 # Interactive Console UI entry point
├── tests/                      
│   └── test_cases.py           # Unittest suite
├── docs/                       
│   ├── ERD.png                 # Entity-Relationship Diagram
│   └── Project_Report.docx     # Academic report
└── requirements.txt            # Python dependencies
```