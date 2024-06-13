#configure aws instance
resource "aws_instance" "instance" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet1.id
  key_name                    = aws_key_pair.tf-key.key_name
  associate_public_ip_address = true
  security_groups             = [aws_security_group.allow_ssh.id]

  root_block_device {
    volume_size = 40  # Size in GB
  }

  lifecycle {
    ignore_changes = [security_groups]
  }

  user_data = templatefile("${path.module}/jenkins.sh", {})

}

# resource "aws_ebs_volume" "ec2-volume" {
#   availability_zone = data.aws_availability_zones.available.names[0]
#   size              = 40

#   tags = {
#     Name = "Jenkins-instance-volume"
#   }
# }

# resource "aws_volume_attachment" "ebs_att" {
#   device_name = "/dev/sdh"
#   volume_id   = aws_ebs_volume.ec2-volume.id
#   instance_id = aws_instance.instance.id
# }

#configure aws key pair
resource "aws_key_pair" "tf-key" {
  key_name   = "tf-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

# generate private key
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#create local file to store private key
resource "local_file" "foo" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tf.key"
}

#configure route table
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route"
  }
}

#configure route table assocations
resource "aws_route_table_association" "public_subnet_asso" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public.id
}
