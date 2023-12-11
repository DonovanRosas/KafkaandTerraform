variable "vpc_id" {
    description = "The VPC where you are going to build"
    
}

variable "vpc_private_route_table_ids" {
  description = "Id of the route tables"
}

variable "vpc_private_subnets" {
  description = "Id of the private subnet"
}

variable "endpoint_sg_id" {
    description = "id of the security group of the endpoint"
}