#!/bin/sh
set -o xtrace

docker ps -aq | xargs --no-run-if-empty docker rm -f
docker images -aq | xargs --no-run-if-empty docker image rm -f
