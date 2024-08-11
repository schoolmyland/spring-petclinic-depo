# User list that need to have the AmazonEKSClusterAdminPolicy access on the cluster

locals {
  iam_access_entries = [
    {
      policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      principal_arn = "arn:aws:iam::${var.account_id}:root"
    },
    {
      policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      principal_arn = "arn:aws:iam::${var.account_id}:user/${var.operator_account}"
    },

  ]
}

#---------------
# ROLE
#---------------

# Create a role to Allow Right on the Cluster 
resource "aws_iam_role" "eks_cluster" {
  name = "eks_cluster_IAM_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "${var.appname}-IAM-role-eks-cluster"
  }
}

# Config role Node group 

# Create an IAM role for EKS node group with a specific assume role policy.
resource "aws_iam_role" "eks_nodes" {
  name = "iam_role_eks_nodes"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "${var.appname}-IAM-role-eks-nodes-group"
  }
}



# Provide to Kubernetes the permission to tag ressources
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# Allow the Driver EBS CSI to make call for EC2
resource "aws_iam_role_policy_attachment" "ebs_csi_controller_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_nodes.name
}

# Allow the node to connect to the cluster
resource "aws_iam_role_policy_attachment" "eks_worker_nodegroup_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

#Authorization for the addon VPC_CNI
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

# Even if your Images are not from Amazon ECR the node group need it to work properly 
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}


#---------------
# CLUSTER
#---------------

# Config Cluster

resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.appname}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids =  flatten([var.sn_pub_ids, var.sn_priv_ids])
  }
  
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
  ]
  tags = {
    Name = "${var.appname}-eks-cluster"
    Application = var.appname
  }
}



resource "aws_eks_access_entry" "eks_access_entry" {
  for_each       = { for entry in local.iam_access_entries : entry.principal_arn => entry }
  cluster_name  = aws_eks_cluster.eks_cluster.name  
  principal_arn = each.value.principal_arn
  type          = "STANDARD"
  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

resource "aws_eks_access_policy_association" "eks_policy_association" {
  for_each       = { for entry in local.iam_access_entries : entry.principal_arn => entry }
  cluster_name  = aws_eks_cluster.eks_cluster.name
  policy_arn    = each.value.policy_arn
  principal_arn = each.value.principal_arn
  depends_on = [
    aws_eks_cluster.eks_cluster
  ]

  access_scope {
    type       = "cluster"
  }
}


#---------------
# NODE GROUP
#---------------

# Create the node groups used by the services into the private subnet

resource "aws_eks_node_group" "eks_node_nodegroup_back" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.appname}-eks-nodegroup-back"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      =  flatten([var.sn_priv_ids])

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 2
  }

  ami_type       = "AL2_x86_64"
  instance_types = var.instance_type_back


  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_nodegroup_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]
  tags = {
    Name = "${var.appname}-${var.customer1}-${var.customer2}-eks-node-group-back"
    Application = var.appname
  }
  labels = {
    "nodetype" = "private"
  }
}

# Create the node groups used by the api-gateway into the public subnet

resource "aws_eks_node_group" "eks_node_nodegroup_front" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.appname}-eks-nodegroup-front"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      =  flatten([var.sn_pub_ids])

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  ami_type       = "AL2_x86_64"
  instance_types = var.instance_type_front

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_nodegroup_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]
  tags = {
    Name = "${var.appname}-${var.customer1}-${var.customer2}-eks-node-group-front"
    Application = var.appname
    
  }
  labels = {
    "nodetype" = "public"
  }
}

resource "aws_eks_node_group" "eks_node_nodegroup_monitor" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.appname}-eks-nodegroup-monitor"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      =  flatten([var.sn_priv_ids])

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  ami_type       = "AL2_x86_64"
  instance_types = var.instance_type_monitor

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_nodegroup_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]
  tags = {
    Name = "${var.appname}-eks-node-group-monitor"
    Application = "Grafana"
  }
  labels = {
    "nodetype" = "monitoring"
  }
}

# System node group 
resource "aws_eks_node_group" "eks_node_nodegroup_system" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.appname}-eks-nodegroup-system"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      =  flatten([var.sn_priv_ids])

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  ami_type       = "AL2_x86_64"
  instance_types = var.instance_type_monitorfront

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_nodegroup_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]
  tags = {
    Name = "${var.appname}-eks-node-group-system"
    Application = "Kubernetes"
  }
  labels = {
    "nodetype" = "monitorfront"
    "role" = "system"
  }
}

#---------------
# ADDONS 
#---------------

# Assure the link between the nodegroup and the pods
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "vpc-cni"
  addon_version      =  "v1.18.2-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}
# Assure the network rules maintenancy between the pods and the node group
resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "kube-proxy"
  addon_version      = "v1.30.0-eksbuild.3"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

}

resource "aws_eks_addon" "eks-pod-identity-agent" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "eks-pod-identity-agent"
  addon_version      = "v1.3.0-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

}


# DNS resolution for pods and cluster  IF Node group not start yet, the addons will start in "depreciate mode"
resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "coredns"
  addon_version      = "v1.11.1-eksbuild.9"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [
    aws_eks_node_group.eks_node_nodegroup_back,
    aws_eks_node_group.eks_node_nodegroup_front,
    aws_eks_node_group.eks_node_nodegroup_monitor
  ]
}

#Driver of the EBS storage ! IF Node group not start yet, the addons will start in "depreciate mode" 
resource "aws_eks_addon" "ebs_driver" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "aws-ebs-csi-driver"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [
    aws_eks_node_group.eks_node_nodegroup_back,
    aws_eks_node_group.eks_node_nodegroup_front,
    aws_eks_node_group.eks_node_nodegroup_monitor
  ]
}


