#!/usr/bin/env bash

run_sql() {
    local -r CMD="${1}"
    shift

    /opt/mssql-tools/bin/sqlcmd -S 0.0.0.0 -U "${DATABASE_USER}" -P "${DATABASE_PASSWORD}" -i "${CMD}"
}

replace_vars() {
    local -r DSTFILE="${1}"
    shift

    sed -i -e "s|@@HOSTNAME@@|${HOSTNAME}|g" \
        -e "s|@@DATABASE_NAME@@|${DATABASE_NAME}|g" \
        "${DSTFILE}"
}

echo "Wait for server to startup"
while [ ! -f /var/opt/mssql/log/errorlog ]
do
  sleep 2
done

tail -f /var/opt/mssql/log/errorlog | while read LOGLINE
do
   [[ "${LOGLINE}" == *"Using 'xpstar.dll' version"* ]] && pkill -P $$ tail
done
echo "[*] Start executing sql scripts."

for sf in $(ls -v /*.sql); do
    echo "Execute ${sf}"
    replace_vars "${sf}"
    run_sql "${sf}"
done

exit 0