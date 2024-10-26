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
        stage('Terraform Init & Apply') {
            steps {
                script {
                    // Pass instance_type and ami_id as parameters
                    sh 'terraform init'
                    sh "terraform apply -auto-approve -var \"instance_type=${params.INSTANCE_TYPE}\" -var \"ami_id=${params.AMI_ID}\""
                    sh 'terraform output instance_ip > instance_ip.txt'
                }
            }
        }

        stage('Ansible Provisioning') {
            steps {
                script {
                    sh 'cat instance_ip.txt'
                    sh 'sudo sh inventory.sh'
                    ansiblePlaybook(
                        playbook: 'playbook.yml',
                        inventory: 'hosts.ini'
                    )
                }
            }
        }
    }
}
