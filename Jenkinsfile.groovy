properties(
    [
        buildDiscarder(logRotator(numToKeepStr: '20')),
        parameters(
            [
                string(name: 'TARGET_DB', description: 'The rf-host-service branch to be built and included', defaultValue: 'lx036trn',  trim: true),
            ]
        )
    ]
)
pipeline {
    agent { label 'master' }
    options {
        skipDefaultCheckout()
    }
    stages {
        stage('Checkout SCM') {
            steps {
                dir('swms-devops-test') { checkout scm }
            }
        }
        stage('Test'){
            steps {
                script {
                    sh "echo 'This is a test'"
                }
            }
        } 
    }
    post {
        always {
            script {
                env.SOURCE_DB = 'rs048e'
                env.TARGET_DB = 'lx048trn'
                dir("selector-academy") {
                    git branch: "master",
                    credentialsId: '4c5daf94-f77a-4854-8a88-03fae213f59b',
                    url: "https://github.com/SyscoCorporation/selector-academy.git"
                }
                env.EMAIL = sh(script: '''grep $TARGET_DB selector-academy/email_recipients.txt | awk '{ print $2 }' ''',returnStdout: true).trim()
                emailext body: 'Project: $PROJECT_NAME <br/>Build # $BUILD_NUMBER <br/>Status: $BUILD_STATUS <br/>Source Database: $SOURCE_DB <br/>Target Database: $TARGET_DB <br/>Check console output at $BUILD_URL to view the results.',
                    mimeType: 'text/html',
                    subject: "[SWMS-DATA-MIGRATION-AIX-RDS] - ${currentBuild.fullDisplayName}",
                    to: '${ENV,var="EMAIL"}'
                
                withCredentials([string(credentialsId: '/swms/jenkins/swms-data-migration', variable: 'TEAMS_WEBHOOK_URL')]) {
                   sh "echo ${TEAMS_WEBHOOK_URL}"
                }
        }
        success {
            script {
                echo 'Data migration from Oracle 11 AIX to Oracle 19 RDS is Success'
            }
        }
        failure {
            script {
                echo 'Data migration from Oracle 11 AIX to Oracle 19 RDS is failed!'
            }
        }
    }
}

