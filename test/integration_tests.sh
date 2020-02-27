#!/bin/bash

# [Test-Setup]
for test_os in centos:7 centos:8 fedora:28 fedora:29 fedora:30 fedora:31 debian:8; do
  docker build --file Containerfile --build-arg OS_VERSION=$test_os --tag testing-$test_os .
done

# [Test-Run+Validate]
for test_os in centos:7 centos:8 fedora:28 fedora:29 fedora:30 fedora:31 debian:8; do
  GOSS_FILES_PATH=test dgoss run --env-file test/unit-test-service.env testing-$test_os sleep 30
done

