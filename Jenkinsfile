pipeline {
    agent any

    parameters {
        string(name: 'INSTANCE_TYPE', defaultValue: 't2.medium', description: 'Type of EC2 instance')
        string(name: 'AMI_ID', defaultValue: 'ami-0dee22c13ea7a9a67', description: 'AMI ID for the UbuntuEC2 instance')
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
        stage('Wait for SSH') {
            steps {
                script {
                    // Wait for the instance to be reachable via SSH
                    def maxAttempts = 30
                    def attempt = 0
                    def sshCommand = "ssh -o StrictHostKeyChecking=no -i /var/lib/jenkins/.ssh/devops-practices.pem ubuntu@${env.INSTANCE_PUBLIC_IP} exit"

                    while (attempt < maxAttempts) {
                        try {
                            sh sshCommand
                            echo "SSH is reachable."
                            break
                        } catch (Exception e) {
                            echo "Attempt ${attempt + 1}: SSH not reachable yet. Waiting..."
                            sleep(10) // Wait for 10 seconds before retrying
                            attempt++
                        }
                    }

                    if (attempt == maxAttempts) {
                        error "SSH was not reachable after ${maxAttempts * 10} seconds."
                    }
                }
            }
        }
        stage('Ansible Deploy') {
            steps {
                // Update the inventory file with the public IP
                script {
                    sh "echo '[app_servers]' > inventory"
                    sh "echo '${env.INSTANCE_PUBLIC_IP} ansible_ssh_user=ubuntu ansible_ssh_private_key_file=/var/lib/jenkins/.ssh/devops-practices.pem' >> inventory"
                    sh 'ansible-playbook -i inventory playbook.yml'
                }
            }
        }
    }
}
