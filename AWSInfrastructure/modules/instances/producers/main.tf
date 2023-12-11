data "aws_ami" "java" {
  most_recent = true
  owners = ["self"]
  filter {
    name   = "name"
    values = ["JavaServer1"]
  }  
}

resource "aws_instance" "producer" {
  ami           = data.aws_ami.java.id
  instance_type = "t2.micro" //Free tier resource
  subnet_id     = var.public_subnet_id
  key_name      = var.key_name // Change to your key name
  security_groups = [
    var.ssh_sg_id,
    var.producer_sg_id
    
    ]

  tags = {
    Name = "producer-instance"
  }
}