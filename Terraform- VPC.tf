# Using AWS VPC modules to create VPC

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "Sujata_Course Assignment_VPC"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a","us-east-1b"]
  private_subnets = ["10.0.1.0/24","10.0.3.0/24"]
  public_subnets  = ["10.0.2.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

# Creating Public Security groups and Private security groups

module "public_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "bastion-service"
  description = "Public SG Course Assigment"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

module "private_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "private-service"
  description = "Private SG Course Assigment"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.0.0.0/16"
    }
  ]
  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_instance" "bastion_host" {

  ami                         = "ami-007855ac798b5175e"
  instance_type               = "t2.small"
  key_name                    = "NewKey"
  vpc_security_group_ids      = [module.public_sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]

  associate_public_ip_address = true
  tags = {
    Name = "bastion host"
  }
}
resource "aws_instance" "Jenkins_host" {

  ami                         = "ami-007855ac798b5175e"
  instance_type               = "t2.small"
  key_name                    = "NewKey"
  vpc_security_group_ids      = [module.private_sg.security_group_id]
  subnet_id                   = module.vpc.private_subnets[0]

  associate_public_ip_address = false
  tags = {
    Name = "Jenkins host"
  }
}

resource "aws_instance" "Application_host" {

  ami                         = "ami-007855ac798b5175e"
  instance_type               = "t2.small"
  key_name                    = "NewKey"
  vpc_security_group_ids      = [module.private_sg.security_group_id]
  subnet_id                   = module.vpc.private_subnets[1]

  associate_public_ip_address = false
  tags = {
    Name = "Application host"
  }
}
