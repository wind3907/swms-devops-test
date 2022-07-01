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
        stage('Testing EC2 Connection') {
            steps {
                echo "Testing EC2 Connection"
                
                script{
                    env.TARGET_DB = "lx07trn"
                    env.HOST_IP = sh(script: '''dig +short $TARGET_DB.swms-np.us-east-1.aws.sysco.net | head -n 1''', returnStdout: true) .trim()                   
                    if (HOST_IP != ''){
                        echo "EC2 Instance is successfully created"
                    }else{
                        echo "EC2 Instance provisioning failed"
                        currentBuild.result = "FAILURE"
                        sh "exit 1"       
                    }
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

