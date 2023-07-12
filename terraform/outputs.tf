output "gitlab-public-dns" {
  value = aws_instance.gitlab.public_dns
}

output "kubernetes-public-dns" {
  value = aws_instance.kubernetes.public_dns
}
