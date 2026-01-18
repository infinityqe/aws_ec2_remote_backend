##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region = var.aws_region
}

##################################################################################
# DATA
##################################################################################

data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
resource "aws_vpc" "app" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  tags                 = merge(local.common_tags, { Name = lower("${local.prefix}-vpc") })
}

resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id
  tags   = merge(local.common_tags, { Name = lower("${local.prefix}-igw") })
}

resource "aws_subnet" "public_subnet1" {
  cidr_block              = var.vpc_subnet_cidr
  vpc_id                  = aws_vpc.app.id
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags                    = merge(local.common_tags, { Name = lower("${local.prefix}-public-subnet1") })
}

# ROUTING #
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.app.id
  tags   = merge(local.common_tags, { Name = lower("${local.prefix}-rt") })
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app.id
  }
}

resource "aws_route_table_association" "app_subnet1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.app.id
}

# SECURITY GROUPS #
# Nginx security group 
resource "aws_security_group" "nginx_sg" {
  name   = "nginx_sg"
  vpc_id = aws_vpc.app.id
  tags   = merge(local.common_tags, { Name = lower("${local.prefix}-nginx-sg") })

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# INSTANCES #
resource "aws_instance" "nginx1" {
  ami                         = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.public_subnet1.id
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  user_data_replace_on_change = true
  tags                        = merge(local.common_tags, { Name = "${local.prefix}-nginx1" })

  user_data = templatefile("./templates/startup_script.tpl", { environment = var.environment })

}
