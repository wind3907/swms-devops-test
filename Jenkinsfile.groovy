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
                    env.CHEF_STATE = sh(script: ''' aws s3 cp s3://swms-infra-deployment/env:/lx739q17/terraform.tfstate - | jq '.resources | .[] | select(.name=="cheff_state") | .instances | .[] | .attributes.content' ''',returnStdout: true).trim()
                    sh (script: '''echo -e $CHEF_STATE | tr '"' "\n" > "${WORKSPACE}/dev-client-rhel-7.yml"''')
                    sh '''
                    aws s3api put-object --bucket swms-jenkins-chef-ci --key chef_state_files/lx739q17/dev-client-rhel-7.yml --body "${WORKSPACE}/dev-client-rhel-7.yml"
                    '''
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

