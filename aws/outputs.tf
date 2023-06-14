# Unless explicitly stated otherwise all files in this repository are licensed under the Apache 2 License.
#
# This product includes software developed at Datadog (https://www.datadoghq.com/). Copyright 2023 Datadog, Inc.
output "asg-name" {
    value = aws_autoscaling_group.opw.name
}

output "iam-role-name" {
    value = aws_iam_role.opw.name
}

output "lb-dns" {
    value = aws_lb.opw.dns_name
}

output "security-group-id" {
    value = aws_security_group.opw.id
}