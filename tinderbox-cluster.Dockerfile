FROM tobiichiorigami/builder:latest

COPY tinderbox-cluster-riscv /tinderbox-cluster
# COPY buildbot_config/master.cfg /tinderbox-cluster/master.cfg
# COPY buildbot_config/gentooci.cfg /tinderbox-cluster/gentooci.cfg
# COPY buildbot_config/logparser.json /tinderbox-cluster/logparser.json
# COPY buildbot_config/alembic.ini /tinderbox-cluster/buildbot_gentoo_ci/db/migrations/alembic.ini
# COPY secrets /var/lib/buildmaster/gentooci-cloud/secrets/
COPY entrypoint.sh /entrypoint.sh

ARG gentoo_ci_db_user="gentooci"
ARG gentoo_ci_db_password="riscv"
ARG gentoo_ci_db_name="gentooci"
ARG gentoo_ci_db_host="db"
ARG repourl="https://git.onfoo.top/Chi-Tan-Da-Eru/gentoo.git"

WORKDIR /tinderbox-cluster

RUN rm .git \
    && sed -i.bak "s/'password' : 'X\?'/'password' : 'riscv'/" master.cfg \
    && sed -i.bak "s|postgresql://buildbot:X@192.0.0.0/buildbot|postgresql://buildbot:riscv@db/buildbot|" master.cfg \
    && sed -i.bak "/#c\['change_source'\] = change_source.gentoo_change_source()/s/#//" master.cfg \
    && sed -i.bak "/c\['services'\] = reporters.gentoo_reporters(r=c\['services'\])/s/^/#/" master.cfg \
    && sed -i.bak "s|postgresql+psycopg2://user:password@host/gentoo-ci|postgresql+psycopg2://$gentoo_ci_db_user:$gentoo_ci_db_password@$gentoo_ci_db_host/$gentoo_ci_db_name|" logparser.json \
    && sed -i.bak "s|postgresql://buildbot:password@ip/gentoo-ci|postgresql://$gentoo_ci_db_user:$gentoo_ci_db_password@$gentoo_ci_db_host/$gentoo_ci_db_name|" gentooci.cfg \
    && sed -i.bak "s|driver://user:pass@localhost/dbname|postgresql://$gentoo_ci_db_user:$gentoo_ci_db_password@$gentoo_ci_db_host/$gentoo_ci_db_name|" buildbot_gentoo_ci/db/migrations/alembic.ini \
    && sed -i.bak -e "s|repourl='https://gitlab.gentoo.org/zorry/gentoo-ci.git'|repourl='$repourl'|" buildbot_gentoo_ci/config/change_source.py \
    && sed -i.bak -e "/project='gentoo-ci'/a category='push'" buildbot_gentoo_ci/config/change_source.py \
    && sed -i.bak -e "/project='gentoo-ci'/s/^/#/" buildbot_gentoo_ci/config/change_source.py \
    && sed -i.bak "/minio/s/^/#/" buildbot_gentoo_ci/steps/logs.py \
    && sed -i.bak "/f.addStep(logs.MakeIssue())/s/^/#/" buildbot_gentoo_ci/config/buildfactorys.py \
    && mkdir /var/lib/buildmaster/gentoo-ci-cloud/secrets -p 
EXPOSE 8010 9989
ENTRYPOINT ["/entrypoint.sh"]
