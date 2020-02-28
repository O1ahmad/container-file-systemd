#!/bin/bash

# [Test-Setup]
cat <<OS | xargs -I % docker build --file Containerfile --build-arg OS_VERSION=% --tag testing-% .
centos:7
centos:8
fedora:28
fedora:29
fedora:30
fedora:31
debian:8
OS

# [Test-Run+Validate]
export GOSS_FILES_PATH=test
cat <<OS | xargs -I % dgoss run --env-file test/unit-test-service.env testing-% sleep 30
centos:7
centos:8
fedora:28
fedora:29
fedora:30
fedora:31
debian:8
OS
unset GOSS_FILES_PATH
