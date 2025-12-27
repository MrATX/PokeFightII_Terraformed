# Local variable for user IP address
locals {
  my_ip_cidr = "${chomp(data.http.my_ip.response_body)}/32"
}

# --------------------------------------------------------------------
# Create a Security Group and Ingress/Egress Rules
# --------------------------------------------------------------------

resource "aws_security_group" "pf2SecurityGroup" {
  name        = "PokeFightII_SecurityGroup"
  description = "Allow access to 5000 from user IP only"
  region      = var.aws_region

  tags = merge(
    var.tags,
    {
      Name = "PokeFightII_SecurityGroup"
    }
  )
}

# Create an Ingress rule only allowing local IP to access port 5000
resource "aws_vpc_security_group_ingress_rule" "pf2SGIngress5000" {
  region            = var.aws_region
  security_group_id = aws_security_group.pf2SecurityGroup.id
  cidr_ipv4         = local.my_ip_cidr
  from_port         = 5000
  ip_protocol       = "tcp"
  to_port           = 5000
}

# Create an Egress rule allowing all outbound traffic
resource "aws_vpc_security_group_egress_rule" "pf2SGEgressOpen" {
  region            = var.aws_region
  security_group_id = aws_security_group.pf2SecurityGroup.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# --------------------------------------------------------------------
# Create EC2 instance connected to the security group created above
# --------------------------------------------------------------------

resource "aws_instance" "pf2instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  region                 = var.aws_region
  vpc_security_group_ids = [aws_security_group.pf2SecurityGroup.id]

  associate_public_ip_address = var.associate_public_ip

  user_data = file("install_pokefight2.sh")

  tags = merge(
    var.tags,
    {
      Name = "PokeFightII_Instance"
    }
  )
}