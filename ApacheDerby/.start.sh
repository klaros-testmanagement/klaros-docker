#!/bin/sh
CA_DIR_DATA=/data
CA_DIR_BASE=$CA_DIR_DATA/catalina-base
CA_DIR_TEMP=$CA_DIR_BASE/temp
CA_DIR_LOGS=$CA_DIR_BASE/logs
CA_DIR_CONF=$CA_DIR_BASE/conf
CA_DIR_WEB=$CA_DIR_BASE/webapps
KT_DIR_WEB=/root/klaros-testmanagement/webapps
KT_DIR_CONF=/root/klaros-testmanagement/conf
counter=0

ctrl_c() {
	echo ""
	counter=$((counter + 1))
	if [ "$counter" = 1 ]; then
		echo "Ctrl-C caught...stopping Server"
		echo "press again to force"
		./root/klaros-testmanagement/bin/catalina.sh stop &
	else
		echo "forcing..."
		kill $child
	fi
	wait "$child"
	exit 2
}

if [ -d "$CA_DIR_DATA" ]; then
	echo "$CA_DIR_DATA exists"
else
	echo "creating $CA_DIR_DATA"
	mkdir $CA_DIR_DATA
fi

if [ -d "$CA_DIR_BASE" ]; then
	echo "$CA_DIR_BASE exists"
else
	echo "creating $CA_DIR_BASE"
	mkdir $CA_DIR_BASE
fi

if [ -d "$CA_DIR_TEMP" ]; then
	echo "$CA_DIR_TEMP exists"
else
	echo "creating $CA_DIR_TEMP"
	mkdir $CA_DIR_TEMP
fi

if [ -d "$CA_DIR_LOGS" ]; then
	echo "$CA_DIR_LOGS exists"
else
	echo "creating $CA_DIR_LOGS"
	mkdir $CA_DIR_LOGS
fi

if [ -d "$CA_DIR_CONF" ]; then
	echo "$CA_DIR_CONF exists"
else
	echo "creating $CA_DIR_CONF"
	ln -s $KT_DIR_CONF $CA_DIR_CONF
fi

if [ -d "$CA_DIR_WEB" ]; then
	echo "$CA_DIR_WEB exists"
else
	echo "creating $CA_DIR_WEB"
	ln -s $KT_DIR_WEB $CA_DIR_WEB
fi

trap "ctrl_c" TERM 2

./root/klaros-testmanagement/bin/catalina.sh run &

child=$!
wait "$child"
