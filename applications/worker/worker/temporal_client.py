from temporalio.client import Client
from worker.config.config import TemporalConfig
from temporalio.runtime import Runtime, TelemetryConfig, PrometheusConfig


async def get_temporal_client():
    temporal_config = TemporalConfig()

    if temporal_config.is_metrics_enabled():
        address = temporal_config.get_metrics_bind_address()
        print(f'Metrics Enabled on {address}')
        runtime = Runtime(
            telemetry=TelemetryConfig(
                metrics=PrometheusConfig(
                    bind_address=address
                )
            )
        )
    else:
        runtime = None

    temporal_url = f"{temporal_config.get_server_host()}:{temporal_config.get_server_port()}"
    print(f"Connecting to {temporal_url} ...")
    client = await Client.connect(temporal_url, runtime=runtime)
    print('connected')
    return client
