#!/bin/bash

MODE=$1
HIGH_SCORES_SUFFIX=""

case "$MODE" in
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
        echo "Ruleset identifier not provided"
        exit 1;
        ;;
esac

# Get combined PP gains
mysql -uroot --execute="
    SELECT
        m.score_id,
        m.beatmap_id,
        m.enabled_mods,
        b.filename,
        m.pp as 'pp_master',
        p.pp as 'pp_pr',
        (p.pp - m.pp) as 'diff',
        (p.pp / m.pp - 1) as 'diff%'
    FROM osu.osu_scores${HIGH_SCORES_SUFFIX}_high m
    JOIN osu_pr.osu_scores${HIGH_SCORES_SUFFIX}_high p
        ON m.score_id = p.score_id
    JOIN osu_pr.osu_beatmaps b
        ON b.beatmap_id = p.beatmap_id
    WHERE abs(m.pp - p.pp) > 0.1
    ORDER BY p.pp - m.pp
        DESC
    LIMIT 10000;" \
> pp_gains_all.csv &

# Get combined PP losses
mysql -uroot --execute="
    SELECT
        m.score_id,
        m.beatmap_id,
        m.enabled_mods,
        b.filename,
        m.pp as 'pp_master',
        p.pp as 'pp_pr',
        (p.pp - m.pp) as 'diff',
        (p.pp / m.pp - 1) as 'diff%'
    FROM osu.osu_scores${HIGH_SCORES_SUFFIX}_high m
    JOIN osu_pr.osu_scores${HIGH_SCORES_SUFFIX}_high p
        ON m.score_id = p.score_id
    JOIN osu_pr.osu_beatmaps b
        ON b.beatmap_id = p.beatmap_id
    WHERE abs(m.pp - p.pp) > 0.1
    ORDER BY p.pp - m.pp
        ASC
    LIMIT 10000;" \
> pp_losses_all.csv &

# Get NoMod PP gains
mysql -uroot --execute="
    SELECT
        m.score_id,
        m.beatmap_id,
        m.enabled_mods,
        b.filename,
        m.pp as 'pp_master',
        p.pp as 'pp_pr',
        (p.pp - m.pp) as 'diff',
        (p.pp / m.pp - 1) as 'diff%'
    FROM osu.osu_scores${HIGH_SCORES_SUFFIX}_high m
    JOIN osu_pr.osu_scores${HIGH_SCORES_SUFFIX}_high p
        ON m.score_id = p.score_id
    JOIN osu_pr.osu_beatmaps b
        ON b.beatmap_id = p.beatmap_id
    WHERE m.enabled_mods = 0
    AND abs(m.pp - p.pp) > 0.1
    ORDER BY p.pp - m.pp
        DESC
    LIMIT 10000;" \
> pp_gains_nm.csv &

# Get NoMod PP losses
mysql -uroot --execute="
    SELECT
        m.score_id,
        m.beatmap_id,
        m.enabled_mods,
        b.filename,
        m.pp as 'pp_master',
        p.pp as 'pp_pr',
        (p.pp - m.pp) as 'diff',
        (p.pp / m.pp - 1) as 'diff%'
    FROM osu.osu_scores${HIGH_SCORES_SUFFIX}_high m
    JOIN osu_pr.osu_scores${HIGH_SCORES_SUFFIX}_high p
        ON m.score_id = p.score_id
    JOIN osu_pr.osu_beatmaps b
        ON b.beatmap_id = p.beatmap_id
    WHERE m.enabled_mods = 0
    AND abs(m.pp - p.pp) > 0.1
    ORDER BY p.pp - m.pp
        ASC
    LIMIT 10000;" \
> pp_losses_nm.csv &

wait
