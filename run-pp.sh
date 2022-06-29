#!/bin/bash

source ./common.sh

function generate() {
    mod_comparator=$1
    sort_mode=$2

    existing_pp_query=""

    if [[ $ONLY_EXISTING_PP == 1 ]]; then
        existing_pp_query="AND tbl.a_pp != 0"
    fi

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
        ${BEATMAP_COMPARATOR}
        AND (
            # For the time being, we also care about PP going from non-null -> null.
            # Caring about null -> not-null will be too verbose when new attributes are added.
            (
                tbl.a_pp IS NOT NULL
                AND tbl.b_pp IS NULL
            )
            OR abs(tbl.a_pp - tbl.b_pp) > 0.1
        )
        ${existing_pp_query}
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
generate "enabled_mods = 0" "ASC" > pp_losses_nm.csv &

wait