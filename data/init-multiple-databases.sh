#!/bin/bash
set -e
set -u

export PGPASSWORD="$POSTGRES_PASSWORD"
export PGHOST="postgres"
export PGUSER="$POSTGRES_USER"
export PGDATABASE="$POSTGRES_DB"

function create_database() {
    local db=$1
    echo "Checking database: $db"
    
    # if db exists
    DB_EXISTS=$(psql -lqt | cut -d \| -f 1 | grep -qw "$db" && echo "yes" || echo "no")
    
    if [ "$DB_EXISTS" = "no" ]; then
        echo "Database '$db' does not exist. Creating..."
        psql -c "CREATE DATABASE \"$db\";"
        psql -c "GRANT ALL PRIVILEGES ON DATABASE \"$db\" TO \"$PGUSER\";"
    else
        echo "Database '$db' already exists. Skipping."
    fi
}

if [ -n "${POSTGRES_MULTIPLE_DATABASES:-}" ]; then
    for db in $(echo "$POSTGRES_MULTIPLE_DATABASES" | tr ',' ' '); do
        create_database "$db"
    done
    echo "All databases processed successfully."
else
    echo "No additional databases to create."
fi