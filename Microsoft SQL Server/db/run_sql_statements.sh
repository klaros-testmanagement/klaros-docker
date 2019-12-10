#!/usr/bin/env bash

declare -r MAXDELAY=20

run_sql() {
    local -r CMD="${1}"; shift

    /opt/mssql-tools/bin/sqlcmd -S 0.0.0.0 -U "${DATABASE_USER}" -P "${SA_PASSWORD}" -i "${CMD}"
}

replace_vars() {
    local -r DSTFILE="${1}"; shift

    sed -i -e "s|@@HOSTNAME@@|${HOSTNAME}|g" \
           -e "s|@@DATABASE_NAME@@|${DATABASE_NAME}|g"\
        "${DSTFILE}"
}

echo "[*] Start executing sql scripts in ${MAXDELAY} seconds."
sleep ${MAXDELAY}

for sf in $(ls -v /*.sql);
do
    echo "Execute ${sf}"
    replace_vars "${sf}"
    run_sql "${sf}"
done

exit 0
