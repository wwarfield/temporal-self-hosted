
/* Generated Migration:
 * Admin Tools Version: 1.24.2-tctl-1.18.1-cli-1.0.0
 * Temporal Migration Version: 1.4
 * Date: 2024-08-23 17:08:11.477161
 */


SET search_path TO temporal_visibility;

ALTER TABLE executions_visibility ADD COLUMN execution_duration BIGINT NULL;
CREATE INDEX by_execution_duration ON executions_visibility (namespace_id, execution_duration, (COALESCE(close_time, '9999-12-31 23:59:59')) DESC, start_time DESC, run_id);

ALTER TABLE executions_visibility ADD COLUMN parent_workflow_id VARCHAR(255) NULL;
ALTER TABLE executions_visibility ADD COLUMN parent_run_id      VARCHAR(255) NULL;
CREATE INDEX by_parent_workflow_id  ON executions_visibility (namespace_id, parent_workflow_id, (COALESCE(close_time, '9999-12-31 23:59:59')) DESC, start_time DESC, run_id);
CREATE INDEX by_parent_run_id       ON executions_visibility (namespace_id, parent_run_id,      (COALESCE(close_time, '9999-12-31 23:59:59')) DESC, start_time DESC, run_id);

ALTER TABLE executions_visibility ADD COLUMN state_transition_count BIGINT NULL;
CREATE INDEX by_state_transition_count ON executions_visibility (namespace_id, state_transition_count, (COALESCE(close_time, '9999-12-31 23:59:59')) DESC, start_time DESC, run_id);




INSERT into schema_version(version_partition, db_name, creation_time, curr_version, min_compatible_version)
VALUES (0,'temporal',now(),'1.4','0.1')
    ON CONFLICT (version_partition, db_name) DO UPDATE
        SET creation_time = excluded.creation_time,
            curr_version = excluded.curr_version,
            min_compatible_version = excluded.min_compatible_version;

INSERT INTO schema_update_history
(version_partition, "year", "month", update_time, description, manifest_md5, new_version, old_version)
VALUES(0, date_part('year', now()), date_part('month', now()), now(), 'add execution duration, state transition count and parent workflow info columns, and indices', '', '1.4', '0.1');