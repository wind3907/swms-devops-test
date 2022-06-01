pipeline {
    agent { label 'master' }
    environment {
        SSH_KEY = credentials('/swms/jenkins/swms-universal-build/svc_swmsci_000/key')   
    }
    stages {
        stage('Copying Scripts') {
            when {
                expression { 
                    params.SOURCE_DB.getAt(5) == 'e' && params.TARGET_DB.substring(0,7) == 'rds_trn' 
                }
            }
            steps {
                echo "Section: Copying Scripts"
                sh '${WORKSPACE}/scripts/copying_scripts.sh'
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
