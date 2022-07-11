pipeline {
    agent { label 'master' }
    environment {
        SSH_KEY = credentials('/swms/jenkins/swms-universal-build/svc_swmsci_000/key')
    }
    stages {
        stage("PMC Configuration") {
            steps {
                echo "Section: PMC Configuration"
                script {
                    env.INSTANCE = "lx222trn"
                    env.INSTANCE_DB = "lx222trn-db"
                    def INSTANCE_ID = sh(script: "aws ec2 describe-instances --filters 'Name=tag:Name,Values=$INSTANCE' --query Reservations[*].Instances[*].[InstanceId] --output text --region us-east-1", returnStdout: true).trim()
                    def INSTANCE_DB_ARN = sh(script: "aws rds describe-db-instances --db-instance-identifier $INSTANCE_DB --region us-east-1", returnStdout: true).trim()
                    sh "echo $INSTANCE_DB_ARN"
                }
            }
        }
    }
    post {
        success {
            script {
                echo 'Data migration from Oracle 11 AIX to Oracle 19 RDS is Success'
            }
        }
        failure {
            script {
                echo 'Data migration from Oracle 11 AIX to Oracle 19 RDS is failed!'
            }
        }
    }
}

