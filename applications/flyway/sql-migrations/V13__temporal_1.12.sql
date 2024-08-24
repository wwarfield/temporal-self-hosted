
/* Generated Migration:
 * Admin Tools Version: 1.24.2-tctl-1.18.1-cli-1.0.0
 * Temporal Migration Version: 1.12
 * Date: 2024-08-23 17:08:11.469451
 */


SET search_path TO temporal_default;

-- Stores information about Nexus incoming services
CREATE TABLE nexus_incoming_services (
    service_id      BYTEA NOT NULL,
    data            BYTEA NOT NULL,  -- temporal.server.api.persistence.v1.NexusIncomingService
    data_encoding   VARCHAR(16) NOT NULL, -- Encoding type used for serialization, in practice this should always be proto3
    version         BIGINT NOT NULL,      -- Version of this row, used for optimistic concurrency
    PRIMARY KEY (service_id)
);

-- Stores the version of Nexus incoming services table as a whole
CREATE TABLE nexus_incoming_services_partition_status (
    id      INT NOT NULL PRIMARY KEY DEFAULT 0,
    version BIGINT NOT NULL,                -- Version of the nexus_incoming_services table
    CONSTRAINT only_one_row CHECK (id = 0)  -- Restrict the table to a single row since it will only be used for incoming services
);



INSERT into schema_version(version_partition, db_name, creation_time, curr_version, min_compatible_version)
VALUES (0,'temporal',now(),'1.12','1.0')
    ON CONFLICT (version_partition, db_name) DO UPDATE
        SET creation_time = excluded.creation_time,
            curr_version = excluded.curr_version,
            min_compatible_version = excluded.min_compatible_version;

INSERT INTO schema_update_history
(version_partition, "year", "month", update_time, description, manifest_md5, new_version, old_version)
VALUES(0, date_part('year', now()), date_part('month', now()), now(), 'add storage for Nexus incoming service records and create nexus_incoming_services and nexus_incoming_services_partition_status tables', '', '1.12', '1.0');