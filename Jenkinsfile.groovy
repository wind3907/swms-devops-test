pipeline {
    agent { label 'master' }
    stages {
        stage('1') {
            steps {
                sh 'exit 0'
            }
        }
        stage('2') {
            steps {
                script{
                    catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') {
                        sh "exit 1"
                    }
                }
            }
        }
        stage('3') {
            steps {
                sh 'exit 0'
            }
        }
    }
    post {
        success {
            script {
                echo 'Data migration from Oracle 11 AIX to Oracle 19 RDS is successful!'
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

