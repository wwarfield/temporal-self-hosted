
/* Generated Migration:
 * Admin Tools Version: 1.24.2-tctl-1.18.1-cli-1.0.0
 * Temporal Migration Version: 1.1
 * Date: 2024-08-23 17:08:11.472883
 */


SET search_path TO temporal_visibility;

CREATE INDEX by_close_time_by_status ON executions_visibility (namespace_id, close_time DESC, run_id, status);




INSERT into schema_version(version_partition, db_name, creation_time, curr_version, min_compatible_version)
VALUES (0,'temporal',now(),'1.1','0.1')
    ON CONFLICT (version_partition, db_name) DO UPDATE
        SET creation_time = excluded.creation_time,
            curr_version = excluded.curr_version,
            min_compatible_version = excluded.min_compatible_version;

INSERT INTO schema_update_history
(version_partition, "year", "month", update_time, description, manifest_md5, new_version, old_version)
VALUES(0, date_part('year', now()), date_part('month', now()), now(), 'add close time & status index', '', '1.1', '0.1');