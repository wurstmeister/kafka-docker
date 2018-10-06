#!/bin/bash -e

BASE_IMAGE="wurstmeister/kafka"
docker build --build-arg vcs_ref=$(git rev-parse --short HEAD) -t "$BASE_IMAGE" .
