data "aws_ami" "kafka" {
  most_recent = true
  owners = ["self"]
  filter {
    name   = "name"
    values = ["KafkaBrokerImage"]
  }  
}
resource  "aws_instance" "kafka-broker" {
  count = var.number_brokers
  ami  = data.aws_ami.kafka.id
  instance_type = "t2.micro"
  subnet_id = var.private_subnet_id
  key_name = var.key_name
  security_groups = [
    var.kafka_sg_id,
    var.ec2-eci_sg_id
    ]
  
  tags = {
    Name = "kafka-broker-${count.index}"
  }
}