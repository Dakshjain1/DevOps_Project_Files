#provider
provider "aws" {
  profile = "root"
  region  = "ap-south-1"
}

# vpc
resource "aws_vpc" "tf_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy = "default"
  tags= {
     Name = "k8s-cluster-vpc"
     "kubernetes.io/cluster/kubernetes" = "owned"
}
}

# subnet
resource "aws_subnet" "tf_subnet" {
  depends_on = [
    aws_vpc.tf_vpc
  ]
  availability_zone = "ap-south-1a"
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags= {
     Name = "k8s-cluster-subnet"
     "kubernetes.io/cluster/kubernetes" = "owned"
}
}

# internet gateway
resource "aws_internet_gateway" "tf_ig" {
  depends_on = [
    aws_vpc.tf_vpc
  ]
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name = "k8s-cluster-igw"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

# route table
 resource "aws_route_table" "tf_route" {
  depends_on = [
    aws_vpc.tf_vpc
  ]
  vpc_id = aws_vpc.tf_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_ig.id
  }
  tags = {
    Name = "k8s-cluster-rtb"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

# route association
resource "aws_route_table_association" "tf_assoc" {
  depends_on = [
    aws_subnet.tf_subnet
  ]
  subnet_id      = aws_subnet.tf_subnet.id
  route_table_id = aws_route_table.tf_route.id
}

# iam policy - master
resource "aws_iam_policy" "tf_policy_master" {
  name        = "k8s-cluster-master-iam-role-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "ec2:DescribeInstances",
                "ec2:DescribeRegions",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVolumes",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifyVolume",
                "ec2:AttachVolume",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateRoute",
                "ec2:DeleteRoute",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteVolume",
                "ec2:DetachVolume",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:DescribeVpcs",
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:AttachLoadBalancerToSubnets",
                "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateLoadBalancerPolicy",
                "elasticloadbalancing:CreateLoadBalancerListeners",
                "elasticloadbalancing:ConfigureHealthCheck",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeleteLoadBalancerListeners",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DetachLoadBalancerFromSubnets",
                "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeLoadBalancerPolicies",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
                "iam:CreateServiceLinkedRole",
                "kms:DescribeKey"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*"
        }
    ]
}
EOF
}

# iam role for master
resource "aws_iam_role" "tf_role_master" {
  name = "k8s-cluster-iam-master-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# instance profile for master
resource "aws_iam_instance_profile" "tf_profile_master" {      
    name  = "k8s-cluster-iam-master-profile"                         
    role = aws_iam_role.tf_role_master.name
}

# attach policy to role - master
resource "aws_iam_policy_attachment" "tf_attach_master" {
  name       = "k8s-cluster-iam-master-attachment"
  roles      = [aws_iam_role.tf_role_master.name]
  policy_arn = aws_iam_policy.tf_policy_master.arn
}

# iam policy - worker
resource "aws_iam_policy" "tf_policy_worker" {
  name        = "k8s-cluster-worker-iam-role-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeRegions",
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:BatchGetImage"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*"
        }
    ]
}
EOF
}

# iam role for worker
resource "aws_iam_role" "tf_role_worker" {
  name = "k8s-cluster-iam-worker-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# instance profile for worker
resource "aws_iam_instance_profile" "tf_profile_worker" {      
    name  = "k8s-cluster-iam-worker-profile"                         
    role  = aws_iam_role.tf_role_worker.name
}

# attach policy to role - worker
resource "aws_iam_policy_attachment" "tf_attach_worker" {
  name       = "k8s-cluster-iam-worker-attachment"
  roles       = [aws_iam_role.tf_role_worker.name]
  policy_arn = aws_iam_policy.tf_policy_worker.arn
}

# Export subnet value to an Ansible var_file
resource "local_file" "tf_ansible_subnet_value_file" {
  content = <<EOF
vpcid: ${aws_vpc.tf_vpc.id}
subnet: ${aws_subnet.tf_subnet.id}
    EOF
  filename = "./tf_subnet_id_value.yml"
}
