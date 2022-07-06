
def helloworld = fileLoader.fromGit('snapshot.version', 
        'https://github.com/wind3907/swms-devops-test.git', 'main', null, '')

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
                    sh "cat $helloworld" 
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

