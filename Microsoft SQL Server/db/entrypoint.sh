#!/usr/bin/env bash

env \
    && (nohup /run_sql_statements.sh &) \
    && /opt/mssql/bin/sqlservr