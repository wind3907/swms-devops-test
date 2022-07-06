
// def schedule = fileLoader.load('data_migration_schedule.groovy', 
//         'https://github.com/wind3907/swms-devops-test.git', 'main', '4c5daf94-f77a-4854-8a88-03fae213f59b', '')


pipeline {
    agent { label 'master' }
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
        stage('File import check') {
            steps {
                script{
                    def schedule = fileLoader.fromGit('data_migration_schedule', 'https://github.com/wind3907/swms-devops-test.git', 'main', null, '')
                    sh "echo ${schedule.schedule()}"
                }
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

