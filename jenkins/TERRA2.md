<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.1.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dlm_lifecycle_policy.jenkins_lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dlm_lifecycle_policy) | resource |
| [aws_eip.myip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_instance_profile.jenkins_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.jenkins_ec2_instance_profile_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.jenkins_dlm_lifecycle_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.jenkins_ec2_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.jenkins_lifecyle_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_instance.jenkins_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_nat_gateway.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_interface.multi-ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_route.route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_security_group.jenkins_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | Aws Profile used to create resources, will be passed into the tags | `string` | `"jenkins-user"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to create resources | `string` | `"us-east-1"` | no |
| <a name="input_az"></a> [az](#input\_az) | AZ the EBS Volume and EC2 instance will be created in need to match | `string` | `"us-east-1a"` | no |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | CIDR Block to allow Jenkins Access, added to security group that is created | `string` | `"172.31.0.0/16"` | no |
| <a name="input_created"></a> [created](#input\_created) | How the resources were created, CICD or Jenkins should override this | `string` | `"jenkins"` | no |
| <a name="input_ec2_instance_profile"></a> [ec2\_instance\_profile](#input\_ec2\_instance\_profile) | The instance profile for the ec2 instances | `string` | `"jenkins-ec2-instance-profile-role"` | no |
| <a name="input_ec2_instance_profile_policy"></a> [ec2\_instance\_profile\_policy](#input\_ec2\_instance\_profile\_policy) | n/a | `string` | `"jenkins-ec2-instance-profile-policy"` | no |
| <a name="input_ec2_private_ip"></a> [ec2\_private\_ip](#input\_ec2\_private\_ip) | n/a | `string` | `"172.31.0.10"` | no |
| <a name="input_email"></a> [email](#input\_email) | Email added as a tag to resources for any communication required | `string` | `"shanechambers85+jenkins@gmail.com"` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | n/a | `string` | `"jenkins-master"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | n/a | `string` | `"t2.micro"` | no |
| <a name="input_kms_key_ebs_id"></a> [kms\_key\_ebs\_id](#input\_kms\_key\_ebs\_id) | Kms Key for EBS\_Jenkins | `string` | `"b9b9e136-e0a1-4356-98a6-cedf16d320c5"` | no |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | Name of keypair to ssh | `string` | `"jenkins_key"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet to put the ec2 instance into | `string` | `"subnet-0af7db4bb425893c5"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Operations VPC where Jenkins master lives | `string` | `"vpc-0c912ef621e20711f"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->