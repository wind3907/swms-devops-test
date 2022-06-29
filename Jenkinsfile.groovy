pipeline {
    agent { label 'master' }
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
        stage('Testing RDS Connection') {
            steps {
                echo "Testing RDS Connection"
                script{
                    env.TARGETDB = "lx739q17"
                    env.ROOTPW = sh(script: '''aws secretsmanager get-secret-value --secret-id /swms/deployment_automation/nonprod/oracle/master_creds/$TARGETDB --region us-east-1 | jq --raw-output '.SecretString' ''',returnStdout: true).trim()
                    
                    sh """
                        ssh -i $SSH_KEY ${SSH_KEY_USR}@lx739q17.swms-np.us-east-1.aws.sysco.net
                    """
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

