#!/bin/bash

cd /code

if [ -f "day$1.nim" ]; then
    if [ ! -f "day$1" -o "day$1.nim" -nt "day$1" ]; then
        HOME=/tmp nim c --opt:speed -d:release day$1.nim >/dev/null 2>&1
    fi
    time ./day$1
fi