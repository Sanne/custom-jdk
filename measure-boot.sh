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
    
    #JAVA_PID=$(podman exec -it $TEMP_INTANCE_NAME bash -c "ps -ef | grep java | head -n 1 | awk '{print \$2}'")
    #echo "Found Java process with PID: $JAVA_PID"
    #Not using this variable because it is always one. To check back later.

    podman exec -it $TEMP_INTANCE_NAME bash -c "jcmd 1 VM.native_memory baseline scale=MB" > /dev/null
    podman exec -it $TEMP_INTANCE_NAME bash -c "jcmd 1 VM.native_memory detail scale=MB" >> "$TEMP_INTANCE_NAME"_NMT.log
    until [ -f startedTimestamp ]
    do
        sleep 1
        #Get memory
        podman exec -it $TEMP_INTANCE_NAME bash -c "jcmd 1 VM.native_memory detail scale=MB" >> "$TEMP_INTANCE_NAME"_NMT.log
    done
    
    finishTString=$(cat startedTimestamp)
    forceClean $TEMP_INTANCE_NAME
    #echo "Just before start timestamp: $startTimeMilliseconds"
    #echo "Bootstrap complete timestamp: $finishTString"
    
    deltaMilliseconds=$((finishTString - startTimeMilliseconds))
    echo "Container '$SHORT_CONTAINERNAME' completed bootstrap in $deltaMilliseconds milliseconds"
    echo "It used the following native memory:"
    #cat "$TEMP_INTANCE_NAME"_NMT.log | head -n 62 | tail -n 56
    cat  "$TEMP_INTANCE_NAME"_NMT.log | head -n 7 | tail -n 1
    rm "$TEMP_INTANCE_NAME"_NMT.log
}

measure "jdk23-leyden-build"
measure "fedora-standard"
measure "jdk23-build"
