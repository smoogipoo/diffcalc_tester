#!/bin/bash

./run-sr.sh "$@" &
./run-pp.sh "$@" &

wait
