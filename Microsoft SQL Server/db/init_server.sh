#!/usr/bin/env bash

replace_vars() {
    local -r DSTFILE="${1}"; shift

    sed -i -e "s|@@HOSTNAME@@|${HOSTNAME}|" \
        "${DSTFILE}"
}

echo "[*] Pre customizing sql server"

cp -v /tmp/mssql.conf /var/opt/mssql/mssql.conf
replace_vars /var/opt/mssql/mssql.conf

echo "[*] Pre customizing sql server done"

exit 0
