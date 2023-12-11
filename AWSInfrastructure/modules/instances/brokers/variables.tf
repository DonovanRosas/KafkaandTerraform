variable "number_brokers" {
    description = "number of Brokers"
    type = number
    default = 1
}

variable "private_subnet_id" {
    description = "Id of the private subnet"
    
}

variable "key_name" {
  description = "name of te key"
}
variable "kafka_sg_id" {
    description = "id of the kafka securitygroup"
    
}
variable "ec2-eci_sg_id" {
  description = "id of the ec2-eci security group"
}