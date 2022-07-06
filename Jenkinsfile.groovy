dir("selector-academy") {
    git branch: "master",
    credentialsId: scm.getUserRemoteConfigs()[0].getCredentialsId(),
    url: "https://github.com/SyscoCorporation/selector-academy.git"
}
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
                    sh "cat selector-academy/email_recipients.txt"
                }
            }
        } 
    }
    post {
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

