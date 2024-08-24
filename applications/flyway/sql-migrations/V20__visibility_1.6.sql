
/* Generated Migration:
 * Admin Tools Version: 1.24.2-tctl-1.18.1-cli-1.0.0
 * Temporal Migration Version: 1.6
 * Date: 2024-08-23 17:08:11.480479
 */


SET search_path TO temporal_visibility;

DROP INDEX by_root_workflow_id;
DROP INDEX by_root_run_id;
ALTER TABLE executions_visibility DROP COLUMN root_workflow_id;
ALTER TABLE executions_visibility DROP COLUMN root_run_id;

ALTER TABLE executions_visibility ADD COLUMN root_workflow_id VARCHAR(255) NOT NULL DEFAULT '';
ALTER TABLE executions_visibility ADD COLUMN root_run_id      VARCHAR(255) NOT NULL DEFAULT '';
CREATE INDEX by_root_workflow_id  ON executions_visibility (namespace_id, root_workflow_id, (COALESCE(close_time, '9999-12-31 23:59:59')) DESC, start_time DESC, run_id);
CREATE INDEX by_root_run_id       ON executions_visibility (namespace_id, root_run_id,      (COALESCE(close_time, '9999-12-31 23:59:59')) DESC, start_time DESC, run_id);




INSERT into schema_version(version_partition, db_name, creation_time, curr_version, min_compatible_version)
VALUES (0,'temporal',now(),'1.6','0.1')
    ON CONFLICT (version_partition, db_name) DO UPDATE
        SET creation_time = excluded.creation_time,
            curr_version = excluded.curr_version,
            min_compatible_version = excluded.min_compatible_version;

INSERT INTO schema_update_history
(version_partition, "year", "month", update_time, description, manifest_md5, new_version, old_version)
VALUES(0, date_part('year', now()), date_part('month', now()), now(), 'fix root workflow info columns', '', '1.6', '0.1');