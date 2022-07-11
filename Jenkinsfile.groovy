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
                sh 'scp -i $SSH_KEY ${WORKSPACE}/tnsnames_config.sh ${SSH_KEY_USR}@lx239wl.swms-np.us-east-1.aws.sysco.net:/tempfs'
                sh '''
                    ssh -i $SSH_KEY ${SSH_KEY_USR}@lx239wl.swms-np.us-east-1.aws.sysco.net "
                    . ~/.profile;
                    chmod 777 /tempfs/tnsnames_config.sh
                    export PATH="/ts/curr/bin/:$PATH"
                    beoracle_ci /tempfs/tnsnames_config.sh '${TARGET_DB}'
                    "
                '''
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

