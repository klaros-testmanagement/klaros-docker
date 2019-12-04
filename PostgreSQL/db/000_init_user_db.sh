#!/bin/bash

echo "Start Init_Database"

#mkdir -p /data/klaros-home/postgressql
#chmod 700 /data/klaros-home/postgressql
#chown postgres /data/klaros-home/postgressql

echo "host $POSTGRES_DB $POSTGRES_USER 127.0.0.1/32 md5" >> /data/postgres-data/pg_hba.conf


set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE TABLESPACE klarosspace LOCATION '/data/postgres-data';
    CREATE role $POSTGRES_USER LOGIN PASSWORD '$POSTGRES_PASSWORD';
    CREATE DATABASE $POSTGRES_DB OWNER $POSTGRES_USER TABLESPACE klarosspace;
    GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;
\q
EOSQL

echo "End of Init_Database"
