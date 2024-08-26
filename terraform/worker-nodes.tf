# Fetch the latest Amazon EKS worker AMI ID
data "aws_ami" "eks_worker" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-*-v*"]  # This pattern fetches the latest EKS worker AMI
  }

  filter {
    name   = "owner-id"
    values = ["602401143452"]  # This is the AWS official EKS AMI owner ID
  }

}

resource "aws_iam_role" "eks_worker_role" {
    name = "eks-worker-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })

    tags = {
        Name = "eks-worker-role"
    }
}

resource "aws_iam_role_policy_attachment" "eks_worker_role_policy" {
    role       = aws_iam_role.eks_worker_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_instance_profile" "eks_worker_profile" {
    name = "eks-worker-profile"
    role = aws_iam_role.eks_worker_role.name
}

resource "aws_launch_configuration" "eks_worker_lc" {
    name                 = "eks-worker-lc"
    image_id             = data.aws_ami.eks_worker.id
    instance_type        = "t3.medium"
    iam_instance_profile = aws_iam_instance_profile.eks_worker_profile.id

    root_block_device {
        volume_size = 20
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "eks_worker_asg" {
    desired_capacity     = 2
    max_size             = 3
    min_size             = 1
    launch_configuration = aws_launch_configuration.eks_worker_lc.id
    vpc_zone_identifier = aws_subnet.eks_subnet[*].id

    tag {
        key                  = "kubernetes.io/cluster/${aws_eks_cluster.eks_cluster.name}"
        value                = "owned"
        propagate_at_launch = true
    }
}
