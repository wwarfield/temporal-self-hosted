
/* Generated Migration:
 * Admin Tools Version: 1.24.2-tctl-1.18.1-cli-1.0.0
 * Temporal Migration Version: 1.5
 * Date: 2024-08-23 17:08:11.459424
 */


SET search_path TO temporal_default;

ALTER TABLE cluster_membership ALTER COLUMN rpc_address TYPE VARCHAR(128);

ALTER TABLE history_node ADD prev_txn_id BIGINT NOT NULL DEFAULT 0;

ALTER TABLE executions ADD db_record_version BIGINT NOT NULL DEFAULT 0;




INSERT into schema_version(version_partition, db_name, creation_time, curr_version, min_compatible_version)
VALUES (0,'temporal',now(),'1.5','1.0')
    ON CONFLICT (version_partition, db_name) DO UPDATE
        SET creation_time = excluded.creation_time,
            curr_version = excluded.curr_version,
            min_compatible_version = excluded.min_compatible_version;

INSERT INTO schema_update_history
(version_partition, "year", "month", update_time, description, manifest_md5, new_version, old_version)
VALUES(0, date_part('year', now()), date_part('month', now()), now(), 'schema update for cluster_membership, executions and history_node tables', '', '1.5', '1.0');