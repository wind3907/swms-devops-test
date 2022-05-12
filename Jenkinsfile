pipeline {
    agent { label 'master' }
    stages {
        stage('Stage 1') {
            steps {
                echo "Stage 1 - Identifier"
                sh "echo 'Hi 1'" 
            }
        }
        stage('Stage 2') {
            steps {
                echo "Stage 1 - Identifier"
                sh "echo 'Hi 2'" 
            }
        }
        stage('Stage 3') {
            steps {
                echo "Stage 1 - Identifier"
                sh "echo 'Hi 3'"
                sh 'ls'
                echo "This is workspace"
                echo $WORKSPACE
            }
        }
    }
    post {
        always {
            script {
                logParser projectRulePath: "${WORKSPACE}/swms-devops-test/log_parse_rules" , useProjectRule: true
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
