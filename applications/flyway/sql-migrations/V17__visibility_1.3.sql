
/* Generated Migration:
 * Admin Tools Version: 1.24.2-tctl-1.18.1-cli-1.0.0
 * Temporal Migration Version: 1.3
 * Date: 2024-08-23 17:08:11.475584
 */


SET search_path TO temporal_visibility;

ALTER TABLE executions_visibility ADD COLUMN BuildIds JSONB GENERATED ALWAYS AS (search_attributes->'BuildIds') STORED;
CREATE INDEX by_build_ids ON executions_visibility USING GIN (namespace_id, BuildIds jsonb_path_ops);

ALTER TABLE executions_visibility ADD COLUMN history_size_bytes BIGINT NULL;
CREATE INDEX by_history_size_bytes ON executions_visibility (namespace_id, history_size_bytes, (COALESCE(close_time, '9999-12-31 23:59:59')) DESC, start_time DESC, run_id);




INSERT into schema_version(version_partition, db_name, creation_time, curr_version, min_compatible_version)
VALUES (0,'temporal',now(),'1.3','0.1')
    ON CONFLICT (version_partition, db_name) DO UPDATE
        SET creation_time = excluded.creation_time,
            curr_version = excluded.curr_version,
            min_compatible_version = excluded.min_compatible_version;

INSERT INTO schema_update_history
(version_partition, "year", "month", update_time, description, manifest_md5, new_version, old_version)
VALUES(0, date_part('year', now()), date_part('month', now()), now(), 'add history size bytes and build IDs visibility columns and indices', '', '1.3', '0.1');