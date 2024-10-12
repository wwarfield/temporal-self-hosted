
/* Generated Migration:
 * Admin Tools Version: 1.25.1-tctl-1.18.1-cli-1.1.0
 * Temporal Migration Version: 1.13
 * Date: 2024-10-12 16:08:21.524425
 */


SET search_path TO temporal_default;

DROP TABLE nexus_incoming_services;
DROP TABLE nexus_incoming_services_partition_status;

-- Stores information about Nexus endpoints
CREATE TABLE nexus_endpoints (
    id            BYTEA NOT NULL,
    data          BYTEA NOT NULL,  -- temporal.server.api.persistence.v1.NexusEndpoint
    data_encoding VARCHAR(16) NOT NULL, -- Encoding type used for serialization, in practice this should always be proto3
    version       BIGINT NOT NULL,      -- Version of this row, used for optimistic concurrency
    PRIMARY KEY (id)
);

-- Stores the version of Nexus endpoints table as a whole
CREATE TABLE nexus_endpoints_partition_status (
    id      INT NOT NULL PRIMARY KEY DEFAULT 0,
    version BIGINT NOT NULL,                -- Version of the nexus_endpoints table
    CONSTRAINT only_one_row CHECK (id = 0)  -- Restrict the table to a single row since it will only be used for endpoints
);




INSERT into schema_version(version_partition, db_name, creation_time, curr_version, min_compatible_version)
VALUES (0,'temporal',now(),'1.13','1.0')
    ON CONFLICT (version_partition, db_name) DO UPDATE
        SET creation_time = excluded.creation_time,
            curr_version = excluded.curr_version,
            min_compatible_version = excluded.min_compatible_version;

INSERT INTO schema_update_history
(version_partition, "year", "month", update_time, description, manifest_md5, new_version, old_version)
VALUES(0, date_part('year', now()), date_part('month', now()), now(), 'Replace nexus_incoming_services and nexus_incoming_services_partition_status tables with nexus_endpoints and nexus_endpoints_partition_status tables', '', '1.13', '1.0');