terraform {
  required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

### Provider

provider "aws" {

    region = "us-east-1"
  
}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"

  name               = "my-vpc"
  cidr               = "10.0.0.0/16"

  azs                = ["us-east-1a", "us-east-1b"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]

  map_public_ip_on_launch = true
  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform        = "true"
    Environment      = "dev"
  }
}

module "SSH_SG"{
   source = "terraform-aws-modules/security-group/aws"

  name        = "ssh-sg"
  description = "Security group for ec2 instances to allow ssh connection from your ip"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = ["ssh-tcp"]
  ingress_cidr_blocks = ["${var.IP_CONFIG}/32"]
}

module "endpoint_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "endpoint-sg"
  description = "Security group to allow outbound traffic to ec2 instances within VPC"
  vpc_id      = module.vpc.vpc_id

  egress_rules        = ["ssh-tcp"]
  egress_cidr_blocks  = [module.vpc.vpc_cidr_block]
}

module "ec2-eci_sg" {
  source = "terraform-aws-modules/security-group/aws"
  
  name = "ec2-eci-sg"
  description = "Security group that allows incoming traffic from endpoint"
  vpc_id =  module.vpc.vpc_id
  
  ingress_with_source_security_group_id =  [
    {
      rule = "ssh-tcp"
      source_security_group_id = module.endpoint_sg.security_group_id
    }
  ]
}

module "producer_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "producer-sg"
  description = "Security group for the producer with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      description = "Spring servers"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  ingress_with_source_security_group_id = [
    {
      rule                     = "kafka-broker-tcp"
      source_security_group_id = module.kafka_sg.security_group_id
    }
  ]
  
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}

module "kafka_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "kafka-sg"
  description = "Security group for the kafka broker"
  vpc_id      = module.vpc.vpc_id

  
 ingress_with_source_security_group_id = [
    {
      rule                     = "kafka-broker-tcp"
      source_security_group_id = module.producer_sg.security_group_id
    },
    {
      rule                     = "kafka-broker-tcp"
      source_security_group_id = module.consumer_sg.security_group_id
    }
  ]

  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}

module "consumer_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "consumer-sg"
  description = "Security group for the consummer"
  vpc_id      = module.vpc.vpc_id

  
 ingress_with_source_security_group_id = [
    {
      rule                     = "kafka-broker-tcp"
      source_security_group_id = module.kafka_sg.security_group_id
    }
  ]

  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}



module "prodcuer-instance" {
  source = "./modules/instances/producers"
  public_subnet_id = module.vpc.public_subnets[0]
  key_name = "terraformtask"
  ssh_sg_id = module.SSH_SG.security_group_id
  producer_sg_id = module.producer_sg.security_group_id
  
}

module "consumers-instances" {
  source = "./modules/instances/consumers"
  consumers_names = [ "emailservice","stockservice"]
  private_subnet_id = module.vpc.private_subnets[0]
  consumer_sg_id = module.consumer_sg.security_group_id
  ec2_eci_sg = module.ec2-eci_sg.security_group_id
}

module "kafka-brokers" {
  source = "./modules/instances/brokers"
  private_subnet_id = module.vpc.private_subnets[0]
  kafka_sg_id = module.kafka_sg.security_group_id
  key_name = "terraformtask"
  ec2-eci_sg_id = module.ec2-eci_sg.security_group_id
  
}

module "endpoints" {
  source = "./modules/endpoints"
  vpc_id = module.vpc.vpc_id
  vpc_private_route_table_ids = module.vpc.private_route_table_ids
  vpc_private_subnets = module.vpc.private_subnets[0]
  endpoint_sg_id = module.endpoint_sg.security_group_id
  
}


module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "terraformtask12723"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = false
  }
}
  
