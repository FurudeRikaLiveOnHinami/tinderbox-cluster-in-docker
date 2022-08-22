#!/usr/bin/env bash

set -e
set -u

SQL_URL="${SQL_URL:-http://90.231.13.235:8000}"

sql_dbs=(
    keywords.sql
    categorys.sql
    repositorys.sql
    project.sql
    portage_makeconf.sql
    projects_emerge_options.sql

    workers.sql

    projects_env.sql
    projects_makeconf.sql
    projects_package.sql
    projects_pattern.sql
    projects_portage.sql
    projects_repositorys.sql
    projects_workers.sql

    repositorys_gitpullers.sql
)


function create_user_and_database() {
    echo " Creating user and database for master "
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
        CREATE USER buildbot with ENCRYPTED PASSWORD 'riscv';
        CREATE DATABASE buildbot;
        CREATE USER gentooci with ENCRYPTED PASSWORD 'riscv';
        GRANT ALL PRIVILEGES ON DATABASE buildbot to buildbot;
EOSQL

psql -v ON_ERROR_STOP=1 -U"$POSTGRES_USER" -f "/sql/gentoo_ci_schema.sql" > /dev/null

for db in ${sql_dbs[@]}; do
    psql -v ON_ERROR_STOP=1 -Ugentooci -dgentooci -f "/sql/$db" > /dev/null
done


    psql -v ON_ERROR_STOP=1 -Ugentooci -dgentooci <<-EOSQL
        UPDATE projects_portage SET value='default/linux/riscv/20.0/rv64gc/lp64d/systemd' WHERE id = 1;
        UPDATE projects_portage SET value='default/linux/riscv/20.0/rv64gc/lp64d/desktop' WHERE id = 3;
        UPDATE projects_portage SET value='default/linux/riscv/20.0/rv64gc/lp64d' WHERE id = 5;
        UPDATE projects SET profile='profiles/default/linux/riscv', keyword_id='11' WHERE uuid = 'e89c2c1a-46e0-4ded-81dd-c51afeb7fcff';
        UPDATE projects SET name='defriscv20_0unstable', description='Default riscv 20.0 Unstable', profile='profiles/default/linux/riscv/20.0/rv64gc/lp64d', keyword_id='11', image='stage3-rv64_lp64d-openrc-latest' WHERE uuid = 'e89c2c1a-46e0-4ded-81dd-c51afeb7fcfa';
        UPDATE projects SET profile='profiles/default/linux/riscv/20.0/rv64gc/lp64d/systemd', keyword_id='11', enabled='t', image='stage3-rv64_lp64d-systemd-latest' WHERE uuid = 'e89c2c1a-46e0-4ded-81dd-c51afeb7fcfd';
        UPDATE public.projects_portages_makeconf set value='riscv64-unknown-linux-gnu' WHERE id = 2;
        INSERT INTO public.projects_portages_makeconf VALUES (63, 'e89c2c1a-46e0-4ded-81dd-c51afeb7fcff', 3, '--jobs');
EOSQL
}

create_user_and_database
