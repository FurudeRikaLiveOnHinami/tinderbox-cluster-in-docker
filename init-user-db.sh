#!/usr/bin/env bash

set -e
set -u

function create_user_and_database() {
    echo " Creating user and database for master "
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
        CREATE USER buildbot with ENCRYPTED PASSWORD 'riscv';
        CREATE DATABASE buildbot;
        GRANT ALL PRIVILEGES ON DATABASE buildbot to buildbot;
        CREATE USER gentooci with ENCRYPTED PASSWORD 'riscv';
        CREATE DATABASE gentooci;
        GRANT ALL PRIVILEGES ON DATABASE gentooci to gentooci;
EOSQL
}

create_user_and_database
