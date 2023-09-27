# Observability Pipelines
This module will create a production-ready Observability Pipelines (OP) cluster in your cloud environment, to facilitate a quick start for dev/production deploys. At the time of writing, we only support AWS.

## Usage
To use this module, include it in your Terraform manifests like so:

```
module "opw" {
    source     = "git::https://github.com/DataDog/opw-terraform//aws"
    vpc-id     = "{VPC ID}"
    subnet-ids = ["{SUBNET ID 1}", "{SUBNET ID 2}"]
    region     = "{REGION}"

    datadog-api-key = "{DATADOG API KEY}"
    pipeline-id = "{OP PIPELINE ID}"
    pipeline-config = <<EOT
# Substitute your configuration here, if you have one, or use this
# as a starting point.
sources:
    dd:
        type: datadog_agent
        address: 0.0.0.0:8282
        multiple_outputs: true
sinks:
    dd_metrics:
        type: datadog_metrics
        inputs:
        - dd.metrics
        # The double-$ there is intentional- Terraform requires that these be
        # escaped so that DD_API_KEY isn't interpolated by its template
        # language.
        default_api_key: $${DD_API_KEY}
EOT
}
```