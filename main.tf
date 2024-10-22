provider "aws" {
  region = "us-east-1"
}

variable "instance_type" {
  description = "Type of EC2 instance"
  default     = "t3.micro"
}

resource "aws_instance" "web" {
  ami           = "ami-0866a3c8686eaeeba"  # Ubuntu 24.04 Image
  instance_type = var.instance_type

  tags = {
    Name = "SpringBootReactApp"
  }

  key_name      = "devops-practices"
  security_groups = [aws_security_group.web_sg.name]
}

resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
