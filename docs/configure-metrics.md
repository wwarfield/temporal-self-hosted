# Metrics, Traces, & Logging
When self hosting temporal there are multiple sets of metrics, traces, and logging
available for you to configure and improve the observability of your stack.
Each one is critical to effectively monitoring and scaling a self hosted instance of
temporal so it's beneficial to set these up early.

This Guide will highlight those pieces of configuration and provide an example
of that configuration you can reference and adapt into your stack.

## Metrics

The [Temporal Cluster](https://docs.temporal.io/references/cluster-metrics) has over 25 metrics that it can ship via Opentelemtry to
observability platform of your choosing. These metrics are split into categories:

 - Common
 - Matching Service
 - History Service
 - Persistence
 - Schedule

### Pre-requistes
For the sake of this repo & Guide we will configure an otel-collector to collect metrics
and write them to Grafana Cloud. Grafana Cloud is free and makes it easy to start to see
these metrics in action. To do this you will need:

- Create a [Free Grafana Cloud Account](https://grafana.com/)
- Follow [OpenTelemetry Protocol (OTLP)](https://grafana.com/docs/grafana-cloud/send-data/otlp/send-data-otlp/) Guide to get Cloud credentials

Once you have Grafana Credentials you should add them to your .envrc
```bash
export OTEL_EXPORTER_OTLP_ENDPOINT=<Grafana Endpoint>
export OTEL_GRAFANA_INSTANCE_ID="<INSERT instance ID>"
export OTEL_GRAFANA_API_TOKEN="<INSERT Grafana API Token>"
export OTEL_EXPORTER_OTLP_HEADERS="<INSERT OLTP header>
```
---
**NOTE**

If you do not see the same screenshots as the guide above shows. It most likely means you are on the wrong configuration page in Grafana Cloud.

---

### Temporal Server (Already Configured)
To start shipping metrics from the Temporal Server you can configure a prometheus endpoint
to serve opentelemtry metrics. This can be done in the metrics stanza of the temporal config
file.

```yaml
metrics:
    prometheus:
        framework: 'opentelemetry'
        listenAddress: '0.0.0.0:4333'
```

This exposes an endpoint from the temporal server on port 4333 with the url prefix /metrics
that will serve all the metrics from the server. It's also expected that in the OTEL collector you configure a job to scrape the metrics regularly and ship them.

### Workers

## Traces
## Logging