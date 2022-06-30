pipeline {
    agent { label 'master' }
    parameters {
        string(name: 'TARGET_DB', defaultValue: 'lx076trn', description: 'TARGET DB')
        string(name: 'ROOT_PW', defaultValue: 'lx076trn', description: 'TARGET DB')
    }
    environment {
        SSH_KEY = credentials('/swms/jenkins/swms-universal-build/svc_swmsci_000/key')
        TARGET_DB = "${params.TARGET_DB}"
        TARGET_DB_ALIAS = "${params.TARGET_DB}_db"
        SOURCE_DB = "rs048e"
        AIX_DB_BK = "/tempfs/DBBackup/SWMS/swm1_db_*.tar.gz"
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
                    if ("${params.ROOT_PW}" != "" ){
                        env.ROOT_PW = "${params.ROOT_PW}"
                    }else{
                        env.ROOT_PW = sh(script: '''aws secretsmanager get-secret-value --secret-id /swms/deployment_automation/nonprod/oracle/master_creds/$TARGET_DB | jq --raw-output '.SecretString' ''',returnStdout: true).trim()
                    }
                }
            }
        }
        stage('Reset network ACLs on RDS') {
            steps {
                echo "Section: Reset network ACLs on RDS"
                script {
                    env.HOST_IP = sh(script: '''dig +short $TARGET_DB.swms-np.us-east-1.aws.sysco.net | head -n 1''', returnStdout: true) .trim()                  
                    
                    sh """
                        ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net ". ~/.profile; beoracle_ci mkdir -p /tempfs/terraform"
                        scp -i $SSH_KEY ${WORKSPACE}/reset_network_acls.sh ${SSH_KEY_USR}@rs1060b1.na.sysco.net:/tempfs/terraform/
                    """
                    sh '''
                        ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
                        . ~/.profile;
                        beoracle_ci /tempfs/terraform/reset_network_acls.sh '${SOURCE_DB}' '${TARGET_DB_ALIAS}' '${ROOT_PW}' '${HOST_IP}' '${AIX_DB_BK}'
                        "
                    '''
                }
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

