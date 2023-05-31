# TODO: Persistence

# Taken from https://github.com/mamemomonga/terraform-aws-linux-ami
data "aws_ami" "ubuntu2204-arm64" {
  most_recent = true
  name_regex  = "^ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-\\d{8}$"
  owners      = ["099720109477"]
}

data "aws_vpc" "selected" {
  id = var.vpc-id
}

data "cloudinit_config" "opw" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./install.sh", {
      api-key         = var.datadog-api-key,
      pipeline-id     = var.pipeline-id,
      site            = var.datadog-site,
      pipeline-config = var.pipeline-config,
    })
  }
}

resource "aws_launch_template" "opw" {
  name_prefix   = "opw"
  image_id      = var.ami-id != "" ? var.ami-id : data.aws_ami.ubuntu2204-arm64.id
  instance_type = var.instance-type
  iam_instance_profile {
    name = aws_iam_instance_profile.opw.name
  }

  network_interfaces {
    associate_public_ip_address = var.assign-public-ip
    security_groups             = concat([aws_security_group.opw.id], var.extra-security-groups)
  }

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = var.ebs-drive-size-gb
      volume_type = var.ebs-drive-type
    }
  }

  user_data = data.cloudinit_config.opw.rendered
}

resource "aws_autoscaling_group" "opw" {
  name_prefix         = "opw"
  max_size            = var.autoscaling-max-size
  min_size            = var.autoscaling-min-size
  vpc_zone_identifier = var.subnet-ids

  launch_template {
    id      = aws_launch_template.opw.id
    version = aws_launch_template.opw.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
  }
}

resource "aws_security_group" "opw" {
  name        = "opw"
  description = "Ingress rules for OPW. Allows traffic from the LBs."
  vpc_id      = var.vpc-id
}

resource "aws_vpc_security_group_ingress_rule" "opw-tcp" {
  for_each          = local.tcp-ports
  security_group_id = aws_security_group.opw.id

  # We allow from anything in the same VPC by default.
  # See: https://docs.aws.amazon.com/elasticloadbalancing/latest/network/target-group-register-targets.html#target-security-groups
  cidr_ipv4   = data.aws_vpc.selected.cidr_block
  from_port   = tonumber(each.key)
  ip_protocol = "tcp"
  to_port     = tonumber(each.key)
}

resource "aws_vpc_security_group_ingress_rule" "opw-udp" {
  for_each          = local.udp-ports
  security_group_id = aws_security_group.opw.id

  # We allow from anything in the same VPC by default.
  # See: https://docs.aws.amazon.com/elasticloadbalancing/latest/network/target-group-register-targets.html#target-security-groups
  cidr_ipv4   = data.aws_vpc.selected.cidr_block
  from_port   = tonumber(each.key)
  ip_protocol = "udp"
  to_port     = tonumber(each.key)
}

resource "aws_vpc_security_group_egress_rule" "opw-allow-egress" {
  description       = "Allow egress traffic to anywhere."
  from_port         = -1
  to_port           = -1
  ip_protocol       = "-1"
  security_group_id = aws_security_group.opw.id
  cidr_ipv4         = "0.0.0.0/0"
}

