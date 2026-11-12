pipeline {
    agent any
    stages {
      stage ('Checkout') {
        steps {
            checkout scm
        }
      }
      stage ('Terraform format check') {
        steps {
            sh 'terraform fmt -check -recursive'
        }
      }
      stage ('Terraform init') {
        steps {
            sh 'terraform init -backend-config=backend-jenkins.hcl -input=false'
        }
      }
      stage ('Terraform Validate') {
        steps {
            sh 'terraform validate'
        }
      }
      stage ('Checkov Security Scan') {
        steps {
            sh '/var/jenkins_home/checkov-venv/bin/checkov -d .'
        }
      }
    }  
}