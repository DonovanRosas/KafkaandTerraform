
resource "aws_ec2_instance_connect_endpoint" "endpoint" {

  subnet_id = var.vpc_private_subnets
  security_group_ids = [var.endpoint_sg_id]
  preserve_client_ip = false

  tags ={
    Name = "EC2-instance-connect-endpoint"
  }
  
}

resource "aws_vpc_endpoint" "s3" {

    service_name = "com.amazonaws.us-east-1.s3"
    vpc_id = var.vpc_id
    route_table_ids = var.vpc_private_route_table_ids
    
    tags = {
      Name = "gateway-endpoint"
    }
  
}
