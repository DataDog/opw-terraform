# Unless explicitly stated otherwise all files in this repository are licensed under the Apache 2 License.
#
# This product includes software developed at Datadog (https://www.datadoghq.com/). Copyright 2023 Datadog, Inc.
terraform {
  required_version = ">= 1.4.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      vendor     = "datadog"
      managed_by = "terraform"
      product    = "observability-pipelines"
    }
  }
}
