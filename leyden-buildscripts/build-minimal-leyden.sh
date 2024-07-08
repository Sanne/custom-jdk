#!/usr/bin/env bash

#Enforce clean state, useful for locally run tests:
rm -Rf build

#Shared flags for both builds:
#Local custom: --with-num-cores=12 --with-memory-size=55000 --with-boot-jdk=/opt/jdk-22+33 
COMMON="--with-jvm-variants=custom --disable-manpages --with-vendor-name=Experiments --disable-full-docs"

#These are the features selected for stage1 build: subsequent stages might trim this selection further:
STAGE1_FEATURES=cds,compiler1,compiler2,g1gc,serialgc,jfr,jvmti,management,services
#STAGE2 is the same as STAGE1 but excluding serialgc:
STAGE2_FEATURES=cds,compiler1,compiler2,g1gc,jfr,jvmti,management,services

bash configure --with-conf-name=stage1 $COMMON --with-jvm-features=$STAGE1_FEATURES

CONF=stage1 make clean
CONF=stage1 make images

bash configure --with-build-jdk=build/stage1/images/jdk/ --with-conf-name=stage2 $COMMON --with-jvm-features=$STAGE2_FEATURES

CONF=stage2 make clean
CONF=stage2 make images
