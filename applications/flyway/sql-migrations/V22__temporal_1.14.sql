
/* Generated Migration:
 * Admin Tools Version: 1.25.1-tctl-1.18.1-cli-1.1.0
 * Temporal Migration Version: 1.14
 * Date: 2024-10-12 16:08:21.526568
 */


SET search_path TO temporal_default;

ALTER TABLE current_executions ADD COLUMN start_time TIMESTAMP NULL;



INSERT into schema_version(version_partition, db_name, creation_time, curr_version, min_compatible_version)
VALUES (0,'temporal',now(),'1.14','1.0')
    ON CONFLICT (version_partition, db_name) DO UPDATE
        SET creation_time = excluded.creation_time,
            curr_version = excluded.curr_version,
            min_compatible_version = excluded.min_compatible_version;

INSERT INTO schema_update_history
(version_partition, "year", "month", update_time, description, manifest_md5, new_version, old_version)
VALUES(0, date_part('year', now()), date_part('month', now()), now(), 'Add new start_time column', '', '1.14', '1.0');