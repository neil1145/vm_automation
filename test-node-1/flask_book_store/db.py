#!/usr/bin/env python3

import os
from dotenv import load_dotenv
import psycopg2

# Load environment variables
load_dotenv()

# Database connection parameters
db_params = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'database': os.getenv('DB_NAME', 'flask_db'),
    'user': os.getenv('DB_USERNAME'),
    'password': os.getenv('DB_PASSWORD')
}

# Establish connection
conn = psycopg2.connect(**db_params)

# Open a cursor to perform database operations
cur = conn.cursor()

# Execute a command: this creates a new table
cur.execute('DROP TABLE IF EXISTS books;')
cur.execute('''CREATE TABLE books (
    id serial PRIMARY KEY,
    title varchar (150) NOT NULL,
    author varchar (50) NOT NULL,
    pages_num integer NOT NULL,
    review text,
    date_added date DEFAULT CURRENT_TIMESTAMP);
''')

# Insert data into the table
books_data = [
    ('A Tale of Two Cities', 'Charles Dickens', 489, 'A great classic!'),
    ('Anna Karenina', 'Leo Tolstoy', 864, 'Another great classic!')
]

for book in books_data:
    cur.execute(
        'INSERT INTO books (title, author, pages_num, review) VALUES (%s, %s, %s, %s)',
        book
    )

# Commit the changes
conn.commit()

# Close communication with the database
cur.close()
conn.close()