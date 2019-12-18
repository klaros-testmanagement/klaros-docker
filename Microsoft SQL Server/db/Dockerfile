FROM mcr.microsoft.com/mssql/server:2017-latest
LABEL maintainer "BreadSpoon <susp425@verit.de>"

ENV MSSQL_DATA_DIR /data/mssql-data
ENV MSSQL_LOG_DIR /data/mssql-data
ENV MSSQL_DUMP_DIR /data/mssql-data

COPY ./*.sh /
COPY ./*.sql /
COPY ./mssql.conf /tmp/mssql.conf

RUN set -ex \
    && chmod +x /*.sh

CMD /bin/bash /entrypoint.sh
