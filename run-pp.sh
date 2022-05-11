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

function generate() {
    mod_comparator=$1
    sort_mode=$2

    mysql -uroot --execute="
        SELECT
            tbl.score_id,
            b.beatmap_id,
            tbl.enabled_mods,
            b.filename,
            tbl.a_pp as 'pp_master',
            tbl.b_pp as 'pp_pr',
            (tbl.b_pp - tbl.a_pp) as 'diff',
            (tbl.b_pp / tbl.a_pp - 1) as 'diff%'
        FROM (
            SELECT
                a.score_id,
                a.beatmap_id,
                a.enabled_mods,
                a.pp AS 'a_pp',
                b.pp AS 'b_pp'
            FROM osu.osu_scores${HIGH_SCORES_SUFFIX}_high a
            LEFT JOIN osu_pr.osu_scores${HIGH_SCORES_SUFFIX}_high b
                ON a.score_id = b.score_id
            # Simulate a full-outer join
            UNION ALL
                SELECT
                    b.score_id,
                    b.beatmap_id,
                    b.enabled_mods,
                    a.pp AS 'a_pp',
                    b.pp AS 'b_pp'
                FROM osu.osu_scores${HIGH_SCORES_SUFFIX}_high a
                RIGHT JOIN osu_pr.osu_scores${HIGH_SCORES_SUFFIX}_high b
                    ON a.score_id = b.score_id
                WHERE a.score_id IS NULL # Anti-join
        )
        AS tbl
        JOIN osu_pr.osu_beatmaps b
            ON b.beatmap_id = tbl.beatmap_id
        WHERE tbl.${mod_comparator}
        AND (
            tbl.a_pp IS NOT NULL
            OR tbl.b_pp IS NOT NULL
        )
        AND (
            tbl.a_pp IS NULL
            OR tbl.b_pp IS NULL
            OR abs(tbl.a_pp - tbl.b_pp) > 0.1
        )
        ORDER BY
            # Nulls at the top of the list (most importance)
            (
                tbl.a_pp IS NULL
                OR tbl.b_pp IS NULL
            ) DESC,
            # Then order by diff
            tbl.b_pp - tbl.a_pp ${sort_mode}
        LIMIT 10000;"
}

generate "enabled_mods >= 0" "DESC" > pp_gains_all.csv &
generate "enabled_mods >= 0" "ASC" > pp_losses_all.csv &
generate "enabled_mods = 0" "DESC" > pp_gains_nm.csv &
generate "enabled_mods = 0" "ASC" > pp_losses_sr.csv &

wait