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

# Get combined SR gains
mysql -uroot --execute="
    SELECT
        p.beatmap_id,
        p.mods,
        b.filename,
        m.diff_unified as 'sr_master',
        p.diff_unified as 'sr_pr',
        (p.diff_unified - m.diff_unified) as 'diff',
        (p.diff_unified / m.diff_unified - 1) as 'diff%'
    FROM osu.osu_beatmap_difficulty m
    RIGHT JOIN osu_pr.osu_beatmap_difficulty p
        ON m.beatmap_id = p.beatmap_id
        AND m.mode = p.mode
        AND m.mods = p.mods
    JOIN osu_pr.osu_beatmaps b
        ON b.beatmap_id = p.beatmap_id
    WHERE m.beatmap_id is null
    OR (
        m.mode = ${MODE_NUMERIC}
        AND abs(m.diff_unified - p.diff_unified) > 0.1
    )
    ORDER BY p.diff_unified - m.diff_unified
        DESC
    LIMIT 10000;" \
> sr_gains_all.csv &

# Get combined SR losses
mysql -uroot --execute="
    SELECT
        p.beatmap_id,
        p.mods,
        b.filename,
        m.diff_unified as 'sr_master',
        p.diff_unified as 'sr_pr',
        (p.diff_unified - m.diff_unified) as 'diff',
        (p.diff_unified / m.diff_unified - 1) as 'diff%'
    FROM osu.osu_beatmap_difficulty m
    RIGHT JOIN osu_pr.osu_beatmap_difficulty p
        ON m.beatmap_id = p.beatmap_id
        AND m.mode = p.mode
        AND m.mods = p.mods
    JOIN osu_pr.osu_beatmaps b
        ON b.beatmap_id = p.beatmap_id
    WHERE m.beatmap_id is null
    OR (
        m.mode = ${MODE_NUMERIC}
        AND abs(m.diff_unified - p.diff_unified) > 0.1
    )
    ORDER BY p.diff_unified - m.diff_unified
        ASC
    LIMIT 10000;" \
> sr_losses_all.csv &

# Get NoMod SR gains
mysql -uroot --execute="
    SELECT
        p.beatmap_id,
        p.mods,
        b.filename,
        m.diff_unified as 'sr_master',
        p.diff_unified as 'sr_pr',
        (p.diff_unified - m.diff_unified) as 'diff',
        (p.diff_unified / m.diff_unified - 1) as 'diff%'
    FROM osu.osu_beatmap_difficulty m
    RIGHT JOIN osu_pr.osu_beatmap_difficulty p
        ON m.beatmap_id = p.beatmap_id
        AND m.mode = p.mode
        AND m.mods = p.mods
    JOIN osu_pr.osu_beatmaps b
        ON b.beatmap_id = p.beatmap_id
    WHERE m.beatmap_id is null
    OR (
        m.mods = 0
        AND m.mode = ${MODE_NUMERIC}
        AND abs(m.diff_unified - p.diff_unified) > 0.1
    )
    ORDER BY p.diff_unified - m.diff_unified
        DESC
    LIMIT 10000;" \
> sr_gains_nm.csv &

# Get NoMod SR losses
mysql -uroot --execute="
    SELECT
        p.beatmap_id,
        p.mods,
        b.filename,
        m.diff_unified as 'sr_master',
        p.diff_unified as 'sr_pr',
        (p.diff_unified - m.diff_unified) as 'diff',
        (p.diff_unified / m.diff_unified - 1) as 'diff%'
    FROM osu.osu_beatmap_difficulty m
    RIGHT JOIN osu_pr.osu_beatmap_difficulty p
        ON m.beatmap_id = p.beatmap_id
        AND m.mode = p.mode
        AND m.mods = p.mods
    JOIN osu_pr.osu_beatmaps b
        ON b.beatmap_id = p.beatmap_id
    WHERE m.beatmap_id is null
    OR (
        m.mods = 0
        AND m.mode = ${MODE_NUMERIC}
        AND abs(m.diff_unified - p.diff_unified) > 0.1
    )
    ORDER BY p.diff_unified - m.diff_unified
        ASC
    LIMIT 10000;" \
> sr_losses_nm.csv &

wait
