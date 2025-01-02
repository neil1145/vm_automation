FROM postgres

# Copy initialization script
COPY backend/init.sql /docker-entrypoint-initdb.d/

# Set required environment variables
ENV POSTGRES_PASSWORD=passwd

EXPOSE 5432 54321