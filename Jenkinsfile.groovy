properties(
    [
        buildDiscarder(logRotator(numToKeepStr: '20')),
        parameters(
            [
                string(name: 'TARGET_DB', description: 'The rf-host-service branch to be built and included', defaultValue: 'lx076trn',  trim: true),
                string(name: 'SOURCE_DB', description: 'The rf-host-service branch to be built and included', defaultValue: 'rs048e',  trim: true),
                string(name: 'ROOT_PW', defaultValue: '', description: 'Root Password'),
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
        stage("Get Production Version") {
            environment {
                ORACLE_DBA_USR_SECRET_PATH = "/swms/deployment_automation/nonprod/oracle/master_creds/${TARGET_DB}"
            }
            steps {
                echo "Section: Get Production Version"
                script {
                    if ("${params.ROOT_PW}" != "" ){
                        env.ORACLE_DBA_PASSWORD = "${params.ROOT_PW}"
                    }else{
                        withCredentials([usernamePassword(credentialsId: "${ORACLE_DBA_USR_SECRET_PATH}", usernameVariable: 'ORACLE_DBA_USER', passwordVariable: 'ORACLE_DBA_PASSWORD')]) {
                            script {
                                set +x
                                env.ORACLE_DBA_PASSWORD = ORACLE_DBA_PASSWORD
                            }
                        }
                    }
                }
            }
        }
        stage("Test Env") {
            steps {
                echo "Section: Test Env"
                script {
                    echo "${ORACLE_DBA_PASSWORD}"
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

