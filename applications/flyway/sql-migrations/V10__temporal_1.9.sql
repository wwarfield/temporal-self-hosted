
/* Generated Migration:
 * Admin Tools Version: 1.24.2-tctl-1.18.1-cli-1.0.0
 * Temporal Migration Version: 1.9
 * Date: 2024-08-23 17:08:11.465799
 */


SET search_path TO temporal_default;

CREATE TABLE history_immediate_tasks(
  shard_id INTEGER NOT NULL,
  category_id INTEGER NOT NULL,
  task_id BIGINT NOT NULL,
  --
  data BYTEA NOT NULL,
  data_encoding VARCHAR(16) NOT NULL,
  PRIMARY KEY (shard_id, category_id, task_id)
);

CREATE TABLE history_scheduled_tasks (
  shard_id INTEGER NOT NULL,
  category_id INTEGER NOT NULL,
  visibility_timestamp TIMESTAMP NOT NULL,
  task_id BIGINT NOT NULL,
  --
  data BYTEA NOT NULL,
  data_encoding VARCHAR(16) NOT NULL,
  PRIMARY KEY (shard_id, category_id, visibility_timestamp, task_id)
);



INSERT into schema_version(version_partition, db_name, creation_time, curr_version, min_compatible_version)
VALUES (0,'temporal',now(),'1.9','1.0')
    ON CONFLICT (version_partition, db_name) DO UPDATE
        SET creation_time = excluded.creation_time,
            curr_version = excluded.curr_version,
            min_compatible_version = excluded.min_compatible_version;

INSERT INTO schema_update_history
(version_partition, "year", "month", update_time, description, manifest_md5, new_version, old_version)
VALUES(0, date_part('year', now()), date_part('month', now()), now(), 'add history tasks table', '', '1.9', '1.0');