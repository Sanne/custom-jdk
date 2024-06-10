# custom-jdk
Experiment: potential of a customized JDK for Quarkus

Some scripts to measure bootstrap, memory and warmup times of a Quarkus application
across various JDK flavours.

Currently testing with:
 - OpenJDK 21, as provided by standard rpms in Fedora 40
 - The Leyden project, based on OpenJDK 23 built from sources in latest `premain` branch
 - The OpenJDK 23, also built from sources in a similar way to the Leyden build

## Requirements

We're using buildah to create the container image: install [buildah](https://buildah.io/) first:

    sudo dnf install buildah

N.B. buildah requires Linux and is not available on other OSes.

## Use

Make sure buildha is installed, then have fun with the following scripts:

To build all necessary images, run:

    bash build-container.sh

To measure impact of the various solutions, run:

    bash measure-boot.sh

(This might need to "sudo", so might ask your password)

## TODO

Improve measurements: currently only looking at bootstrap times.
 - native memory consumption
 - reuse of CDS archives in detail (is it working?)
 - play with other condensers as they get developed (none availablet yet)
 - figure out if C2 compilation benefits are effectively transferable to other applications
 - is it worth automating repeating measurements multiple times? Currently they seem fairly stable but this might change.

JLink
 - Would like to add variants using JLink-optimised JVMs, and combined with Leyden

Various other TODOs & wishes:
- Add OpenJDK 21 built from sources in similar ways to have more comparison data
- Explore behaviour of Leyden vs non Leyden in constrained environments
- Get a baseline of podman starting an empty container, to better understand the benefits of Leyden
- Analyze podman+JVM boostrap process as a combination
