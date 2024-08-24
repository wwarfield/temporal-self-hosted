
/* Generated Migration:
 * Admin Tools Version: 1.24.2-tctl-1.18.1-cli-1.0.0
 * Temporal Migration Version: 1.0
 * Date: 2024-08-23 17:08:11.471342
 */


CREATE SCHEMA temporal_visibility;
SET search_path TO temporal_visibility;

CREATE TABLE executions_visibility (
  namespace_id         CHAR(64) NOT NULL,
  run_id               CHAR(64) NOT NULL,
  start_time           TIMESTAMP NOT NULL,
  execution_time       TIMESTAMP NOT NULL,
  workflow_id          VARCHAR(255) NOT NULL,
  workflow_type_name   VARCHAR(255) NOT NULL,
  status               INTEGER NOT NULL,  -- enum WorkflowExecutionStatus {RUNNING, COMPLETED, FAILED, CANCELED, TERMINATED, CONTINUED_AS_NEW, TIMED_OUT}
  close_time           TIMESTAMP NULL,
  history_length       BIGINT,
  memo                 BYTEA,
  encoding             VARCHAR(64) NOT NULL,
  task_queue           VARCHAR(255) DEFAULT '' NOT NULL,

  PRIMARY KEY  (namespace_id, run_id)
);

CREATE INDEX by_type_start_time ON executions_visibility (namespace_id, workflow_type_name, status, start_time DESC, run_id);
CREATE INDEX by_workflow_id_start_time ON executions_visibility (namespace_id, workflow_id, status, start_time DESC, run_id);
CREATE INDEX by_status_by_start_time ON executions_visibility (namespace_id, status, start_time DESC, run_id);
CREATE INDEX by_type_close_time ON executions_visibility (namespace_id, workflow_type_name, status, close_time DESC, run_id);
CREATE INDEX by_workflow_id_close_time ON executions_visibility (namespace_id, workflow_id, status, close_time DESC, run_id);
CREATE INDEX by_status_by_close_time ON executions_visibility (namespace_id, status, close_time DESC, run_id);






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
VALUES(0, date_part('year', now()), date_part('month', now()), now(), 'base version of visibility schema', '', '1.0', '0.1');