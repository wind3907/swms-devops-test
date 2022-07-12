pipeline {
    agent { label 'master' }
    stages {
        stage('SCM') {
            steps {
                dir("rf-host-service")
                {
                    git branch: 'develop',
                    credentialsId: scm.getUserRemoteConfigs()[0].getCredentialsId(),
                    url: 'git@github.com:SyscoCorporation/swms-opco.git'
                }
                sh 'ls'
                sh 'ls rf-host-service'
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
