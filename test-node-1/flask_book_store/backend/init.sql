-- Create user first (if not exists)
DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'flask_user') THEN

      CREATE USER flask_user WITH PASSWORD 'passwd';
   END IF;
END
$do$;

-- Create database (if not exists)
SELECT 'CREATE DATABASE flask_db'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'flask_db')\gexec

-- Connect to flask_db
\c flask_db;

-- Create books table
CREATE TABLE IF NOT EXISTS books (
    id serial PRIMARY KEY,
    title varchar (150) NOT NULL,
    author varchar (50) NOT NULL,
    pages_num integer NOT NULL,
    review text,
    date_added date DEFAULT CURRENT_TIMESTAMP
);

-- Set permissions
GRANT ALL PRIVILEGES ON DATABASE flask_db TO flask_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO flask_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO flask_user;

-- Insert initial data
INSERT INTO books (title, author, pages_num, review) VALUES
    ('A Tale of Two Cities', 'Charles Dickens', 489, 'A great classic!'),
    ('Anna Karenina', 'Leo Tolstoy', 864, 'Another great classic!');