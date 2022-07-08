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
                // sh "scp -i $SSH_KEY ${WORKSPACE}/tnsnames.sh ${SSH_KEY_USR}@rs1060b1.na.sysco.net:/tempfs"
                // sh '''
                //     ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
                //     . ~/.profile;
                //     /tempfs/tnsnames.sh
                //     "
                // '''
            }
        }
    }
    post {
        success {
            script {
                echo 'Data migration from Oracle 11 AIX to Oracle 19 RDS is Success'
                def props = readProperties  file: "${WORKSPACE}/email.properties"
                env.SUBJECT = props['subject']
                env.MIMETYPE = props['mimeType']
                env.EMAIL = 'wind3907@sysco.com'
                env.OPCO = '036'
                echo 'SUBJECT: ${ENV,var="SUBJECT"}'
                echo "MIMETYPE: $MIMETYPE"
                emailext body: 'Project: $PROJECT_NAME <br/>Build # $BUILD_NUMBER <br/>Status: $BUILD_STATUS <br/>Target Database: $TARGET_DB <br/>Check console output at $BUILD_URL to view the results.',
                    mimeType: "$MIMETYPE",
                    subject: "$SUBJECT $OPCO",
                    to: "$EMAIL"
            }
        }
        failure {
            script {
                echo 'Data migration from Oracle 11 AIX to Oracle 19 RDS is failed!'
            }
        }
    }
}

