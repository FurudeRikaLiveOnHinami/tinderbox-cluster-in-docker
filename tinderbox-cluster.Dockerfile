FROM tobiichiorigami/builder:latest

COPY tinderbox-cluster-riscv /tinderbox-cluster
# COPY buildbot_config/master.cfg /tinderbox-cluster/master.cfg
# COPY buildbot_config/gentooci.cfg /tinderbox-cluster/gentooci.cfg
# COPY buildbot_config/logparser.json /tinderbox-cluster/logparser.json
# COPY buildbot_config/alembic.ini /tinderbox-cluster/buildbot_gentoo_ci/db/migrations/alembic.ini
# COPY secrets /var/lib/buildmaster/gentooci-cloud/secrets/
COPY entrypoint.sh /entrypoint.sh

ARG gentoo_ci_db_user="gentoo-ci"
ARG gentoo_ci_db_password="gentoo-ci"
ARG gentoo_ci_db_name="gentoo-ci"
ARG gentoo_ci_db_host="db"

RUN rm /tinderbox-cluster/.git \
    && sed -Ei.bak "s/'password' : 'X\?'/'password' : 'riscv'/" /tinderbox-cluster/master.cfg
    && sed -Ei.bak "s|postgresql+psycopg2://user:password@host/gentoo-ci|postgresql+psycopg2://$gentoo_ci_db_user:$gentoo_ci_db_password@gentoo_ci_db_host/gentoo_ci_db_name|" /tinderbox-cluster/logparser.json \
    && sed -Ei.bak "s|postgresql://buildbot:password@ip/gentoo-ci|postgresql://$gentoo_ci_db_user:$gentoo_ci_db_password@$gentoo_ci_db_host/$gentoo_ci_db_name" /tinderbox-cluster/gentooci.cfg \
    && sed -Ei.bak "s|driver://user:pass@localhost/dbname|postgresql://$gentoo_ci_db_user:$gentoo_ci_db_password@$gentoo_ci_db_host/$gentoo_ci_db_name|" /tinderbox-cluster/buildbot_gentoo_ci/db/migrations/alembic.ini \
    && sed -Ei.bak "s|repourl='https://gitlab.gentoo.org/zorry/gentoo-ci.git'|repourl='https://git.onfoo.top/Chi-Tan-Da-Eru/gentoo.git'|" /tinderbox-cluster/buildbot_gentoo_ci/config/change_source.py \
    && diff -u --color /tinderbox-cluster/master.cfg /tinderbox-cluster/master.cfg.bak \
    && diff -u --color /tinderbox-cluster/logparser.json /tinderbox-cluster/logparser.json.bak \
    && diff -u --color /tinderbox-cluster/logparser.json /tinderbox-cluster/gentooci.cfg.bak \
    && diff -u --color /tinderbox-cluster/buildbot_gentoo_ci/db/migrations/alembic.ini /tinderbox-cluster/buildbot_gentoo_ci/db/migrations/alembic.ini.bak \

EXPOSE 8010 9989
ENTRYPOINT ["/entrypoint.sh"]
