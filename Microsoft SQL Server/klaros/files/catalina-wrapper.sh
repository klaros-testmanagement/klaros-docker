#!/bin/sh

CA_DIR_BASE=/data/catalina-base
CA_DIR_TEMP=$CA_DIR_BASE/temp
CA_DIR_LOGS=$CA_DIR_BASE/logs
CA_DIR_CONF=$CA_DIR_BASE/conf
CA_DIR_WEB=$CA_DIR_BASE/webapps
KT_DIR_WEB=/root/klaros-testmanagement/webapps
KT_DIR_CONF=/root/klaros-testmanagement/conf
KT_DIR_HOME=/data/klaros-home
counter=0

ctrl_c() {
	echo ""
	counter=$((counter + 1))
	if [ "$counter" = 1 ]; then
		echo "...stopping Server"
		echo "press again to force kill"
		./root/klaros-testmanagement/bin/catalina.sh stop &
	else
		echo "force kill Server"
		kill $child
	fi
	wait "$child"
	exit 2
}

if [ -d "$KT_DIR_HOME" ]; then
	echo "$KT_DIR_HOME exists"
else
	echo "creating $KT_DIR_HOME"
	mkdir -p $KT_DIR_HOME
fi

if [ -d "$CA_DIR_BASE" ]; then
	echo "$CA_DIR_BASE exists"
else
	echo "creating $CA_DIR_BASE"
	mkdir -p $CA_DIR_BASE
fi

if [ -d "$CA_DIR_TEMP" ]; then
	echo "$CA_DIR_TEMP exists"
else
	echo "creating $CA_DIR_TEMP"
	mkdir -p $CA_DIR_TEMP
fi

if [ -d "$CA_DIR_LOGS" ]; then
	echo "$CA_DIR_LOGS exists"
else
	echo "creating $CA_DIR_LOGS"
	mkdir -p $CA_DIR_LOGS
fi

if [ -d "$CA_DIR_CONF" ]; then
	echo "$CA_DIR_CONF is linked"
else
	echo "creating link $CA_DIR_CONF"
	ln -s $KT_DIR_CONF $CA_DIR_CONF
fi

if [ -d "$CA_DIR_WEB" ]; then
	echo "$CA_DIR_WEB is linked"
else
	echo "creating link $CA_DIR_WEB"
	ln -s $KT_DIR_WEB $CA_DIR_WEB
fi

(
	echo "hibernate.connection.driver_class=com.microsoft.sqlserver.jdbc.SQLServerDriver"
	if [ -z "${DATABASE_INSTANCE}" ]; then
		echo "hibernate.connection.url=jdbc:sqlserver://${DATABASE_HOST}:1433;databaseName=${DATABASE_NAME};encrypt=false"
	else
		echo "hibernate.connection.url=jdbc:sqlserver://${DATABASE_HOST};instanceName=${DATABASE_INSTANCE};databaseName=${DATABASE_NAME};encrypt=false"
	fi
	echo "hibernate.connection.username=${DATABASE_USER}"
	echo "hibernate.connection.password=${DATABASE_PASSWORD}"
) >/data/klaros-home/hibernate.properties

# Allow for the Tomcat admin password to be changed on container start if TOMCAT_ADMIN_PASSWORD is set (else keep as default)
if [ ! -z "$TOMCAT_ADMIN_PASSWORD" ]; then
  sed -i -e "s/password=\".*\" roles/password=\"${TOMCAT_ADMIN_PASSWORD}\" roles/g" /root/klaros-testmanagement/conf/tomcat-users.xml
else
  echo "TOMCAT_ADMIN_PASSWORD is empty. TOMCAT_ADMIN_PASSWORD MUST be set in the environment before starting the container"
  exit 1
fi

# Wait for SQL Server (override by setting CATALINA_SKIP_SLEEP to anything e.g CATALINA_SKIP_SLEEP: 1)
if [ -z "${CATALINA_SKIP_SLEEP+x}" ]; then
	sleep 60
fi

trap "ctrl_c" TERM 2

./root/klaros-testmanagement/bin/catalina.sh run &

#/root/klaros-testmanagement/bin/catalina.sh run

child=$!
wait "$child"
