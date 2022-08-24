#!/usr/bin/env bash

while pg_isready -d gentooci -h db -U gentooci > /dev/null; [ $? -ne 0 ]; do
  sleep 1
done

buildbot create-master -r /master
mv /master/buildbot.tac /tinderbox-cluster
rm -r /master

buildbot checkconfig /tinderbox-cluster

buildbot upgrade-master /tinderbox-cluster

pushd /tinderbox-cluster
rm master.cfg.sample
popd

pushd /tinderbox-cluster/buildbot_gentoo_ci/db/migrations
PYTHONPATH+="/tinderbox-cluster" alembic ensure_version
popd
buildbot start --nodaemon /tinderbox-cluster || cat /tinderbox-cluster/twistd.log
