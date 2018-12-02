#!/bin/bash

IMAGE=csmith/aoc-2018

echo "Building docker image..."
docker build . -t $IMAGE

echo "To manually run without rebuilding:"
echo "   docker run --rm -it $IMAGE /entrypoint.sh $@"

docker run --rm -it $IMAGE /entrypoint.sh $@