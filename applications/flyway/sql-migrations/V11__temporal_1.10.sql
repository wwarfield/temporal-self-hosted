
/* Generated Migration:
 * Admin Tools Version: 1.24.2-tctl-1.18.1-cli-1.0.0
 * Temporal Migration Version: 1.10
 * Date: 2024-08-23 17:08:11.467018
 */


SET search_path TO temporal_default;

-- Stores task queue information such as user provided versioning data
CREATE TABLE task_queue_user_data (
  namespace_id    BYTEA NOT NULL,
  task_queue_name VARCHAR(255) NOT NULL,
  data            BYTEA NOT NULL,       -- temporal.server.api.persistence.v1.TaskQueueUserData
  data_encoding   VARCHAR(16) NOT NULL, -- Encoding type used for serialization, in practice this should always be proto3
  version         BIGINT NOT NULL,      -- Version of this row, used for optimistic concurrency
  PRIMARY KEY (namespace_id, task_queue_name)
);

-- Stores a mapping between build ids and task queues
CREATE TABLE build_id_to_task_queue (
  namespace_id    BYTEA NOT NULL,
  build_id        VARCHAR(255) NOT NULL,
  task_queue_name VARCHAR(255) NOT NULL,
  PRIMARY KEY (namespace_id, build_id, task_queue_name)
);




INSERT into schema_version(version_partition, db_name, creation_time, curr_version, min_compatible_version)
VALUES (0,'temporal',now(),'1.10','1.0')
    ON CONFLICT (version_partition, db_name) DO UPDATE
        SET creation_time = excluded.creation_time,
            curr_version = excluded.curr_version,
            min_compatible_version = excluded.min_compatible_version;

INSERT INTO schema_update_history
(version_partition, "year", "month", update_time, description, manifest_md5, new_version, old_version)
VALUES(0, date_part('year', now()), date_part('month', now()), now(), 'add storage for update records and create task_queue_user_data table', '', '1.10', '1.0');