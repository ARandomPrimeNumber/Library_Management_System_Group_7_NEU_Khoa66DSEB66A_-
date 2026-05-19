# Database Configuration File
# This uses the app_service_role account created in database/security.sql

DB_CONFIG = {
    'host': 'localhost',
    'user': 'library_app',
    'password': 'app_secure_pass2026',
    'database': 'LibraryManagement',
    'port': 3306
}

# The AES encryption key used for sensitive Reader information
AES_SECRET_KEY = 'library_secret_key_2026'
