# EKS Cluster Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.project_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Cluster endpoint access
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Cluster addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    # EBS CSI driver disabled for demo deployments (use emptyDir volumes)
    # Saves deployment time (~20 min) and costs
  }

  # EKS Managed Node Group
  eks_managed_node_groups = {
    main = {
      name = "main"

      instance_types = var.node_instance_types
      capacity_type  = "ON_DEMAND"

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      # Labels for pod scheduling
      labels = {
        Environment = var.environment
        NodeGroup   = "main"
      }

      # Tags for autoscaling
      tags = merge(
        var.tags,
        {
          "k8s.io/cluster-autoscaler/${var.project_name}" = "owned"
          "k8s.io/cluster-autoscaler/enabled"             = "true"
        }
      )
    }
  }

  # Enable IRSA (IAM Roles for Service Accounts)
  enable_irsa = true

  # Additional security group rules for worker nodes
  node_security_group_additional_rules = {
    # Allow inbound traffic from internet to NodePort range for NLB
    ingress_nlb_nodeport = {
      description = "Allow NLB traffic to Kubernetes NodePort range"
      protocol    = "tcp"
      from_port   = 30000
      to_port     = 32767
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = var.tags
}

