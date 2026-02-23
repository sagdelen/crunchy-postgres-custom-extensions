#!/bin/bash
set -e

PGDATA="${PGDATA:-/tmp/pgdata}"

# Initialize database if not already done
if [ ! -f "$PGDATA/PG_VERSION" ]; then
    echo "Initializing PostgreSQL database..."
    initdb -D "$PGDATA" --auth=trust --username=postgres

    # Configure pg_partman_bgw
    cat >> "$PGDATA/postgresql.conf" <<EOF
# pg_partman background worker
shared_preload_libraries = 'pg_partman_bgw'
pg_partman_bgw.dbname = 'postgres'
pg_partman_bgw.interval = 3600
pg_partman_bgw.role = 'postgres'

# Network
listen_addresses = '*'
EOF

    # Allow external connections
    echo "host all all 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"
    echo "host all all ::/0 md5" >> "$PGDATA/pg_hba.conf"

    # Start temporarily to set up extensions
    pg_ctl -D "$PGDATA" -w start

    psql -U postgres <<EOSQL
ALTER USER postgres PASSWORD 'postgres';
CREATE SCHEMA IF NOT EXISTS partman;
CREATE EXTENSION IF NOT EXISTS pg_partman SCHEMA partman;
EOSQL

    pg_ctl -D "$PGDATA" -w stop
    echo "PostgreSQL initialization complete."
fi

echo "Starting PostgreSQL..."
exec postgres -D "$PGDATA"
