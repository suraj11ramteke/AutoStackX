# Spring Boot and React Application Deployment with Jenkins, Ansible, and Terraform

## Overview

This project provides an automated deployment setup for a Spring Boot application with a React frontend. It utilizes **Jenkins** for continuous integration and continuous deployment (CI/CD), **Ansible** for configuration management, and **Terraform** for infrastructure provisioning. This setup ensures a smooth and efficient deployment process on an AWS EC2 instance.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Usage](#usage)
- [Jenkins Integration](#jenkins-integration)
- [Terraform Setup](#terraform-setup)
- [Ansible Playbook](#ansible-playbook)
- [Nginx Configuration](#nginx-configuration)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before you begin, ensure you have met the following requirements:

- A server running Ubuntu 20.04 or later.
- Ansible installed on your local machine or CI/CD server.
- Terraform installed on your local machine or CI/CD server.
- Jenkins installed and configured on your CI/CD server.
- SSH access to the target server.
- PostgreSQL installed on the target server.
- Java 17 installed on the target server.

## Installation

1. **Clone the Repository**

   Clone this repository to your local machine:

   ```bash
   git clone https://github.com/namdeopawar/Simple-SpringBoot-ReactApp.git
   cd Simple-SpringBoot-ReactApp
   ```

2. **Install Required Packages**

   Ensure that the required packages are installed on your target server. The Ansible playbook will handle this automatically.

## Configuration

1. **Ansible Inventory**

   Update the Ansible inventory file to include your target server's IP address or hostname. This file is typically generated dynamically during the Jenkins pipeline execution.

2. **Terraform Configuration**

   Update the `main.tf` file to define your infrastructure. The default configuration provisions an EC2 instance with a security group allowing SSH, HTTP, and application traffic.

   ```hcl
   provider "aws" {
     region = "ap-south-1"
   }

   variable "instance_type" {
     description = "Type of EC2 instance"
     default     = "t2.medium"
   }

   variable "ami_id" {
     description = "AMI ID for the EC2 instance"
     default     = "ami-0dee22c13ea7a9a67"  // Default Ubuntu 20.04 Image
   }

   variable "key_name" {
     description = "Key name for the EC2 instance"
     default     = "devops-practices"
   }

   resource "aws_instance" "web" {
     ami           = var.ami_id
     instance_type = var.instance_type
     key_name      = var.key_name
     security_groups = [aws_security_group.web_sg.name]

     tags = {
       Name = "SpringBootReactApp"
     }
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

   output "instance_ip" {
     value = aws_instance.web.public_ip
   }
   ```

## Deployment

To deploy the application, follow these steps:

1. **Run the Jenkins Pipeline**

   The Jenkins pipeline defined in the `Jenkinsfile` automates the entire deployment process. It performs the following stages:

   - **Terraform Init**: Initializes Terraform.
   - **Terraform Apply**: Provisions the EC2 instance using the specified AMI and instance type.
   - **Get Public IP**: Captures the public IP of the newly created instance.
   - **Wait for SSH**: Waits until the instance is reachable via SSH.
   - **Ansible Deploy**: Runs the Ansible playbook to configure the server and deploy the application.

   You can trigger the Jenkins job manually or set it to run automatically on code changes.

## Usage

Once the deployment is complete, you can access the application via your web browser at:

```
http://your_instance_public_ip
```

The Spring Boot application will be running in the background, and the React frontend will be served by Nginx.

## Jenkins Integration

To automate the deployment process using Jenkins, ensure you have the following:

1. **Create a New Jenkins Job**

   - Open Jenkins and create a new Freestyle project.
   - In the "Source Code Management" section, select "Git" and provide the repository URL.

2. **Add Build Steps**

   - Add a build step to execute a shell command to run Terraform and Ansible:

   ```bash
   cd /path/to/your/project
   terraform init
   terraform apply -auto-approve -var instance_type=${params.INSTANCE_TYPE} -var ami_id=${params.AMI_ID}
   ansible-playbook -i inventory deploy.yml
   ```

3. **Configure Triggers**

   - Set up triggers to run the job on code changes or at scheduled intervals.

## Ansible Playbook

The Ansible playbook (`playbook.yml`) automates the configuration of the server and deployment of the application. Key tasks include:

- Installing required packages (Java, Nginx, PostgreSQL, etc.).
- Cloning the Spring Boot application from GitHub.
- Configuring PostgreSQL with a new database and user.
- Starting the Spring Boot backend and building the React frontend.
- Configuring Nginx to serve the React application and proxy requests to the Spring Boot backend.

## Nginx Configuration

The Nginx configuration is templated using Jinja2 (`nginx.conf.j2`). It sets up the server to listen on port 80 and serves the React application while proxying API requests to the Spring Boot backend.

```nginx
server {
    listen 80;
    server_name {{ ansible_host }};  # Use the EC2 public IP

    location / {
        root /var/www/html/build;  # Path to your React build files
        index index.html index.htm;
        try_files $uri $uri/ /index.html;  # Redirect all requests to index.html
    }

    location /api/ {
        proxy_pass http://localhost:8080;  # Change this to your Spring Boot backend URL
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Troubleshooting

- **PostgreSQL Errors**: If you encounter issues with PostgreSQL, check the logs located at `/var/log/postgresql/`.
- **Nginx Configuration**: If Nginx fails to start, run `nginx -t` to test the configuration for errors.
- **Service Status**: Check the status of services using the following commands:

  ```bash
  sudo systemctl status postgresql
  sudo systemctl status nginx
  ```

- **Terraform Issues**: If you face issues with Terraform, check the output logs for errors and ensure your AWS credentials are correctly configured.

