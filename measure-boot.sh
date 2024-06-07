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
    
    # Options such as cpuset-mems=0 might require some extra system settings; see: https://fossies.org/linux/podman/troubleshooting.md
    podman run --pull=never --read-only --rm -d -p 8080:8080 --cpus 4 --cpuset-mems=0 --memory 2000m --name measurement $CONTAINER > /dev/null
    
    until [ -f startedTimestamp ]
    do
        sleep 1
    done
    
    finishTString=$(cat startedTimestamp)
    forceClean
    #echo "Just before start timestamp: $startTimeMilliseconds"
    #echo "Bootstrap complete timestamp: $finishTString"
    
    deltaMilliseconds=$((finishTString - startTimeMilliseconds))
    echo "Container $CONTAINER completed bootstrap in $deltaMilliseconds milliseconds"
}

measure "localhost/leyden-build:latest"
measure "localhost/baseline-boot:latest"
