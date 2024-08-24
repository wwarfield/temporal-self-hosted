from dataclasses import dataclass
import datetime
import json
from strenum import StrEnum
import subprocess
import os

from psycopg2 import connect
from packaging.version import Version
from textwrap import dedent


SCRATCH_DIR = "./tools/migrations/scratch-schema"
FLYWAY_MIGRATION_DIR = "./applications/flyway/sql-migrations"
ADMIN_TOOLS_VERSION = "1.24.2-tctl-1.18.1-cli-1.0.0"
version_directory = f"{SCRATCH_DIR}/{ADMIN_TOOLS_VERSION}"

DEFAULT_SCHEMA_NAME = "temporal_default"
VISIBILITY_SCHEMA_NAME = "temporal_visibility"

DB_NAME = "temporal"
DB_USER = "temporal"
DB_PASSWORD = "temporal"
DB_HOST = "localhost"
DB_PORT = 5432


def main():
    print('Download Schema Files from Admin Tools')
    DockerRunner.download_schemas(version_directory)

    print('Check Current Schema Versions')
    default_schema_version = get_current_version(
        DEFAULT_SCHEMA_NAME, DB_NAME, DB_USER, DB_PASSWORD, DB_HOST, DB_PORT
    )
    visibility_schema_version = get_current_version(
        VISIBILITY_SCHEMA_NAME, DB_NAME, DB_USER, DB_PASSWORD, DB_HOST, DB_PORT
    )
    print(f'Default Version: {default_schema_version.last_applied_version}')
    print(f'Visibility Version: {visibility_schema_version.last_applied_version}')

    extractor = PSQLMigrationExtractor(
        "temporal",
        version_directory,
        default_schema_version,
        visibility_schema_version
    )
    migration_writer = FlywayMigrationWriter(FLYWAY_MIGRATION_DIR)

    for schema_type in SchemaType:
        available_versions = extractor.get_available_versions(schema_type)
        unapplied_versions = extractor.get_unapplied_versions(schema_type, available_versions)

        if len(unapplied_versions) == 0:
            print(f'{schema_type} is up to date')

        for unapplied_version in unapplied_versions:
            migration = extractor.get_migration(schema_type, unapplied_version)
            print(f'Generating Migration {schema_type}:{migration.schema_version} -> {migration.description}')

            migration_writer.write_migration(
                message=f"{schema_type}_{str(unapplied_version)}",
                migration=migration.migration
            )


class SchemaType(StrEnum):
    # Each Schema Type that temporal utilizes
    # the string mapping also aligns with the directory names that temporal
    # stores the respective schema files
    DEFAULT = 'temporal'
    VISIBILITY = 'visibility'


@dataclass
class VersionedSchema:
    name: str
    last_applied_version: Version


@dataclass
class VersionedMigration:
    migration: str
    schema_version: Version

    min_compatible_version: str
    description: str


class DockerRunner:

    CONTAINER_NAME = "temporal-admin-tool-scratch"
    IMAGE_NAME = "temporalio/admin-tools"

    @staticmethod
    def run_command(command_args: list[str]) -> str:
        print(f'Run Command: {" ".join(command_args)}')
        result = subprocess.run(
            command_args,
            stdout=subprocess.PIPE,
            check=True
        )
        print(f'Command output: {result.stdout}')
        return result.stdout

    @staticmethod
    def start_admin_tools(admin_tools_version):
        args = [
            "docker", "run",
            "-d",  # Run container in detached mode
            "--rm",  # Remove existing container if it exists
            "--name", DockerRunner.CONTAINER_NAME,
            f"{DockerRunner.IMAGE_NAME}:{admin_tools_version}"
        ]
        DockerRunner.run_command(args)

    @staticmethod
    def stop_admin_tools():
        args = [
            "docker", "container",
            "stop", DockerRunner.CONTAINER_NAME
        ]
        DockerRunner.run_command(args)

    def copy_schema_directory_to_host(destination: str):
        args = [
            "docker", "cp",
            f"{DockerRunner.CONTAINER_NAME}:/etc/temporal/schema",
            destination
        ]
        DockerRunner.run_command(args)

    @staticmethod
    def download_schemas(version_directory):
        if not os.path.exists(SCRATCH_DIR):
            os.makedirs(SCRATCH_DIR)

        DockerRunner.start_admin_tools(ADMIN_TOOLS_VERSION)

        if not os.path.exists(version_directory):
            os.makedirs(version_directory)

        DockerRunner.copy_schema_directory_to_host(version_directory)
        DockerRunner.stop_admin_tools()


class PSQLMigrationExtractor:

    PERSISTENCE_STORE = "postgresql/v12/"

    def __init__(
        self,
        db_name: str,
        version_directory: str,
        default_schema: VersionedSchema,
        visibility_schema: VersionedSchema
    ):
        self.db_name = db_name
        self.directory = f"{version_directory}/schema/{PSQLMigrationExtractor.PERSISTENCE_STORE}"
        self.default_schema = default_schema
        self.visibility_schema = visibility_schema

    def get_available_versions(self, schema_type: SchemaType) -> list[Version]:
        version_strs = os.listdir(f"{self.directory}{schema_type}/versioned/")
        versions = [Version(version_str) for version_str in version_strs]
        versions.sort()
        return versions

    def get_unapplied_versions(self, schema_type: SchemaType, available_versions: list[Version]) -> list[Version]:

        if schema_type == SchemaType.DEFAULT:
            last_applied_version = self.default_schema.last_applied_version
        elif schema_type == SchemaType.VISIBILITY:
            last_applied_version = self.visibility_schema.last_applied_version

        unapplied = []
        for version in available_versions:
            if version > last_applied_version:
                unapplied.append(version)

        return unapplied

    def _get_raw_migration(self, schema_type: SchemaType, version: Version) -> str:
        all_files = os.listdir(f"{self.directory}{schema_type}/versioned/v{version}/")
        sql_files = list(filter(lambda name: name.endswith('.sql'), all_files))

        concatentated_sql = ''
        for filename in sql_files:
            with open(f"{self.directory}{schema_type}/versioned/v{version}/{filename}", "r") as file:
                concatentated_sql += str(file.read()) + '\n'

        return concatentated_sql

    def _get_manifest_dict(self, schema_type: SchemaType, version: Version):
        with open(f"{self.directory}{schema_type}/versioned/v{version}/manifest.json", "r") as file:
            return json.loads(file.read())

    def _get_history_table_schema(self) -> str:
        # https://github.com/temporalio/temporal/blob/13d6cd8cf7a4ba0c4660cf98f672bbd645dca3e7/common/persistence/sql/sqlplugin/postgresql/admin.go#L33
        return dedent("""
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
        );\n\n""")

    def _get_history_insert_statements(self, version: Version, manifest_dict) -> str:
        # https://github.com/temporalio/temporal/blob/13d6cd8cf7a4ba0c4660cf98f672bbd645dca3e7/common/persistence/sql/sqlplugin/postgresql/admin.go#L33
        min_compatible_version = manifest_dict['MinCompatibleVersion']
        description = manifest_dict['Description']
        return dedent(f"""
        INSERT into schema_version(version_partition, db_name, creation_time, curr_version, min_compatible_version)
        VALUES (0,'{self.db_name}',now(),'{str(version)}','{min_compatible_version}')
            ON CONFLICT (version_partition, db_name) DO UPDATE
                SET creation_time = excluded.creation_time,
                    curr_version = excluded.curr_version,
                    min_compatible_version = excluded.min_compatible_version;

        INSERT INTO schema_update_history
        (version_partition, "year", "month", update_time, description, manifest_md5, new_version, old_version)
        VALUES(0, date_part('year', now()), date_part('month', now()), now(), '{description}', '', '{str(version)}', '{min_compatible_version}');""")

    def get_migration(self, schema_type: SchemaType, version: Version) -> VersionedMigration:
        migration = dedent(f"""
        /* Generated Migration:
         * Admin Tools Version: {ADMIN_TOOLS_VERSION}
         * Temporal Migration Version: {version}
         * Date: {datetime.datetime.now()}
         */\n\n
        """)
        if schema_type == SchemaType.DEFAULT:
            schema_name = self.default_schema.name
        else:
            schema_name = self.visibility_schema.name

        if version == Version("1.0"):
            migration += f"CREATE SCHEMA {schema_name};\n"

        migration += f"SET search_path TO {schema_name};\n\n"
        migration += self._get_raw_migration(schema_type, version) + "\n\n"

        if version == Version("1.0"):
            migration += self._get_history_table_schema()

        manifest_dict = self._get_manifest_dict(schema_type, version)

        migration += self._get_history_insert_statements(version, manifest_dict)

        return VersionedMigration(
            migration,
            version,
            manifest_dict['MinCompatibleVersion'],
            manifest_dict['Description']
        )


class FlywayMigrationWriter:

    def __init__(self, directory: str):
        self.directory = directory
        pass

    def _get_current_versions(self) -> list[Version]:
        files = os.listdir(f"{self.directory}")
        versions = [Version(filename.split("_")[0]) for filename in files]
        versions.sort()
        return versions

    def _get_next_version(self) -> Version:
        versions = self._get_current_versions()
        if len(versions) == 0:
            return Version("1")
        else:
            last_version = versions[-1].major
            return Version(str(last_version + 1))

    def _get_filename(self, message: str) -> str:
        next_version = self._get_next_version()
        return f"V{next_version.major}__{message}.sql"

    def write_migration(self, message: str, migration: str):
        with open(f"{self.directory}/{self._get_filename(message)}", "w") as file:
            file.write(migration)


def get_current_version(
    schema_name: str,
    db_name: str,
    db_user: str,
    db_password: str,
    db_host: str,
    db_port: int
) -> VersionedSchema:
    connection = connect(
        database=db_name,
        user=db_user, password=db_password, host=db_host, port=db_port)

    cursor = connection.cursor()

    schema_query = f"""
    SELECT
        schema_name
    FROM information_schema.schemata
    WHERE schema_name = '{schema_name}';
    """
    cursor.execute(schema_query)
    schema_record = cursor.fetchall()

    if len(schema_record) == 0:
        # If the schema does not exist then we should assume that
        # none of the migrations have run yet & the current version is 0
        return VersionedSchema(schema_name, Version("0"))

    version_query = f"""
    SELECT
        curr_version
    from {schema_name}.schema_version
    where version_partition=0 and db_name='{db_name}';
    """
    cursor.execute(version_query)

    version_record = cursor.fetchall()
    version = Version(version_record[0][0])
    return VersionedSchema(schema_name, version)


if __name__ == "__main__":
    main()
