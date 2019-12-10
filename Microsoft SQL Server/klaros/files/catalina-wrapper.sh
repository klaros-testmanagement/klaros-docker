#!/bin/sh

(
echo "hibernate.dialect=org.hibernate.dialect.SQLServer2008Dialect";
echo "hibernate.connection.driver_class=com.microsoft.sqlserver.jdbc.SQLServerDriver";
echo "hibernate.connection.url=jdbc:sqlserver://db:1433;databaseName=${DATABASE_NAME}";
echo "hibernate.connection.username=${DATABASE_USER}";
echo "hibernate.connection.password=${SA_PASSWORD}";
)> /klaros-data/hibernate.properties

# Wait for SQL Server
sleep 60

/root/klaros-testmanagement/bin/catalina.sh run
