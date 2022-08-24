# name the portage image
FROM gentoo/portage:latest as portage

# based on stage3 image
FROM gentoo/stage3:latest

# copy the entire portage volume in
COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

ARG MIRROR_URL="https://mirrors.ustc.edu.cn/gentoo"

#COPY portage_config /etc/portage
#COPY portage_config/make.conf /make.conf
#COPY portage_config/binrepos.conf /etc/portage/binrepos.conf
#COPY portage_config/package.use /etc/portage/package.use
#COPY package.mask /etc/portage/package.mask
#COPY portage_config/package.accept_keywords /etc/portage/package.accept_keywords
COPY tinderbox-cluster-riscv/patches/bb-gitlab.patch /bb-gitlab.patch

RUN echo -e "[binhost]\npriority = 9999\nsync-uri = $MIRROR_URL/experimental/amd64/binpkg/default/linux/17.1/x86-64/" | cat >> /etc/portage/binrepos.conf \
    && echo "EMERGE_DEFAULT_OPTS=\"--usepkg=y --binpkg-respect-use=y --getbinpkg=y --autounmask-write --autounmask-continue --autounmask-keep-keywords=y --autounmask-use=y\"" | cat >> /etc/portage/make.conf \
    && echo "FEATURES=\"-ipc-sandbox -pid-sandbox -network-sandbox -usersandbox -mount-sandbox sandbox parallel-install parallel-fetch -merge-sync buildpkg\"" | cat >> /etc/portage/make.conf \
    && echo "GENTOO_MIRRORS=\" $MIRROR_URL \"" | cat >> /etc/portage/make.conf \
    && echo -e "dev-util/buildbot docker\ndev-db/postgresql -server\nx11-libs/cairo X\nx11-libs/gdk-pixbuf jpeg" | cat >> /etc/portage/package.use/buildbot \
    && echo "dev-vcs/git -webdev -gnome-keyring" | cat >> /etc/portage/package.use/git \
    && echo -e "dev-util/buildbot ~amd64\ndev-util/buildbot-badges ~amd64\ndev-util/buildbot-console-view ~amd64\ndev-util/buildbot-grid-view ~amd64\ndev-util/buildbot-waterfall-view ~amd64\ndev-util/buildbot-wsgi-dashboards ~amd64\ndev-util/buildbot-www ~amd64\ndev-util/buildbot-pkg ~amd64\ndev-python/klein ~amd64\ndev-python/tubes ~amd64\ndev-python/txrequests ~amd64" | cat >> /etc/portage/package.accept_keywords/buildbot \
    # && echo -e "-----------------------------------\n" \
    # && cat /etc/portage/binrepos.conf \
    # && cat /etc/portage/package.accept_keywords/buildbot \
    # && cat /etc/portage/make.conf \
    # && cat /etc/portage/package.use/buildbot \
    # && cat /etc/portage/package.use/git \
    # && echo -e "------------------------------------\n" \
    && mkdir -p /etc/portage/patches/dev-util/buildbot-3.5.0-r1 \
    && mv /bb-gitlab.patch /etc/portage/patches/dev-util/buildbot-3.5.0-r1 \
    && emerge --noreplace --update --with-bdeps=y --jobs=16 dev-vcs/git \
                  dev-lang/rust-bin \
                  www-client/pybugz \
                  dev-python/GitPython dev-python/pygit2 \
                  dev-python/psycopg:2 \
                  dev-python/requests \
                  dev-python/txrequests \
                  dev-util/buildbot \
                  dev-util/buildbot-badges \
                  dev-util/buildbot-console-view dev-util/buildbot-grid-view dev-util/buildbot-waterfall-view dev-util/buildbot-wsgi-dashboards \
                  dev-util/buildbot-www \
    && rm -rf /var/cache/distfiles \
    && rm -rf /var/cache/binpkgs
