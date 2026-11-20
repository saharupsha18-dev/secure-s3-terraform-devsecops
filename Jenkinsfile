
pipeline {
    agent any

    environment {
        TF_VAR_s3_endpoint = 'http://floci:4566'

        TF_VAR_dev_bucket  = 'secure-s3-project-dev-202611'
        TF_VAR_test_bucket = 'secure-s3-project-test-202611'
        TF_VAR_prod_bucket = 'secure-s3-project-prod-202611'

        TF_VAR_dev_versioning  = 'true'
        TF_VAR_test_versioning = 'true'
        TF_VAR_prod_versioning = 'true'

        TF_VAR_dev_secure_transport  = 'false'
        TF_VAR_test_secure_transport = 'false'
        TF_VAR_prod_secure_transport = 'false'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Format Check') {
            steps {
                sh 'terraform fmt -check -recursive'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init -backend-config=backend-jenkins.hcl -input=false'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -input=false'
            }
        }

        stage('Checkov Security Scan') {
            steps {
                sh '/var/jenkins_home/checkov-venv/bin/checkov -d . --soft-fail'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully.'
        }

        failure {
            echo 'Pipeline failed. Check the stage logs.'
        }
    }
}
