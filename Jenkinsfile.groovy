pipeline {
    agent { label 'terraform-slave' }
    environment {
        SSH_KEY = credentials('/swms/jenkins/swms-universal-build/svc_swmsci_000/key')
        S3_ACCESS_ARN="arn:aws:iam::546397704060:role/ec2_s3_role";
        AWS_ROLE_SESSION_NAME="swms-data-migration";
        RDS_INSTANCE="${params.TARGET_SERVER}-db"
        S3_BUCKET="swms-jenkins-chef-ci"
    }
    stages {
        stage('Checkout SCM') {
            steps {
                cleanWs()
                checkout scm
                echo "Building ${env.JOB_NAME}..."
            }
        }
        stage('Copy Chef Resources to S3') {
            steps {
                script{
                    chef_state = sh(script: ''' aws s3 cp s3://swms-infra-deployment/env:/lx739q17/terraform.tfstate - | jq '.resources | .[] | select(.name=="cheff_state") | .instances | .[] | .attributes.content' ''',returnStdout: true)
                    echo "${chef_state}"
                }
            }
        }
    }
    post {
        success {
            script {
                echo 'Data migration from Oracle 11 AIX to Oracle 19 RDS is successful!'
            }
        }
        failure {
            script {
                echo 'Data migration from Oracle 11 AIX to Oracle 19 RDS is failed!'
            }
        }
    }
}

