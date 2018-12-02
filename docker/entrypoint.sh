#!/bin/bash

cd /code
time pypy3 ${1:-$(find -regex './[0-9]+.py' | sort | tail -n 1)}