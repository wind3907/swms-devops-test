pipeline {
    agent { label 'master' }
    parameters {
        string(name: 'TARGET_DB', defaultValue: 'lx076trn', description: 'TARGET DB')
    }
    environment {
        SSH_KEY = credentials('/swms/jenkins/swms-universal-build/svc_swmsci_000/key')
        // ROOT_PW = credentials("/swms/deployment_automation/nonprod/oracle/master_creds/${params.TARGET_DB}")
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
                    env.ROOT_PW = sh(script: """ aws secretsmanager get-secret-value --secret-id '/swms/deployment_automation/nonprod/oracle/master_creds/${params.TARGET_DB}' """,returnStdout: true)
                }
            }
        }
        stage('Print') {
            steps {
                script{
                    echo "$ROOT_PW"
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

