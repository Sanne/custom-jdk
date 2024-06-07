#!/usr/bin/env bash

forceClean() {
    podman rm -f measurement > /dev/null
    rm --force startedTimestamp
}

measure() {
    CONTAINER=$1
    forceClean
    
    while [[ "$(curl -s -o startedTimestamp -w ''%{http_code}'' localhost:8080/currenttime)" != "200" ]]; do sleep .00001; done &
    
    startTimeMilliseconds=$(($(date --utc +%s%N)/1000000))
    
    # See also: https://fossies.org/linux/podman/troubleshooting.md
    # TODO: experimenbt with --cpuset-mems=0 --memory 1000m
    podman run --pull=never --read-only --rm -d -p 8080:8080 --cpus 4 --name measurement $CONTAINER
    
    until [ -f startedTimestamp ]
    do
        sleep 1
    done
    echo "Waiting ..."
    sleep 100 
    
    podman rm -f measurement > /dev/null
    finishTString=$(cat startedTimestamp)
    #echo "Just before start timestamp: $startTimeMilliseconds"
    #echo "Bootstrap complete timestamp: $finishTString"
    
    deltaMilliseconds=$((finishTString - startTimeMilliseconds))
    echo "Container $CONTAINER completed bootstrap in $deltaMilliseconds milliseconds"
}

measure "localhost/leyden-build:latest"
measure "localhost/baseline-boot:latest"
