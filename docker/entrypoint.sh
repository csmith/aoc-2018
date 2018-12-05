#!/bin/bash

cd /code

if [ -f "day$1.nim" ]; then
    HOME=/tmp nim c --opt:speed -d:release day$1.nim >/dev/null 2>&1
    time ./day$1
else
    time pypy "$1.py"
fi