pipeline {
    agent { label 'master' }
    stages {
        stage('Stage 1') {
            steps {
                echo "INFO Section: 1"
                sh "echo 'Hi 1'" 
            }
        }
        stage('Stage 2') {
            steps {
                echo "TEST: Section: 2"
                sh "echo 'Hi 2'" 
            }
        }
        stage('Stage 3') {
            steps {
                echo "TEST :Section: 3"
                sh "echo 'Hi 3'"
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
                echo 'Data backup restoration is successful!'
            }
        }
        failure {
            script {
                echo 'Data backup restoration is failed!'
            }
        }
    }
}
