#!/bin/bash

echo "Start Init_Database"

chmod 700 /data/mysql-data
chown mysql:mysql /data/mysql-data


mysql -h "localhost" -u "$MYSQL_USER" "-p$(MYSQL_PASSWORD)" "$MYSQL_DATABASE" < "
    CREATE TABLESPACE klarosspace LOCATION '/data/mysql-data';
    CREATE role $MYSQL_USER LOGIN PASSWORD '$MYSQL_PASSWORD';
    CREATE DATABASE $MYSQL_DATABASE OWNER $MYSQL_USER TABLESPACE klarosspace;
    GRANT ALL PRIVILEGES ON DATABASE $MYSQL_DATABASE TO $MYSQL_USER;"

echo "End of Init_Database"
