FROM postgres:15-alpine

COPY init.sql /docker-entrypoint-initdb.d/

ENV POSTGRES_PASSWORD=passwd \
    PGDATA=/var/lib/postgresql/data/pgdata

EXPOSE 5432

HEALTHCHECK --interval=5s --timeout=5s --retries=5 \
    CMD pg_isready -U flask_user -d flask_db