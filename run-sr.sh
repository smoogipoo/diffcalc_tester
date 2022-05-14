#!/bin/bash

source ./common.sh

function generate() {
    mod_comparator=$1
    sort_mode=$2

    mysql -uroot --execute="
        SELECT
            b.beatmap_id,
            tbl.mods,
            b.filename,
            tbl.a_diff_unified as 'sr_master',
            tbl.b_diff_unified as 'sr_pr',
            (tbl.b_diff_unified - tbl.a_diff_unified) as 'diff',
            (tbl.b_diff_unified / tbl.a_diff_unified - 1) as 'diff%'
        FROM (
            SELECT
                a.beatmap_id,
                a.mods,
                a.mode,
                a.diff_unified AS 'a_diff_unified',
                b.diff_unified AS 'b_diff_unified'
            FROM osu.osu_beatmap_difficulty a
            LEFT JOIN osu_pr.osu_beatmap_difficulty b
                ON a.beatmap_id = b.beatmap_id
                AND a.mode = b.mode
                AND a.mods = b.mods
            # Simulate a full-outer join
            UNION ALL
                SELECT
                    b.beatmap_id,
                    b.mods,
                    b.mode,
                    a.diff_unified AS 'a_diff_unified',
                    b.diff_unified AS 'b_diff_unified'
                FROM osu.osu_beatmap_difficulty a
                RIGHT JOIN osu_pr.osu_beatmap_difficulty b
                    ON a.beatmap_id = b.beatmap_id
                    AND a.mode = b.mode
                    AND a.mods = b.mods
                WHERE a.beatmap_id IS NULL # Anti-join
        )
        AS tbl
        JOIN osu_pr.osu_beatmaps b
            ON b.beatmap_id = tbl.beatmap_id
        WHERE tbl.mode = ${MODE_NUMERIC}
        AND tbl.${mod_comparator}
        ${BEATMAP_COMPARATOR}
        AND (
            # For the time being, we also care about SR going from non-null -> null.
            # Caring about null -> not-null will be too verbose when new attributes are added.
            (
                tbl.a_diff_unified IS NOT NULL
                AND tbl.b_diff_unified IS NULL
            )
            OR abs(tbl.a_diff_unified - tbl.b_diff_unified) > 0.1
        )
        ORDER BY
            # Nulls at the top of the list (most importance)
            (
                tbl.a_diff_unified IS NULL
                OR tbl.b_diff_unified IS NULL
            ) DESC,
            # Then order by diff
            tbl.b_diff_unified - tbl.a_diff_unified ${sort_mode}
        LIMIT 10000;"
}

generate "mods >= 0" "DESC" > sr_gains_all.csv &
generate "mods >= 0" "ASC" > sr_losses_all.csv &
generate "mods = 0" "DESC" > sr_gains_nm.csv &
generate "mods = 0" "ASC" > sr_losses_nm.csv &

wait
