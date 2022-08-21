#!/usr/bin/env bash

buildbot create-master -r /master
mv /master/buildbot.tac /tinderbox-cluster
buildbot checkconfig /tinderbox-cluster
#FIXME GET CONFIG FROM ENVIRONMENT
