resource "aws_iam_role" "ds-cluster-iam" {
  name = "ds-eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ds-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.ds-cluster-iam.name
}

resource "aws_iam_role_policy_attachment" "ds-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.ds-cluster-iam.name
}

resource "aws_security_group" "ds-cluster" {
  name        = "ds-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.ds.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ds-eks-cluster"
  }
}

resource "aws_security_group_rule" "ds-cluster-ingress-workstation-https" {
  cidr_blocks       = [local.workstation-external-cidr]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.ds-cluster.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "ds" {
  name     = var.cluster-name
  role_arn = aws_iam_role.ds-cluster-iam.arn

  vpc_config {
    security_group_ids = [aws_security_group.ds-cluster.id]
    subnet_ids         = aws_subnet.ds[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.ds-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.ds-cluster-AmazonEKSVPCResourceController,
  ]
}