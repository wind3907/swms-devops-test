pipeline {
    agent { label 'master' }
    parameters {
        string(name: 'TARGET_DB', defaultValue: 'lx076trn', description: 'TARGET DB')
        string(name: 'ROOT_PW', defaultValue: '', description: 'TARGET DB')
    }
    environment {
        SSH_KEY = credentials('/swms/jenkins/swms-universal-build/svc_swmsci_000/key')
    }
    stages {
        stage('Checkout SCM') {
            steps {
                cleanWs()
                checkout scm
                echo "Building ${env.JOB_NAME}..."
            }
        }
        stage('Prepare db export to RDS') {
            steps {
                echo "Section: Prepare db export to RDS"
                sh "scp -i $SSH_KEY ${WORKSPACE}/verify.sh ${SSH_KEY_USR}@rs1060b1.na.sysco.net:/tempfs/11gtords/"
                sh """
                    ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
                    . ~/.profile;
                    beoracle_ci /tempfs/11gtords/verify.sh
                    "
                """
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

