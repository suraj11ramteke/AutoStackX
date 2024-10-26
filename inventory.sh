#!/bin/bash

# Get the public IP from the Terraform output
INSTANCE_IP=$(cat instance_ip.txt)

# Create the Ansible inventory file
cat <<EOL > hosts.ini
[all]
$INSTANCE_IP ansible_ssh_user=ubuntu ansible_ssh_private_key_file=/path/to/your/private/key.pem
EOL