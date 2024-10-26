# Spring Boot and React Application Deployment with Jenkins, Ansible, and Terraform

## Overview

This project provides an automated deployment setup for a Spring Boot application with a React frontend. It utilizes **Jenkins** for continuous integration and continuous deployment (CI/CD), **Ansible** for configuration management, and **Terraform** for infrastructure provisioning. This setup ensures a smooth and efficient deployment process on a target server.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Usage](#usage)
- [Jenkins Integration](#jenkins-integration)
- [Terraform Setup](#terraform-setup)
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

   Update the Ansible inventory file to include your target server's IP address or hostname. This file is typically located at `inventory/hosts`.

   ```ini
   [all]
   your_server_ip_or_hostname
   ```

2. **PostgreSQL Configuration**

   The playbook includes tasks to create a PostgreSQL database and user. You can modify the database name and user credentials in the `deploy.yml` file.

3. **Terraform Configuration**

   Create a `main.tf` file in the root of your project to define your infrastructure. Here’s a basic example for provisioning an EC2 instance on AWS:

   ```hcl
   provider "aws" {
     region = "us-west-2"
   }

   resource "aws_instance" "app_server" {
     ami           = "ami-0c55b159cbfafe1f0" # Replace with your desired AMI
     instance_type = "t2.micro"

     tags = {
       Name = "SpringBootReactApp"
     }
   }
   ```

   Adjust the AMI and instance type as necessary for your needs.

## Deployment

To deploy the application, run the following commands from the root of the project directory:

1. **Provision Infrastructure with Terraform**

   ```bash
   terraform init
   terraform apply
   ```

   This command will provision the necessary infrastructure as defined in your `main.tf` file.

2. **Run the Ansible Playbook**

   After provisioning, run the Ansible playbook to deploy the application:

   ```bash
   ansible-playbook -i inventory/hosts deploy.yml
   ```

   This command will execute the Ansible playbook, which performs the following tasks:

   - Installs required packages (Java, Nginx, PostgreSQL, etc.).
   - Configures PostgreSQL with a new database and user.
   - Clones the Spring Boot application from GitHub.
   - Runs the Spring Boot application.
   - Unzips the React frontend and configures Nginx.

## Usage

Once the deployment is complete, you can access the application via your web browser at:

```
http://your_server_ip_or_hostname
```

The Spring Boot application will be running in the background, and the React frontend will be served by Nginx.

## Jenkins Integration

To automate the deployment process using Jenkins, follow these steps:

1. **Create a New Jenkins Job**

   - Open Jenkins and create a new Freestyle project.
   - In the "Source Code Management" section, select "Git" and provide the repository URL.

2. **Add Build Steps**

   - Add a build step to execute a shell command to run Terraform and Ansible:

   ```bash
   cd /path/to/your/project
   terraform init
   terraform apply -auto-approve
   ansible-playbook -i inventory/hosts deploy.yml
   ```

3. **Configure Triggers**

   - Set up triggers to run the job on code changes or at scheduled intervals.

## Terraform Setup

To manage your infrastructure as code, ensure you have the following:

- **Terraform CLI**: Install Terraform on your local machine or CI/CD server.
- **AWS Credentials**: Configure your AWS credentials to allow Terraform to provision resources.

You can run the following command to verify your Terraform installation:

```bash
terraform version
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

