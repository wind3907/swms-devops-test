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
            }
        }
    }
    post {
        always {
            script {
                dir("selector-academy") {
                    git branch: "master",
                    credentialsId: '4c5daf94-f77a-4854-8a88-03fae213f59b',
                    url: "https://github.com/wind3907/swms-devops-test.git"
                }

                def now = new Date()
                def DATE = now.format("yyyy-MM-dd HH:mm", TimeZone.getTimeZone('UTC'))
                def props = readProperties  file: "${WORKSPACE}/email.properties"
                if (currentBuild.result == 'SUCCESS'){
                    env.SUBJECT = props['subject_successfull']
                }else{
                    env.SUBJECT = props['subject_failed']
                }
                def BODY = props['body']
                def MIMETYPE = props['mimeType']
                def EMAIL = 'wimukthibw@gmail.com,wind3907@sysco.com'
                def OPCO = sh(script: 'echo $TARGET_DB | cut -c3-5',returnStdout: true)
                emailext body: "$BODY",
                    mimeType: "$MIMETYPE",
                    subject: "$SUBJECT for $OPCO at $DATE UTC",
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

