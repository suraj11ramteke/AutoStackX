pipeline {
    agent any

    environment {
        AWS_CREDENTIALS = credentials('aws-credentials')
    }

    stages {
        stage('Terraform Init & Apply') {
            steps {
                script {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Ansible Provisioning') {
            steps {
                script {
                    ansiblePlaybook(
                        playbook: 'playbook.yml',
                        inventory: 'hosts.ini'
                    )
                }
            }
        }
    }
}
