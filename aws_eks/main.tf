# Creating IAM role for Kubernetes clusters to make calls to other AWS services on your behalf to manage the resources that you use with the service.
resource "aws_iam_role" "iam-role-eks-cluster" {
  name = "terraformekscluster"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

# Attaching the EKS-Cluster policies to the terraform ekscluster role.
resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.iam-role-eks-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.iam-role-eks-cluster.name}"
}

# Security group for network traffic to and from AWS EKS Cluster.
resource "aws_security_group" "eks-cluster" {
  name        = "eks-cluster-sg"
  vpc_id      = "${var.vpc_id}"  

# Egress allows Outbound traffic from the EKS cluster to the  Internet 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Ingress allows Inbound traffic to EKS cluster from the  Internet 
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating the EKS cluster
resource "aws_eks_cluster" "this" {
  name     = "dev-cluster"
  role_arn = "${aws_iam_role.iam-role-eks-cluster.arn}"
  version  = "1.22"

# Adding VPC Configuration
  vpc_config {
    security_group_ids = ["${aws_security_group.eks-cluster.id}"]
    subnet_ids         = var.vpc_subnets
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy,
  ]
}

# Creating IAM role for EKS nodes to work with other AWS Services. 
resource "aws_iam_role" "eks_nodes" {
  name = "eks-node-group"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Attaching the different Policies to Node Members.
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

# Create EKS cluster node group
resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "node-group-1"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.vpc_subnets

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  ami_type       = "AL2_x86_64"
  instance_types = ["t2.micro"]
  capacity_type  = "ON_DEMAND"
  disk_size      = 10

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}