variable "aws_region" {
  description = "AWS region to create resources"
  default     = "us-east-1"
}
variable "az" {
  description = "AZ the EBS Volume and EC2 instance will be created in need to match"
  default     = "us-east-1a"
}

variable "vpc_id" {
  description = "Operations VPC where Jenkins master lives"
  default     = "vpc-0c912ef621e20711f"
}
variable "subnet_id" {
  description = "Subnet to put the ec2 instance into"
  default     = "subnet-0af7db4bb425893c5"
}
variable "ec2_private_ip" {
  default = "172.31.0.10"
}

variable "cidr_block" {
  description = "CIDR Block to allow Jenkins Access, added to security group that is created"
  default     = "172.31.0.0/16"
}

variable "kms_key_ebs_id" {
  description = "Kms Key for EBS_Jenkins"
  default     = "b9b9e136-e0a1-4356-98a6-cedf16d320c5"
  type        = string
}


variable "ssh_key_name" {
  description = "Name of keypair to ssh"
  default     = "jenkins_key"
}

variable "ec2_instance_profile" {
  description = "The instance profile for the ec2 instances"
  default     = "jenkins-ec2-instance-profile-role"
}

variable "ec2_instance_profile_policy" {
  default = "jenkins-ec2-instance-profile-policy"
}



variable "instance_name" {
  default = "jenkins-master"
  type    = string
}

variable "instance_type" {
  default = "t2.micro"
  type    = string
}

variable "created" {
  description = "How the resources were created, CICD or Jenkins should override this"
  default     = "jenkins"
  type        = string
}

variable "email" {
  description = "Email added as a tag to resources for any communication required"
  default     = "shanechambers85+jenkins@gmail.com"
  type        = string
}

variable "aws_profile" {
  description = "Aws Profile used to create resources, will be passed into the tags"
  default     = "jenkins-user"
  type        = string
}


