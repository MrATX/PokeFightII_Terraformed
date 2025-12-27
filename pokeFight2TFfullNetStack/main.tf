# Local variable for user IP address
locals {
  my_ip_cidr = "${chomp(data.http.my_ip.response_body)}/32"
}
# --------------------------------------------------------------------
# Create a VPC
# --------------------------------------------------------------------

resource "aws_vpc" "pf2Vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = "PokeFightII_VPC"
    }
  )
}

# --------------------------------------------------------------------
# Create a Public Subnet in the VPC
# --------------------------------------------------------------------

resource "aws_subnet" "pf2PublicSubnet" {
  vpc_id                  = aws_vpc.pf2Vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "PokeFightII_PublicSubnet"
    }
  )
}

# --------------------------------------------------------------------
# Create an Internet Gateway (IGW) in the VPC
# --------------------------------------------------------------------

resource "aws_internet_gateway" "pf2Igw" {
  vpc_id = aws_vpc.pf2Vpc.id

  tags = merge(
    var.tags,
    {
      Name = "PokeFightII_IGW"
    }
  )
}

# --------------------------------------------------------------------
# Create a Route Table directing outbound traffic to IGW
# --------------------------------------------------------------------

resource "aws_route_table" "pf2RouteTable" {
  vpc_id = aws_vpc.pf2Vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pf2Igw.id
  }

  tags = merge(
    var.tags,
    {
      Name = "PokeFightII_RouteTable"
    }
  )
}

# --------------------------------------------------------------------
# Associate the Subnet to the Route Table
# --------------------------------------------------------------------

resource "aws_route_table_association" "pf2RTassign" {
  subnet_id      = aws_subnet.pf2PublicSubnet.id
  route_table_id = aws_route_table.pf2RouteTable.id
}

# --------------------------------------------------------------------
# Create a Security Group and Ingress/Egress Rules
# --------------------------------------------------------------------

resource "aws_security_group" "pf2SecurityGroup" {
  name        = "PokeFightII_SecurityGroup"
  description = "Allow access to 5000 from user IP only"
  region      = var.aws_region
  vpc_id      = aws_vpc.pf2Vpc.id

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
# Create EC2 instance connected to the networking resources created above
# --------------------------------------------------------------------

resource "aws_instance" "pf2instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  region                 = var.aws_region
  subnet_id              = aws_subnet.pf2PublicSubnet.id
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