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
                    env.ROOT_PW = sh(script: '''aws secretsmanager get-secret-value --secret-id '/swms/deployment_automation/nonprod/oracle/master_creds/${params.TARGET_DB}' | jq --raw-output '.SecretString' ''',returnStdout: true).trim()
                }
            }
        }
        stage('Alter USER SWMS') {
            steps {
                echo "Section: Alter USER SWMS"
                sh """
                    ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net ". ~/.profile; beoracle_ci mkdir -p /tempfs/terraform"
                    scp -i $SSH_KEY ${WORKSPACE}/alter_user.sh ${SSH_KEY_USR}@rs1060b1.na.sysco.net:/tempfs/terraform/
                """
                sh '''
                    ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
                    . ~/.profile;
                    beoracle_ci /tempfs/terraform/alter_user.sh 'lx076trn' "$ROOT_PW"
                    "
                '''
            }
        }
        // stage('Print') {
        //     steps {
        //         script{
        //             echo "$ROOT_PW"
        //             sh """
        //                 ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net ". ~/.profile; beoracle_ci mkdir -p /tempfs/terraform"
        //                 scp -i $SSH_KEY ${WORKSPACE}/verify.sh ${SSH_KEY_USR}@rs1060b1.na.sysco.net:/tempfs/terraform/
        //             """
        //             sh '''
        //                 ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
        //                 . ~/.profile; 
        //                 /tempfs/terraform/verify.sh '${TARGET_DB}' "$ROOT_PW"
        //                 "
        //             '''
        //         }
        //     }
        // }
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

