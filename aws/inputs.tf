# Unless explicitly stated otherwise all files in this repository are licensed under the Apache 2 License.
#
# This product includes software developed at Datadog (https://www.datadoghq.com/). Copyright 2023 Datadog, Inc.
variable "datadog-api-key" {
  type        = string
  description = "API key to use for connecting to Datadog."
  sensitive   = true
}

variable "datadog-site" {
  type        = string
  description = "Datadog site to use. Defaults to US1, which suffices for most customers."
  default     = "datadoghq.com"
  # TODO: validation
}

variable "pipeline-id" {
  type        = string
  description = "Observability Pipelines ID to use for config reporting."
}

variable "pipeline-config" {
  type        = string
  description = "Observability Pipelines config to seed into the instances."
}

# TODO: remote configuration variables
variable "environment" {
  type        = map(string)
  description = "Additional environment variables to seed to the instances."
  default     = {}
}

variable "vpc-id" {
  type        = string
  description = "VPC to spawn instances in."
}

variable "subnet-ids" {
  type        = list(string)
  description = "Subnets to spawn instances in."
}

variable "region" {
  type        = string
  description = "Region to spawn instances in."
}

variable "tcp-ports" {
  type        = list(number)
  description = "TCP ports to open/listen on. Defaults to the Datadog Agent port."
  default     = [8282]
}

variable "udp-ports" {
  type        = list(number)
  description = "UDP ports to open/listen on."
  default     = []
}

variable "instance-type" {
  type        = string
  description = "EC2 instance size to launch. Defaults to c6g.4xlarge, our production recommendation."
  default     = "c6g.4xlarge"
}

variable "autoscaling-max-size" {
  type        = number
  description = "Max instances to create."
  default     = 3
}

variable "autoscaling-min-size" {
  type        = number
  description = "Min instances to create."
  default     = 3
}

variable "ami-id" {
  type        = string
  default     = ""
  description = "Use a specific AMI ID. This must be an Ubuntu-based image."
}

variable "assign-public-ip" {
  type        = bool
  description = "Make the instances publicly accessible. Defaults to false. Do not change this unless you have a specific reason to."
  default     = false
}

variable "extra-security-groups" {
  type        = list(string)
  description = "Security Group IDs to add to the one created by this manifest, if any."
  default     = []
}

variable "cross-zone-lb" {
  type        = bool
  description = "Enable cross-zone load balancing. Defaults to false to save on costs."
  default     = false
}

variable "ebs-drive-size-gb" {
  type        = number
  description = "Size of EBS drives to attach to each instance. Defaults to 300GB, which is our default production recommendation."
  default     = 300
}

variable "ebs-drive-type" {
  type        = string
  description = "What kind of EBS drive to attach to the instances. Defaults to gp3, which is a decent production choice."
  default     = "gp3"
}

# TODO: extra tags variable
locals {
  tcp-ports = toset([for v in var.tcp-ports : tostring(v)])
  udp-ports = toset([for v in var.udp-ports : tostring(v)])

  envs = join("\n", formatlist("%s=%s", keys(var.environment), values(var.environment)))
}
