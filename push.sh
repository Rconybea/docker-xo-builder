#!/usr/bin/env bash

IMAGE=docker-xo-builder:v1
OWNER=rconybea

docker image tag ${IMAGE} ghcr.io/${OWNER}/${IMAGE}
docker image push ghcr.io/${OWNER}/${IMAGE}

