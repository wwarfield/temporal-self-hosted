
/* Generated Migration:
 * Admin Tools Version: 1.24.2-tctl-1.18.1-cli-1.0.0
 * Temporal Migration Version: 1.0
 * Date: 2024-08-23 17:08:11.451785
 */


CREATE SCHEMA temporal_default;
SET search_path TO temporal_default;

CREATE TABLE namespaces(
  partition_id INTEGER NOT NULL,
  id BYTEA NOT NULL,
  name VARCHAR(255) UNIQUE NOT NULL,
  notification_version BIGINT NOT NULL,
  --
  data BYTEA NOT NULL,
  data_encoding VARCHAR(16) NOT NULL,
  is_global BOOLEAN NOT NULL,
  PRIMARY KEY(partition_id, id)
);

CREATE TABLE namespace_metadata (
  partition_id INTEGER NOT NULL,
  notification_version BIGINT NOT NULL,
  PRIMARY KEY(partition_id)
);

INSERT INTO namespace_metadata (partition_id, notification_version) VALUES (54321, 1);

CREATE TABLE shards (
  shard_id INTEGER NOT NULL,
  --
  range_id BIGINT NOT NULL,
  data BYTEA NOT NULL,
  data_encoding VARCHAR(16) NOT NULL,
  PRIMARY KEY (shard_id)
);

CREATE TABLE transfer_tasks(
  shard_id INTEGER NOT NULL,
  task_id BIGINT NOT NULL,
  --
  data BYTEA NOT NULL,
  data_encoding VARCHAR(16) NOT NULL,
  PRIMARY KEY (shard_id, task_id)
);

CREATE TABLE executions(
  shard_id INTEGER NOT NULL,
  namespace_id BYTEA NOT NULL,
  workflow_id VARCHAR(255) NOT NULL,
  run_id BYTEA NOT NULL,
  --
  next_event_id BIGINT NOT NULL,
  last_write_version BIGINT NOT NULL,
  data BYTEA NOT NULL,
  data_encoding VARCHAR(16) NOT NULL,
  state BYTEA NOT NULL,
  state_encoding VARCHAR(16) NOT NULL,
  PRIMARY KEY (shard_id, namespace_id, workflow_id, run_id)
);

CREATE TABLE current_executions(
  shard_id INTEGER NOT NULL,
  namespace_id BYTEA NOT NULL,
  workflow_id VARCHAR(255) NOT NULL,
  --
  run_id BYTEA NOT NULL,
  create_request_id VARCHAR(64) NOT NULL,
  state INTEGER NOT NULL,
  status INTEGER NOT NULL,
  start_version BIGINT NOT NULL,
  last_write_version BIGINT NOT NULL,
  PRIMARY KEY (shard_id, namespace_id, workflow_id)
);

CREATE TABLE buffered_events (
  shard_id INTEGER NOT NULL,
  namespace_id BYTEA NOT NULL,
  workflow_id VARCHAR(255) NOT NULL,
  run_id BYTEA NOT NULL,
  id BIGSERIAL NOT NULL UNIQUE,
  --
  data BYTEA NOT NULL,
  data_encoding VARCHAR(16) NOT NULL,
  PRIMARY KEY (shard_id, namespace_id, workflow_id, run_id, id)
);

CREATE TABLE tasks (
  range_hash BIGINT NOT NULL,
  task_queue_id BYTEA NOT NULL,
  task_id BIGINT NOT NULL,
  --
  data BYTEA NOT NULL,
  data_encoding VARCHAR(16) NOT NULL,
  PRIMARY KEY (range_hash, task_queue_id, task_id)
);

CREATE TABLE task_queues (
  range_hash BIGINT NOT NULL,
  task_queue_id BYTEA NOT NULL,
  --
  range_id BIGINT NOT NULL,
  data BYTEA NOT NULL,
  data_encoding VARCHAR(16) NOT NULL,
  PRIMARY KEY (range_hash, task_queue_id)
);

CREATE TABLE replication_tasks (
  shard_id INTEGER NOT NULL,
  task_id BIGINT NOT NULL,
  --
  data BYTEA NOT NULL,
  data_encoding VARCHAR(16) NOT NULL,
  PRIMARY KEY (shard_id, task_id)
);

CREATE TABLE replication_tasks_dlq (
  source_cluster_name VARCHAR(255) NOT NULL,
  shard_id INTEGER NOT NULL,
  task_id BIGINT NOT NULL,
  --
  data BYTEA NOT NULL,
  data_encoding VARCHAR(16) NOT NULL,
  PRIMARY KEY (source_cluster_name, shard_id, task_id)
);

CREATE TABLE timer_tasks (
  shard_id INTEGER NOT NULL,
  visibility_timestamp TIMESTAMP NOT NULL,
  task_id BIGINT NOT NULL,
  --
  data BYTEA NOT NULL,
  data_encoding VARCHAR(16) NOT NULL,
  PRIMARY KEY (shard_id, visibility_timestamp, task_id)
);

CREATE TABLE activity_info_maps (
-- each row corresponds to one key of one map<string, ActivityInfo>
  shard_id INTEGER NOT NULL,
  namespace_id BYTEA NOT NULL,
  workflow_id VARCHAR(255) NOT NULL,
  run_id BYTEA NOT NULL,
  schedule_id BIGINT NOT NULL,
--
  data BYTEA NOT NULL,
  data_encoding VARCHAR(16),
  PRIMARY KEY (shard_id, namespace_id, workflow_id, run_id, schedule_id)
);

CREATE TABLE timer_info_maps (
  shard_id INTEGER NOT NULL,
  namespace_id BYTEA NOT NULL,
  workflow_id VARCHAR(255) NOT NULL,
  run_id BYTEA NOT NULL,
  timer_id VARCHAR(255) NOT NULL,
--
  data BYTEA NOT NULL,
  data_encoding VARCHAR(16),
  PRIMARY KEY (shard_id, namespace_id, workflow_id, run_id, timer_id)
);

CREATE TABLE child_execution_info_maps (
  shard_id INTEGER NOT NULL,
  namespace_id BYTEA NOT NULL,
  workflow_id VARCHAR(255) NOT NULL,
  run_id BYTEA NOT NULL,
  initiated_id BIGINT NOT NULL,
--
  data BYTEA NOT NULL,
  data_encoding VARCHAR(16),
  PRIMARY KEY (shard_id, namespace_id, workflow_id, run_id, initiated_id)
);

CREATE TABLE request_cancel_info_maps (
  shard_id INTEGER NOT NULL,
  namespace_id BYTEA NOT NULL,
  workflow_id VARCHAR(255) NOT NULL,
  run_id BYTEA NOT NULL,
  initiated_id BIGINT NOT NULL,
--
  data BYTEA NOT NULL,
  data_encoding VARCHAR(16),
  PRIMARY KEY (shard_id, namespace_id, workflow_id, run_id, initiated_id)
);

CREATE TABLE signal_info_maps (
  shard_id INTEGER NOT NULL,
  namespace_id BYTEA NOT NULL,
  workflow_id VARCHAR(255) NOT NULL,
  run_id BYTEA NOT NULL,
  initiated_id BIGINT NOT NULL,
--
  data BYTEA NOT NULL,
  data_encoding VARCHAR(16),
  PRIMARY KEY (shard_id, namespace_id, workflow_id, run_id, initiated_id)
);

CREATE TABLE signals_requested_sets (
  shard_id INTEGER NOT NULL,
  namespace_id BYTEA NOT NULL,
  workflow_id VARCHAR(255) NOT NULL,
  run_id BYTEA NOT NULL,
  signal_id VARCHAR(64) NOT NULL,
  --
  PRIMARY KEY (shard_id, namespace_id, workflow_id, run_id, signal_id)
);

-- history eventsV2: history_node stores history event data
CREATE TABLE history_node (
  shard_id       INTEGER NOT NULL,
  tree_id        BYTEA NOT NULL,
  branch_id      BYTEA NOT NULL,
  node_id        BIGINT NOT NULL,
  txn_id         BIGINT NOT NULL,
  --
  data           BYTEA NOT NULL,
  data_encoding  VARCHAR(16) NOT NULL,
  PRIMARY KEY (shard_id, tree_id, branch_id, node_id, txn_id)
);

-- history eventsV2: history_tree stores branch metadata
CREATE TABLE history_tree (
  shard_id       INTEGER NOT NULL,
  tree_id        BYTEA NOT NULL,
  branch_id      BYTEA NOT NULL,
  --
  data           BYTEA NOT NULL,
  data_encoding  VARCHAR(16) NOT NULL,
  PRIMARY KEY (shard_id, tree_id, branch_id)
);

CREATE TABLE queue (
  queue_type INTEGER NOT NULL,
  message_id BIGINT NOT NULL,
  message_payload BYTEA NOT NULL,
  PRIMARY KEY(queue_type, message_id)
);

CREATE TABLE queue_metadata (
  queue_type INTEGER NOT NULL,
  data BYTEA NOT NULL,
  PRIMARY KEY(queue_type)
);

CREATE TABLE cluster_metadata (
  metadata_partition        INTEGER NOT NULL,
  immutable_data            BYTEA NOT NULL,
  immutable_data_encoding   VARCHAR(16) NOT NULL,
  PRIMARY KEY(metadata_partition)
);

CREATE TABLE cluster_membership
(
    membership_partition INTEGER NOT NULL,
    host_id              BYTEA NOT NULL,
    rpc_address          VARCHAR(15) NOT NULL,
    rpc_port             SMALLINT NOT NULL,
    role                 SMALLINT NOT NULL,
    session_start        TIMESTAMP DEFAULT '1970-01-01 00:00:01+00:00',
    last_heartbeat       TIMESTAMP DEFAULT '1970-01-01 00:00:01+00:00',
    record_expiry        TIMESTAMP DEFAULT '1970-01-01 00:00:01+00:00',
    PRIMARY KEY (membership_partition, host_id)
);

CREATE UNIQUE INDEX cm_idx_rolehost ON cluster_membership (role, host_id);
CREATE INDEX cm_idx_rolelasthb ON cluster_membership (role, last_heartbeat);
CREATE INDEX cm_idx_rpchost ON cluster_membership (rpc_address, role);
CREATE INDEX cm_idx_lasthb ON cluster_membership (last_heartbeat);
CREATE INDEX cm_idx_recordexpiry ON cluster_membership (record_expiry);



CREATE TABLE schema_update_history(
    version_partition INT not null,
    year int not null,
    month int not null,
    update_time timestamp not null,
    description VARCHAR(255),
    manifest_md5 VARCHAR(64),
    new_version VARCHAR(64),
    old_version VARCHAR(64),
    PRIMARY KEY (version_partition, year, month, update_time)
);

CREATE TABLE schema_version(version_partition INT not null,
    db_name VARCHAR(255) not null,
    creation_time timestamp,
    curr_version VARCHAR(64),
    min_compatible_version VARCHAR(64),
    PRIMARY KEY (version_partition, db_name)
);


INSERT into schema_version(version_partition, db_name, creation_time, curr_version, min_compatible_version)
VALUES (0,'temporal',now(),'1.0','0.1')
    ON CONFLICT (version_partition, db_name) DO UPDATE
        SET creation_time = excluded.creation_time,
            curr_version = excluded.curr_version,
            min_compatible_version = excluded.min_compatible_version;

INSERT INTO schema_update_history
(version_partition, "year", "month", update_time, description, manifest_md5, new_version, old_version)
VALUES(0, date_part('year', now()), date_part('month', now()), now(), 'base version of schema', '', '1.0', '0.1');