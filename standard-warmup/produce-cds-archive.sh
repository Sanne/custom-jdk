#!/usr/bin/env bash

mvn package -DskipTests
curl --retry-connrefused --retry 100 --retry-delay 1 -s -o /dev/null "http://localhost:8080/hello/quit" & 
#java -jar target/quarkus-app/quarkus-run.jar
/leyden-openjdk/bin/java -Xlog:cds -XX:CacheDataStore=/leyden-openjdk/quarkus-generic-cds.cds -jar target/quarkus-app/quarkus-run.jar
