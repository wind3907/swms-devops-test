pipeline {
    agent { label 'master' }
    environment {
        ROOTPW = credentials('SWMS_Devops_Rootpw')
        SSH_KEY = credentials('/swms/jenkins/swms-universal-build/svc_swmsci_000/key')   
    }
    stages {
        stage('Copying Scripts') {
            steps {
                echo "Section: Copying Scripts"
                sh '${WORKSPACE}/scripts/copying_scripts.sh'
            }
        }
    }
    post {
        always {
            script {
                logParser projectRulePath: "${WORKSPACE}/log_parse_rules" , useProjectRule: true
            }
        }
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
