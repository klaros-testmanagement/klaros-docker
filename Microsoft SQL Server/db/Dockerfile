FROM mcr.microsoft.com/mssql/server:2017-CU19-ubuntu-16.04
LABEL maintainer "BreadSpoon <susp425@verit.de>"

ENV MSSQL_MASTER_DATA_FILE /data/mssql-data/master.mdf
ENV MSSQL_MASTER_LOG_FILE /data/mssql-data/mastlog.ldf

COPY ./*.sh /
COPY ./*.sql /
COPY ./mssql.conf /var/opt/mssql/mssql.conf
COPY ./mssql.conf /data/mssql-data/mssql.conf

RUN set -ex \
    && chmod +x /*.sh

RUN sed -i -e "s|@@HOSTNAME@@|${HOSTNAME}|" "/var/opt/mssql/mssql.conf"

CMD /bin/bash ./entrypoint.sh