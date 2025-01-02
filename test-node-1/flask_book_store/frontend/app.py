import os
from datetime import datetime
from flask import Flask, render_template, request, url_for, redirect, flash
import psycopg2
from dotenv import load_dotenv
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Load environment variables
load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv('FLASK_SECRET_KEY', 'dev-secret-key')

def get_db_connection():
    """Create a database connection"""
    try:
        conn = psycopg2.connect(
            host=os.getenv('DB_HOST', 'db'),
            database=os.getenv('DB_NAME', 'flask_db'),
            user=os.getenv('DB_USERNAME', 'flask_user'),
            password=os.getenv('DB_PASSWORD', 'passwd'),
            port=int(os.getenv('DB_PORT', 5432))
        )
        return conn
    except psycopg2.Error as e:
        logger.error(f"Database connection error: {e}")
        return None

@app.route('/')
def index():
    """Display all books"""
    conn = get_db_connection()
    if not conn:
        flash("Unable to connect to database", "error")
        return render_template('index.html', books=[])
    
    try:
        cur = conn.cursor()
        cur.execute('''
            SELECT id, title, author, pages_num, review, 
                   to_char(date_added, 'YYYY-MM-DD') as date_added 
            FROM books 
            ORDER BY date_added DESC;
        ''')
        books = cur.fetchall()
        cur.close()
        conn.close()
        return render_template('index.html', books=books)
    except Exception as e:
        logger.error(f"Error fetching books: {e}")
        flash("Error retrieving books", "error")
        return render_template('index.html', books=[])

@app.route('/create/', methods=('GET', 'POST'))
def create():
    """Create a new book entry"""
    if request.method == 'POST':
        title = request.form.get('title', '').strip()
        author = request.form.get('author', '').strip()
        pages_num = request.form.get('pages_num', '')
        review = request.form.get('review', '').strip()

        # Validate input
        if not all([title, author, pages_num]):
            flash('Title, author, and number of pages are required!', 'error')
            return render_template('create.html')

        try:
            pages_num = int(pages_num)
            if pages_num <= 0:
                raise ValueError()
        except ValueError:
            flash('Please enter a valid number of pages', 'error')
            return render_template('create.html')

        conn = get_db_connection()
        if not conn:
            flash("Database connection error", "error")
            return render_template('create.html')

        try:
            cur = conn.cursor()
            cur.execute(
                'INSERT INTO books (title, author, pages_num, review) VALUES (%s, %s, %s, %s)',
                (title, author, pages_num, review)
            )
            conn.commit()
            cur.close()
            conn.close()
            flash('Book added successfully!', 'success')
            return redirect(url_for('index'))
        except Exception as e:
            logger.error(f"Error creating book: {e}")
            flash('Error adding book to database', 'error')
            return render_template('create.html')

    return render_template('create.html')

@app.errorhandler(404)
def not_found_error(error):
    return render_template('404.html'), 404

@app.errorhandler(500)
def internal_error(error):
    return render_template('500.html'), 500

@app.errorhandler(Exception)
def handle_exception(e):
    logger.error(f"Unhandled exception: {e}")
    return render_template('500.html'), 500

if __name__ == '__main__':
    # Get port from environment variable or default to 5000
    port = int(os.getenv('FLASK_PORT', 5000))
    
    # Get debug mode from environment variable
    debug = os.getenv('FLASK_DEBUG', 'False').lower() == 'true'
    
    app.run(host='0.0.0.0', port=port, debug=debug)