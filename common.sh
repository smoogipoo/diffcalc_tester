#!/bin/bash

MODE_LITERAL=$1

RANKED_ONLY=0
MODE_NUMERIC=0
HIGH_SCORES_SUFFIX=""
ONLY_EXISTING_PP=0

BEATMAP_COMPARATOR=""

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

while (( $# )); do
    case $1 in
        # Only process scores/beatmaps from the given ruleset.
        -nc|--no-converts)
            BEATMAP_COMPARATOR+="AND b.playmode = $MODE_NUMERIC "
            ;;
        # Only process ranked scores/beatmaps
        -ro|--ranked-only)
            BEATMAP_COMPARATOR+="AND b.approved IN (1, 2) "
            ;;
        # Only process scores that had an existing non-zero PP.
        -ex|--only-existing-pp)
            ONLY_EXISTING_PP=1
            ;;
    esac
    shift
done