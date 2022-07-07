@NonCPS
def loadProperties() {
	checkout scm
	File propertiesFile = new File('${workspace}/email_recipients.txt')
	sh "cat propertiesFile"
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
                    sh "echo 'hi'"
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

