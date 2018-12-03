#!/bin/bash

IMAGE=csmith/aoc-2018-02

docker image inspect $IMAGE >/dev/null 2>&1
if [ $? -ne 0 ]
then
    echo "One time setup: building docker image..."
    cd docker
    docker build . -t $IMAGE
    cd ..
fi

docker run --rm -it -v $(pwd):/code $IMAGE /entrypoint.sh $@