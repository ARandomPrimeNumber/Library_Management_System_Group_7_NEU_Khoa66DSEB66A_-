# 📚 Library Management System

A robust, database-driven Library Management System developed for the Database Management System course at the National Economics University (DATCOM Lab NEU - College of Technology).

**Group 7 - Khoa 66 DSEB 66A**

## 🌟 Overview

This project is designed to manage library operations effectively, optimizing the borrowing and returning processes. It provides both a core **Console-based Interface** and an optional **Web GUI**. The system is built with a strong emphasis on database normalization (3NF) and security against vulnerabilities like SQL Injection.

## 🛠️ Technology Stack

*   **Database Management System:** MySQL
*   **Backend & Application Logic:** Python (`mysql-connector-python` or `SQLAlchemy`)
*   **Web GUI (Optional Extension):** Flask or FastAPI (Backend), HTML5/CSS3/Vanilla JS (Frontend)

## ✨ Core Features

*   **Book Management:** Add, edit, delete, and search books, categories, and authors.
*   **Reader Management:** Register readers and update profiles.
*   **Transaction Handling:** Process book borrowing and returning with automated inventory updates.
*   **Alerts:** Track and notify regarding overdue books.
*   **Statistical Reports:** Analytics on book availability, reader borrowing patterns, and overdue items.
*   **Security:** Role-based access control, parameterized queries for SQL Injection prevention, and data encryption.

## 🗄️ Database Architecture

The database is built using advanced MySQL objects for high performance and integrity:
*   **Normalized Schema:** 5 core tables (`Books`, `Categories`, `Authors`, `Readers`, `Borrowing`) in 3NF.
*   **Indexes:** Optimized for fast search queries.
*   **Views:** Abstracted data for quick reporting.
*   **Stored Procedures:** Encapsulated logic for complex borrowing transactions and overdue reporting.
*   **Triggers:** Automated quantity updates when books are borrowed or returned.
*   **UDFs:** Custom data calculations and processing.

## 📂 Repository Structure

```text
LibraryMS_Project/
├── database/                   # Database schema and logic
│   ├── schema.sql              # DDL scripts
│   ├── sample_data.sql         # DML scripts for initial data
│   ├── advanced_objects.sql    # Views, Procedures, Triggers, UDFs
│   └── security.sql            # User roles and permissions
├── src/                        # Python Source Code
│   ├── config.py               # Database credentials
│   ├── db_connector.py         # DB connection handling
│   ├── crud.py                 # Core CRUD operations
│   ├── transactions.py         # Borrow/return logic
│   ├── reports.py              # Statistical generation
│   ├── main.py                 # Console UI entry point
│   └── web_app/                # (Optional) Web GUI
│       ├── app.py              # Web server and routes
│       ├── templates/          # HTML views
│       └── static/             # CSS/JS assets
├── docs/                       # Project Documentation
│   ├── ERD.png                 # Entity-Relationship Diagram
│   └── Project_Report.docx     # Final academic report
└── tests/                      # Testing Suite
    ├── test_cases.py           # Unit and integration tests
    └── sample_outputs/         # Test results
```
