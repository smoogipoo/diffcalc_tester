#!/bin/bash

MODE_LITERAL=$1

NO_CONVERTS=0
MODE_NUMERIC=0
HIGH_SCORES_SUFFIX=""

case "$MODE_LITERAL" in
    "osu")
        MODE_NUMERIC=0
        ;;
    "taiko")
        MODE_NUMERIC=1
        HIGH_SCORES_SUFFIX="_taiko"
        ;;
    "catch")
        MODE_NUMERIC=2
        HIGH_SCORES_SUFFIX="_fruits"
        ;;
    "mania")
        MODE_NUMERIC=3
        HIGH_SCORES_SUFFIX="_mania"
        ;;
    *)
        echo "Ruleset argument not provided."
        exit 1;
        ;;
esac

while :; do
    case $1 in
        --no-converts)
            NO_CONVERTS=1
            ;;
        *) break
    esac
    shift
done