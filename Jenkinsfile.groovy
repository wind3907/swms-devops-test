properties(
    [
        buildDiscarder(logRotator(numToKeepStr: '20')),
        parameters(
            [
                string(name: 'TARGET_DB', description: 'The rf-host-service branch to be built and included', defaultValue: 'lx048trn',  trim: true),
                string(name: 'SOURCE_DB', description: 'The rf-host-service branch to be built and included', defaultValue: 'rs048e',  trim: true),
            ]
        )
    ]
)
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
                    def INSTANCE_DB_ARN = sh(script: "aws rds describe-db-instances --db-instance-identifier $INSTANCE_DB --query DBInstances[*].[DBInstanceArn] --output text --region us-east-1", returnStdout: true).trim()
                    sh "aws ec2 create-tags --resources ${INSTANCE_ID} --tags Key='Automation:PMC',Value='Always On' --region us-east-1"
                    sh "aws rds add-tags-to-resource --resource-name ${INSTANCE_DB_ARN} --tags Key='Automation:PMC',Value='Always On' --region us-east-1"
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

