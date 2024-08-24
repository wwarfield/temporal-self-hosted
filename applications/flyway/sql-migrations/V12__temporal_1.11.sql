
/* Generated Migration:
 * Admin Tools Version: 1.24.2-tctl-1.18.1-cli-1.0.0
 * Temporal Migration Version: 1.11
 * Date: 2024-08-23 17:08:11.468201
 */


SET search_path TO temporal_default;

CREATE TABLE queues (
    queue_type INT NOT NULL,
    queue_name VARCHAR(255) NOT NULL,
    metadata_payload BYTEA NOT NULL,
    metadata_encoding VARCHAR(16) NOT NULL,
    PRIMARY KEY (queue_type, queue_name)
);

CREATE TABLE queue_messages (
    queue_type INT NOT NULL,
    queue_name VARCHAR(255) NOT NULL,
    queue_partition BIGINT NOT NULL,
    message_id BIGINT NOT NULL,
    message_payload BYTEA NOT NULL,
    message_encoding VARCHAR(16) NOT NULL,
    PRIMARY KEY (
        queue_type,
        queue_name,
        queue_partition,
        message_id
    )
);



INSERT into schema_version(version_partition, db_name, creation_time, curr_version, min_compatible_version)
VALUES (0,'temporal',now(),'1.11','1.0')
    ON CONFLICT (version_partition, db_name) DO UPDATE
        SET creation_time = excluded.creation_time,
            curr_version = excluded.curr_version,
            min_compatible_version = excluded.min_compatible_version;

INSERT INTO schema_update_history
(version_partition, "year", "month", update_time, description, manifest_md5, new_version, old_version)
VALUES(0, date_part('year', now()), date_part('month', now()), now(), 'add queues and queue_messages tables', '', '1.11', '1.0');