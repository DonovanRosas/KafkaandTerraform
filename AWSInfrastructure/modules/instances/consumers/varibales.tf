variable "consumers_names" {
    description = "List of your consumer names"
    type = list(string)
  
}
variable "private_subnet_id" {
    description = "Id of the private subnet"
    
}
variable "consumer_sg_id" {
    description = "Id of the ssh security group"
    
}

variable "ec2_eci_sg" {
    description = "Id of the producer security-group"
    
}