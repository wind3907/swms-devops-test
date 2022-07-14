properties(
    [
        buildDiscarder(logRotator(numToKeepStr: '20')),
        parameters(
            [
                string(name: 'TARGET_DB', description: 'The rf-host-service branch to be built and included', defaultValue: 'lx076trn',  trim: true),
                string(name: 'SOURCE_DB', description: 'The rf-host-service branch to be built and included', defaultValue: 'rs048e',  trim: true),
            ]
        )
    ]
)
pipeline {
    agent { label 'master' }
    environment {
        SSH_KEY = credentials('/swms/jenkins/swms-universal-build/svc_swmsci_000/key')
        TARGET_DB = "${params.TARGET_DB}"
    }
    stages {
        stage("Production Version") {
            steps {
                echo "Section: Production Version"
                script {
                    sh '''
                    scp -i $SSH_KEY ${WORKSPACE}/rds_configurations.sh ${SSH_KEY_USR}@rs1060b1.na.sysco.net:/tempfs
                    '''
                    sh '''
                        ssh -i $SSH_KEY ${SSH_KEY_USR}@$rs1060b1.na.sysco.net "
                        beoracle_ci /tempfs/rds_configurations.sh
                        "
                    ''' 
                }
            }
        }
        stage("Test Env") {
            steps {
                echo "Section: Test Env"
                script {
                    echo "$WINDY"
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

