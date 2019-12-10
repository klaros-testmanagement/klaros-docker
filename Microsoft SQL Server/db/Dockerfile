FROM mcr.microsoft.com/mssql/server:2017-latest
LABEL maintainer "André Raabe <andre.raabe@gmail.com>"

ENV DATABASE_USER sa
ENV DATABASE_NAME dbname
ENV SA_PASSWORD P@ssw0rd
ENV MSSQL_PID Developer
ENV ACCEPT_EULA Y
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY ./*.sh /
COPY ./*.sql /
COPY ./mssql.conf /tmp/mssql.conf

RUN set -ex \
    && chmod +x /*.sh

CMD /bin/bash /entrypoint.sh
