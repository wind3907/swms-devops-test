pipeline {
    agent { label 'master' }
    stages {
        stage('Checkout SCM') {
            steps {
                cleanWs()
                checkout scm
                echo "Building ${env.JOB_NAME}..."
            }
        } 
    }
    post {
        success {
            script {
                env.TEST="Example varibale"
                env.OPCO="lx036trn"
                env.EMAIL = sh(script: "grep lx036trn $WORKSPACE/email_recipients.txt | awk '{print $2}'",returnStdout: true).trim()  
                echo "$EMAIL"
                // echo 'Data migration from Oracle 11 AIX to Oracle 19 RDS is successful!'
                // emailext body: 'Project: $PROJECT_NAME <br/>Build # $BUILD_NUMBER <br/>Status: $BUILD_STATUS <br/>TEST ENV: ${ENV,var="TEST"} <br/>Check console output at $BUILD_URL to view the results.',
                //     mimeType: 'text/html',
                //     subject: "[SWMS-OPCO-DEPLOYMENT] - ${currentBuild.fullDisplayName}",
                //     to: '${ENV,var="EMAIL"}'
            }
        }
        failure {
            script {
                echo 'Data migration from Oracle 11 AIX to Oracle 19 RDS is failed!'
            }
        }
    }
}

