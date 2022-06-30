pipeline {
    agent { label 'master' }
    parameters {
        string(name: 'TARGET_DB', defaultValue: 'lx076trn', description: 'TARGET DB')
    }
    environment {
        SSH_KEY = credentials('/swms/jenkins/swms-universal-build/svc_swmsci_000/key')
        ROOT_PW = credentials("/swms/deployment_automation/nonprod/oracle/master_creds/${params.TARGET_DB}")
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
                    sh """
                        ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net ". ~/.profile; beoracle_ci mkdir -p /tempfs/swms-devops-test"
                        scp -i $SSH_KEY ${WORKSPACE}/verify.sh ${SSH_KEY_USR}@rs1060b1.na.sysco.net:/tempfs/swms-devops-test/
                    """
                    sh '''
                        ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
                        . ~/.profile; 
                        /tempfs/swms-devops-test/verify.sh '${params.TARGETDB}' '$ROOTPW'
                        "
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

