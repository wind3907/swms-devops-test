properties(
    [
        buildDiscarder(logRotator(numToKeepStr: '20')),
        parameters(
            [
                string(name: 'TARGET_DB', description: 'The rf-host-service branch to be built and included', defaultValue: 'lx048trn',  trim: true),
                string(name: 'SOURCE_DB', description: 'The rf-host-service branch to be built and included', defaultValue: 'rs048e',  trim: true),
            ]
        )
    ]
)
pipeline {
    agent { label 'master' }
    environment {
        SSH_KEY = credentials('/swms/jenkins/swms-universal-build/svc_swmsci_000/key')
        TARGET_DB =  "${params.TARGET_DB}"
    }
    stages {
        stage('Tnsnames Configuration') {
            steps {
                echo "Section: Tnsnames Configuration"
                sh 'exit 1'
            }
        }
    }
    post {
        always {
            script {
                def props = readProperties  file: "${WORKSPACE}/email.properties"
                if (currentBuild.result == 'SUCCESS'){
                    def SUBJECT = props['subject_successfull']
                }else{
                    def SUBJECT = props['subject_failed']
                }
                def BODY = props['body']
                def MIMETYPE = props['mimeType']
                def EMAIL = 'wind3907@sysco.com'
                def OPCO = sh(script: 'echo $TARGET_DB | cut -c3-5',returnStdout: true)
                emailext body: "$BODY",
                    mimeType: "$MIMETYPE",
                    subject: "$SUBJECT $OPCO",
                    to: "$EMAIL"
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

