#!/usr/bin/env bash

mvn package -DskipTests
curl --retry-connrefused --retry 100 --retry-delay 1 -s -o /dev/null "http://localhost:8080/hello/quit" & 
#java -jar target/quarkus-app/quarkus-run.jar
#Setting -XX:+UseG1GC explicitly as we need it to be consistent with runtime choices (it's the default but ergonomics might change that).
/leyden-openjdk/bin/java -Xlog:cds -XX:+ArchiveInvokeDynamic -XX:+UseG1GC -XX:CacheDataStore=/leyden-openjdk/quarkus-generic-cds.cds -jar target/quarkus-app/quarkus-run.jar
