import mysql.connector
from mysql.connector import Error
from src.config import DB_CONFIG

class DatabaseManager:
    def __init__(self):
        self.connection = None
        self.connect()

    def connect(self):
        """Establish a connection to the MySQL database."""
        try:
            self.connection = mysql.connector.connect(**DB_CONFIG)
        except Error as e:
            print(f"Error connecting to MySQL: {e}")
            print("Please ensure your MySQL server is running and the database/setup scripts have been executed.")

    def get_connection(self):
        """Returns the active connection, reconnecting if necessary."""
        if not self.connection or not self.connection.is_connected():
            self.connect()
        return self.connection

    def close(self):
        """Close the database connection."""
        if self.connection and self.connection.is_connected():
            self.connection.close()

    def execute_query(self, query, params=None):
        """Execute a single SELECT query and return fetched results."""
        conn = self.get_connection()
        if not conn: return None
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute(query, params or ())
            result = cursor.fetchall()
            cursor.close()
            return result
        except Error as e:
            print(f"Query Execution Error: {e}")
            return None
            
    def execute_write(self, query, params=None):
        """Execute an INSERT, UPDATE, or DELETE query."""
        conn = self.get_connection()
        if not conn: return False
        try:
            cursor = conn.cursor()
            cursor.execute(query, params or ())
            conn.commit()
            cursor.close()
            return True
        except Error as e:
            print(f"Query Write Error: {e}")
            return False

    def call_procedure(self, proc_name, args):
        """Call a stored procedure and return the modified arguments."""
        conn = self.get_connection()
        if not conn: return None
        try:
            cursor = conn.cursor()
            result_args = cursor.callproc(proc_name, args)
            conn.commit()
            cursor.close()
            return result_args
        except Error as e:
            print(f"Stored Procedure Error: {e}")
            return None


# Shared database instance — import this instead of creating new DatabaseManager() instances
db = DatabaseManager()
