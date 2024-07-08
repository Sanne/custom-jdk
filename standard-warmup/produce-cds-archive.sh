#!/usr/bin/env bash

mvn package -DskipTests
curl --retry-connrefused --retry 100 --retry-delay 1 -s -o /dev/null "http://localhost:8080/hello/quit" & 
/leyden-openjdk/bin/java --version
#Setting -XX:+UseG1GC explicitly as we need it to be consistent with runtime choices (it's the default but ergonomics might change that).
#Need to set G1HeapRegionSize and have it match the same value at runtime: see https://bugs.openjdk.org/browse/JDK-8335440
/leyden-openjdk/bin/java -XX:G1HeapRegionSize=1048576 -Xlog:cds -XX:+ArchiveInvokeDynamic -XX:+UseG1GC -XX:CacheDataStore=/leyden-openjdk/quarkus-generic-cds.cds -jar target/quarkus-app/quarkus-run.jar
