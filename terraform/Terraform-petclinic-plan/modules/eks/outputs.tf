# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = aws_eks_cluster.eks_cluster.name
}
/*
output "eks_cluster_oidc_issuer_url" {
  description = "Kubernetes Cluster Name"
  value       = aws_eks_cluster.eks_cluster.cluster_oidc_issuer_url
}
*/


