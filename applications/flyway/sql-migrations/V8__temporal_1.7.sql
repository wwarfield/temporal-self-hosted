
/* Generated Migration:
 * Admin Tools Version: 1.24.2-tctl-1.18.1-cli-1.0.0
 * Temporal Migration Version: 1.7
 * Date: 2024-08-23 17:08:11.462647
 */


SET search_path TO temporal_default;

CREATE TABLE cluster_metadata_info (
  metadata_partition        INTEGER NOT NULL,
  cluster_name              VARCHAR(255) NOT NULL,
  data                      BYTEA NOT NULL,
  data_encoding             VARCHAR(16) NOT NULL,
  version                   BIGINT NOT NULL,
  PRIMARY KEY(metadata_partition, cluster_name)
);
ALTER TABLE current_executions ALTER COLUMN start_version SET DEFAULT 0;
CREATE TABLE tiered_storage_tasks(
  shard_id INTEGER NOT NULL,
  task_id BIGINT NOT NULL,
  --
  data BYTEA NOT NULL,
  data_encoding VARCHAR(16) NOT NULL,
  PRIMARY KEY (shard_id, task_id)
);



INSERT into schema_version(version_partition, db_name, creation_time, curr_version, min_compatible_version)
VALUES (0,'temporal',now(),'1.7','1.0')
    ON CONFLICT (version_partition, db_name) DO UPDATE
        SET creation_time = excluded.creation_time,
            curr_version = excluded.curr_version,
            min_compatible_version = excluded.min_compatible_version;

INSERT INTO schema_update_history
(version_partition, "year", "month", update_time, description, manifest_md5, new_version, old_version)
VALUES(0, date_part('year', now()), date_part('month', now()), now(), 'create cluster metadata info table to store cluster information and executions to store tiered storage queue', '', '1.7', '1.0');