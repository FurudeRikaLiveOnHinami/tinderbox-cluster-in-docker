FROM postgres:14

COPY sql /sql
COPY init-user-db.sh /docker-entrypoint-initdb.d/init-user-db.sh
