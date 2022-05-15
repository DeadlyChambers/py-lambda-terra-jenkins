
data "aws_caller_identity" "current" {

}
locals {
  calling_role = data.aws_caller_identity.current.arn
  kms_key_ebs  = "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:key/${var.kms_key_ebs_id}"
  tags = {
    "soin:owned_by"   = "devops"
    "soin:contact"    = var.email
    "soin:created"    = var.created
    "soin:operations" = "restrict"
    "soin:git_repo"   = "git@github.com:DeadlyChambers/py-lambda-terra-jenkins.git"
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = local.tags
  }
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-security-group"
  description = "Allow Jenkins Traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow Https from VPN"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block, "70.59.19.225/32"]
  }
  ingress {
    description = "Allow SSH from Personal CIDR block"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block, "70.59.19.225/32"]
  }
  ingress {
    description = "Allow resources with the security group to communicate over 9000"
    from_port   = -1
    to_port     = -1
    protocol    = "tcp"
    self        = true

  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name              = "jenkins-security-group"
    "soin:created_by" = local.calling_role
  }
  tags_all = local.tags
}

resource "aws_network_interface" "multi-ip" {
  subnet_id   = var.subnet_id
  private_ips = [var.ec2_private_ip]
  tags = {
    "Name"            = "jenkins-eni"
    "soin:created_by" = local.calling_role
  }
}

resource "aws_eip" "myip" {
  vpc               = true
  network_interface = aws_network_interface.multi-ip.id
  tags = {
    "Name"            = "jenkins-eip"
    "soin:created_by" = local.calling_role
  }
}




resource "aws_route" "route" {
  route_table_id = "rtb-0e0e6acd47a846e8c"
  nat_gateway_id = aws_nat_gateway.example.id
}

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.myip
  subnet_id     = var.subnet_id


  tags = {
    Name              = "default-nat"
    "soin:created_by" = local.calling_role
  }


}
resource "aws_iam_role" "jenkins_ec2_instance_profile" {
  name = var.ec2_instance_profile
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Effect" : "Allow",
          "Sid" : "EC2TrustPolicy"
        }
      ]
  })
  managed_policy_arns = [resource.aws_iam_policy.jenkins_ec2_instance_profile_policy.arn]
  tags = {
    Name = var.ec2_instance_profile
  "soin:created_by" = local.calling_role }
}

resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  # Because this expression refers to the role, Terraform can infer
  # automatically that the role must be created first.
  role = resource.aws_iam_role.jenkins_ec2_instance_profile.name

}

resource "aws_iam_policy" "jenkins_ec2_instance_profile_policy" {
  name = var.ec2_instance_profile_policy
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [

      {

        "Sid" : "JenkinsEC2AssumeRolePolicy",
        "Action" : "sts:AssumeRole",
        "Resource" : [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/soinshane-deployer-role",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/soinshane-sso-admin",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/soinshane-code-full-access",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/PassRoleCustomSecretManager"],
        "Effect" : "Allow"
      },
      {
        "Action" : "s3:*",
        "Resource" : "*",
        "Effect" : "Allow",
        "Sid" : "JenkinsEC2S3Policy"
      },
      {
        "Sid" : "JenkinsKMSKeyPolicy",
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ListGrants",
          "kms:DescribeKey"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "${local.kms_key_ebs}"
        ]
      },
      {
        "Sid" : "JenkinsAllowAll",
        "Effect" : "Allow",
        "Action" : [
          "application-autoscaling:*",
          "autoscaling:*",
          "cloudformation:*",
          "cloudtrail:*",
          "dynamodb:*",
          "dlm:*",
          "ecr-public:*",
          "lambda:*",
          "ecs:*",
          "ecr:*",
          "ec2:*",
          "events:*",
          "cloudwatch:*",
          "logs:*",
          "servicediscovery:*",
          "route53:*",
          "elasticloadbalancing:*",
          "sns:*",
          "sqs:*"
        ],
        "Resource" : "*"
      }
    ]
  })
  tags = {
    Name              = var.ec2_instance_profile_policy
    "soin:created_by" = local.calling_role
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

}

resource "aws_instance" "jenkins_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  vpc_security_group_ids  = [resource.aws_security_group.jenkins_sg.id]
  user_data               = file("install_jenkins.sh")
  availability_zone       = var.az
  disable_api_termination = false
  subnet_id               = var.subnet_id
  iam_instance_profile    = resource.aws_iam_instance_profile.jenkins_instance_profile.name
  private_ip              = var.ec2_private_ip
  root_block_device {
    delete_on_termination = "false"
    encrypted             = true
    volume_size           = 20
    kms_key_id            = local.kms_key_ebs
    tags = {
      Name                    = "jenkins-master-ebs"
      "soin:lifecycle_policy" = "jenkins"
    }
  }
  tags = {
    Name              = var.instance_name
    "soin:created_by" = local.calling_role
  }
}


resource "aws_iam_role" "jenkins_dlm_lifecycle_role" {
  name = "jenkins-dlm-lifecycle-role"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "dlm.amazonaws.com"
          },
          "Effect" : "Allow",
          "Sid" : "jenkinsdlmrole"
        }
      ]
  })
  tags = {
    Name              = "jenkins-dlm-lifecycle-role"
    "soin:created_by" = local.calling_role
    "soin:volume"     = "jenkins"
  }
}

resource "aws_iam_role_policy" "jenkins_lifecyle_role_policy" {
  name = "jenkins-dlm-lifecycle-policy"
  role = aws_iam_role.jenkins_dlm_lifecycle_role.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateSnapshot",
            "ec2:DeleteSnapshot",
            "ec2:DescribeVolumes",
            "ec2:DescribeSnapshots"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateTags"
          ],
          "Resource" : "arn:aws:ec2:*::snapshot/*"
        },
        {
          "Sid" : "JenkinsKMSKeyPolicy",
          "Action" : [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ListGrants",
            "kms:DescribeKey"
          ],
          "Effect" : "Allow",
          "Resource" : "${local.kms_key_ebs}"
        }
      ]
  })

}

resource "aws_dlm_lifecycle_policy" "jenkins_lifecycle" {
  description        = "DLM lifecycle policy"
  execution_role_arn = aws_iam_role.jenkins_dlm_lifecycle_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "1 Snapshot every 2 days of Jenkins root volume"

      create_rule {
        interval      = 48
        interval_unit = "HOURS"
        times         = ["23:45"]
      }

      retain_rule {
        count = 1
      }

      tags_to_add = {
        "soin:created_by" = "DLM"
      }

      copy_tags = true
    }

    target_tags = {
      "soin:lifecycle_policy" = "jenkins"
    }

  }


  tags = {
    Name              = "jenkins-dlm-lifecycle"
    "soin:created_by" = local.calling_role
    "soin:volume"     = "jenkins"
  }
}

