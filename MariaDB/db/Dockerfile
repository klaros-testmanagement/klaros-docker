FROM verit/klaros-mariadb_db:4.12.5
LABEL maintainer "BreadSpoon <susp425@verit.de>"

COPY *.cnf /etc/mysql/mariadb.conf.d
RUN chmod 444 /etc/mysql/mariadb.conf.d/mysqld.cnf