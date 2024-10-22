pipeline {
    agent any

    parameters {
        choice(name: 'INSTANCE_TYPE', choices: ['t3.micro', 't3.medium'], description: 'Select the instance type')
    }

    stages {
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Terraform Apply') {
            steps {
                script {
                    // Pass instance type as a parameter
                    def instanceType = params.INSTANCE_TYPE ?: 't3.micro'
                    sh "terraform apply -auto-approve -var 'instance_type=${instanceType}'"
                }
            }
        }
        stage('Get Public IP') {
            steps {
                script {
                    // Capture the public IP output from Terraform
                    def publicIp = sh(script: "terraform output -raw instance_public_ip", returnStdout: true).trim()
                    env.INSTANCE_PUBLIC_IP = publicIp
                }
            }
        }
        stage('Ansible Deploy') {
            steps {
                // Update the inventory file with the public IP
                script {
                    sh "echo '[app_servers]' > inventory"
                    sh "echo '${env.INSTANCE_PUBLIC_IP} ansible_ssh_user=ubuntu' >> inventory"
                    sh 'ansible-playbook -i inventory deploy.yml'
                }
            }
        }
    }
}
