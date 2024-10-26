pipeline {
    agent any

    parameters {
        string(name: 'INSTANCE_TYPE', defaultValue: 't3.micro', description: 'Type of EC2 instance')
        string(name: 'AMI_ID', defaultValue: 'ami-0dee22c13ea7a9a67', description: 'AMI ID for the EC2 instance')
    }

    environment {
        AWS_CREDENTIALS = credentials('aws-credentials')
    }

    stages {
        stage('Terraform Init') {
            steps {
                script {
                    sh 'terraform init'
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                script {
                    // Use the parameters for instance type and AMI ID
                    sh "terraform apply -auto-approve -var instance_type=${params.INSTANCE_TYPE} -var ami_id=${params.AMI_ID}"
                }
            }
        }
        stage('Get Public IP') {
            steps {
                script {
                    // Capture the public IP output from Terraform
                    def publicIp = sh(script: "terraform output -raw instance_ip", returnStdout: true).trim()
                    env.INSTANCE_PUBLIC_IP = publicIp
                }
            }
        }
        stage('Ansible Deploy') {
            steps {
                // Update the inventory file with the public IP
                script {
                    sh "echo '[app_servers]' > inventory"
                    sh "echo '${env.INSTANCE_PUBLIC_IP} ansible_ssh_user=ubuntu ansible_ssh_private_key_file=/var/lib/jenkins/.ssh/devops-practices.pem' >> inventory"
                    sh 'ansible-playbook -i inventory test_play.yml'
                }
            }
        }
    }
}
