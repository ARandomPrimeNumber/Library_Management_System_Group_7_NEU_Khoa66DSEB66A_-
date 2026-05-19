-- ==============================================================================
-- DATABASE SECURITY SCRIPT
-- Purpose: Defines Role-Based Access Control (RBAC), Users, and Permissions
-- Execute this script LAST, after schema.sql and advanced_objects.sql
-- ==============================================================================
USE LibraryManagement;

-- 1. Create Roles
-- ------------------------------------------------------------------------------
CREATE ROLE IF NOT EXISTS 'db_admin_role', 'librarian_role', 'reader_role', 'app_service_role';

-- 2. Define Privileges for db_admin_role
-- ------------------------------------------------------------------------------
-- Admins have full access to the database
GRANT ALL PRIVILEGES ON LibraryManagement.* TO 'db_admin_role';

-- 3. Define Privileges for librarian_role
-- ------------------------------------------------------------------------------
-- Librarians manage data but cannot alter schema or manage users
GRANT SELECT, INSERT, UPDATE, DELETE ON LibraryManagement.Books TO 'librarian_role';
GRANT SELECT, INSERT, UPDATE, DELETE ON LibraryManagement.Categories TO 'librarian_role';
GRANT SELECT, INSERT, UPDATE, DELETE ON LibraryManagement.Authors TO 'librarian_role';
GRANT SELECT, INSERT, UPDATE, DELETE ON LibraryManagement.Readers TO 'librarian_role';
GRANT SELECT, INSERT, UPDATE, DELETE ON LibraryManagement.Borrowing TO 'librarian_role';
-- Allow executing standard stored procedures
GRANT EXECUTE ON LibraryManagement.* TO 'librarian_role';

-- 4. Define Privileges for reader_role
-- ------------------------------------------------------------------------------
-- Readers have read-only access to basic catalog information
GRANT SELECT ON LibraryManagement.Books TO 'reader_role';
GRANT SELECT ON LibraryManagement.Categories TO 'reader_role';
GRANT SELECT ON LibraryManagement.Authors TO 'reader_role';
-- They should only access Views or use App level filtering for their own borrowing history

-- 5. Define Privileges for app_service_role
-- ------------------------------------------------------------------------------
-- Used by the Python backend application
GRANT SELECT, INSERT, UPDATE, DELETE ON LibraryManagement.* TO 'app_service_role';
GRANT EXECUTE ON LibraryManagement.* TO 'app_service_role';

-- ==============================================================================
-- SAMPLE USERS CREATION & ROLE ASSIGNMENT
-- ==============================================================================

-- Create an Admin User
CREATE USER IF NOT EXISTS 'admin_bach'@'localhost' IDENTIFIED BY 'bach_admin_pass123';
GRANT 'db_admin_role' TO 'admin_bach'@'localhost';
SET DEFAULT ROLE 'db_admin_role' TO 'admin_bach'@'localhost';

-- Create a Librarian User
CREATE USER IF NOT EXISTS 'lib_staff1'@'localhost' IDENTIFIED BY 'staff_pass123';
GRANT 'librarian_role' TO 'lib_staff1'@'localhost';
SET DEFAULT ROLE 'librarian_role' TO 'lib_staff1'@'localhost';

-- Create an Application Service User (For Python db_connector.py)
CREATE USER IF NOT EXISTS 'library_app'@'localhost' IDENTIFIED BY 'app_secure_pass2026';
GRANT 'app_service_role' TO 'library_app'@'localhost';
SET DEFAULT ROLE 'app_service_role' TO 'library_app'@'localhost';

-- Flush privileges to ensure they take effect
FLUSH PRIVILEGES;

-- ==============================================================================
-- NOTES ON DATA ENCRYPTION:
-- The Address and PhoneNumber in the Readers table are encrypted.
-- To decrypt and read them, use the AES_DECRYPT function with the key.
-- Example:
-- SELECT ReaderName, AES_DECRYPT(PhoneNumber, 'library_secret_key_2026') AS Phone
-- FROM Readers;
-- ==============================================================================
