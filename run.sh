#!/bin/bash

./run-sr.sh $1 &
./run-pp.sh $1 &

wait
