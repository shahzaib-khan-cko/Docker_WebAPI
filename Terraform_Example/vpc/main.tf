# # data "aws_region" "current" {
  
# # }

provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

data "aws_availability_zones" "aws-az" {
  state = "available"
}

resource "aws_vpc" "aws-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "pki-containers"
  }
}

resource "aws_subnet" "public_a" {
  cidr_block              = "10.0.0.0/24"
  availability_zone       = data.aws_availability_zones.aws-az.names[0]
  vpc_id                  = aws_vpc.aws-vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "pki-containers-public_a"
  }
  depends_on = [
    aws_vpc.aws-vpc
  ]
}

resource "aws_subnet" "public_b" {
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.aws-az.names[1]
  vpc_id                  = aws_vpc.aws-vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "pki-containers-public_b"
  }
  depends_on = [
    aws_vpc.aws-vpc
  ]
}

resource "aws_subnet" "private_a" {
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.aws-az.names[0]
  vpc_id            = aws_vpc.aws-vpc.id
  map_public_ip_on_launch = false
  tags = {
    Name = "pki-containers-private_a"
  }
  depends_on = [
    aws_vpc.aws-vpc
  ]
}

resource "aws_subnet" "private_b" {
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.aws-az.names[1]
  vpc_id            = aws_vpc.aws-vpc.id
  map_public_ip_on_launch = false
  tags = {
    Name = "pki-containers-private_b"
  }
  depends_on = [
    aws_vpc.aws-vpc
  ]
}

resource "aws_internet_gateway" "aws-igw" {
  vpc_id = aws_vpc.aws-vpc.id
  tags = {
    Name = "pki-containers-igw"
  }

  depends_on = [
    aws_vpc.aws-vpc
  ]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.aws-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws-igw.id
  }
}

resource "aws_route_table_association" "public-a-subnet-to-IG" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-b-subnet-to-IG" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.aws-vpc.id

  # route {
  #   cidr_block     = "0.0.0.0/0"
  #   nat_gateway_id = aws_nat_gateway.gateway.id
  # }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_main_route_table_association" "default" {
  route_table_id = aws_route_table.public.id
  vpc_id         = aws_vpc.aws-vpc.id
}

# resource "aws_eip" "gateway" {
#   vpc        = true
#   depends_on = [aws_internet_gateway.aws-igw]
#   tags = {
#     Name = "pki-containers-NAT"
#   }
# }

# resource "aws_nat_gateway" "gateway" {
#   subnet_id     = aws_subnet.public.id
#   allocation_id = aws_eip.gateway.id
#   tags = {
#     Name = "pki-containers-NAT"
#   }
#   depends_on = [
#     aws_subnet.public,
#     aws_subnet.private,
#     aws_eip.gateway
#   ]
# }

resource "aws_security_group" "alb" {
  name        = "example-task-security-group"
  vpc_id = aws_vpc.aws-vpc.id

  ingress {
    cidr_blocks = ["82.21.179.40/32"]
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_vpc.aws-vpc
  ]
}

resource "aws_alb" "alb" {
  name            = "alb"
  security_groups = ["${aws_security_group.alb.id}"]

  subnets = ["${aws_subnet.public_a.id}", "${aws_subnet.public_b.id}"]
}

resource "aws_alb_target_group" "alb-target-group" {
  health_check {
    matcher = "200,301,302"
    path = "/weatherforecast"
  }

  name     = "alb-target-group"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"

  stickiness {
    type = "lb_cookie"
  }

  vpc_id = aws_vpc.aws-vpc.id
}

resource "aws_alb_listener" "alb_listener" {
  default_action {
    target_group_arn = aws_alb_target_group.alb-target-group.arn
    type             = "forward"
  }

  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"
}
