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