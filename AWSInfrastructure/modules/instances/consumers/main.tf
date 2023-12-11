data "aws_ami" "java" {
  most_recent = true
  owners = ["self"]
  filter {
    name   = "name"
    values = ["JavaServer1"]
  }  
}

resource "aws_instance" "consumer"{
  for_each = toset(var.consumers_names)
  ami =data.aws_ami.java.id
  instance_type = "t2.micro"
  subnet_id = var.private_subnet_id
  security_groups = [
    var.consumer_sg_id,
    var.ec2_eci_sg
    ]

  tags ={
    Name = "consumer-instance-${lower(each.key)}"
  }
}