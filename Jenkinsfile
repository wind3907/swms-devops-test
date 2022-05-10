pipeline {
    agent any
    environment {
        SSH_KEY = credentials("${params['/swms/jenkins/swms-universal-build/svc_swmsci_000/key']}")
        BUILD_SERVER = 'rs1060b1'
    }
    stages {
        stage('Verifying parameters') {
            steps {
                echo "Section: Setting up SWMS working directory"
            }
        }
    }
    post {
        success {
            script {
               echo "Section: Setting up SWMS working directory"
            }
        }
    }
}
