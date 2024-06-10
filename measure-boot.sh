#!/usr/bin/env bash

forceClean() {
    podman rm -f $1 > /dev/null
    rm --force startedTimestamp
}

preMeasure() {
    sync && sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
}

measure() {
    SHORT_CONTAINERNAME=$1
    FULLCONTAINERNAME="localhost/$SHORT_CONTAINERNAME:latest"
    TEMP_INTANCE_NAME="measure_$SHORT_CONTAINERNAME"
    forceClean $TEMP_INTANCE_NAME
    
    while [[ "$(curl -s -o startedTimestamp -w ''%{http_code}'' localhost:8080/currenttime)" != "200" ]]; do sleep .00001; done &
    
    preMeasure
    startTimeMilliseconds=$(($(date --utc +%s%N)/1000000))
    
    # Options such as cpuset-mems=0 might require some extra system settings; see: https://fossies.org/linux/podman/troubleshooting.md
    #TODO pick specific CPUs
    podman run --pull=never --read-only --rm -d -p 8080:8080 --cpus 4 --cpuset-mems=0 --memory 2000m --name $TEMP_INTANCE_NAME $FULLCONTAINERNAME > /dev/null

    # For experiments:
    # podman run --pull=never --read-only --rm -it -p 8080:8080 --cpus 4 --cpuset-mems=0 --memory 2000m --name measurement localhost/leyden-build:latest
    
    until [ -f startedTimestamp ]
    do
        sleep 1
    done
    #TODO get memory data sleep 100
    
    finishTString=$(cat startedTimestamp)
    forceClean $TEMP_INTANCE_NAME
    #echo "Just before start timestamp: $startTimeMilliseconds"
    #echo "Bootstrap complete timestamp: $finishTString"
    
    deltaMilliseconds=$((finishTString - startTimeMilliseconds))
    echo "Container '$SHORT_CONTAINERNAME' completed bootstrap in $deltaMilliseconds milliseconds"
}

measure "jdk23-leyden-build"
measure "fedora-standard"
measure "jdk23-build"
