#!/usr/bin/env bash

set -x

# Build the container using the definition in `Containerfile`
## Setting 30 days for cache expiry for layers for now, as we don't need strict
## freshness while exploring things, and this greatly facilitates travel and offline work.
buildah build -t test --cache-ttl=480h --layers .

## Include some buildtime annotations (example):
buildah config --annotation "io.quarkus.core-version=TODO_SET_THIS" "$ctr1"