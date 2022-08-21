# name the portage image
FROM gentoo/portage:latest as portage

# based on stage3 image
FROM gentoo/stage3:latest

# copy the entire portage volume in
COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

#COPY portage /etc/portage
COPY portage_config/make.conf /make.conf
COPY portage_config/binrepos.conf /etc/portage/binrepos.conf
COPY portage_config/package.use /etc/portage/package.use
#COPY package.mask /etc/portage/package.mask
COPY portage_config/package.accept_keywords /etc/portage/package.accept_keywords

RUN cat /make.conf >> /etc/portage/make.conf \
    && emerge -qv dev-vcs/git \
                  www-client/pybugz \
                  dev-python/GitPython dev-python/pygit2 \
                  dev-python/requests \
                  dev-python/txrequests \
                  dev-util/buildbot \
                  dev-util/buildbot-badges \
                  dev-util/buildbot-console-view dev-util/buildbot-grid-view dev-util/buildbot-waterfall-view dev-util/buildbot-wsgi-dashboards \
                  dev-util/buildbot-www

COPY tinderbox-cluster-riscv /tinderbox-cluster
COPY buildbot_config/master.cfg /tinderbox-cluster/master.cfg
COPY buildbot_config/gentooci.cfg /tinderbox-cluster/gentooci.cfg
COPY buildbot_config/logparser.json /tinderbox-cluster/logparser.json

COPY entrypoint.sh /entrypoint.sh

EXPOSE 8010 9989
ENTRYPOINT ['/entrypoint.sh']
