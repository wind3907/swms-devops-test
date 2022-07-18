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
        stage("Get Production Version") {
            environment {
                ORACLE_SWMS_USR_SECRET_PATH = "/swms/deployment_automation/nonprod/oracle/user/swms"
            }
            steps {
                echo "Section: Get Production Version"
                script {
                    withCredentials([usernamePassword(credentialsId: "${ORACLE_SWMS_USR_SECRET_PATH}", usernameVariable: 'ORACLE_SWMS_USER', passwordVariable: 'ORACLE_SWMS_PASSWORD')]) {
                        script {
                            def status = sh(script: '''
                                scp -i $SSH_KEY ${WORKSPACE}/rds_configurations.sh ${SSH_KEY_USR}@${TARGET_DB}.swms-np.us-east-1.aws.sysco.net:/tempfs
                                ssh -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_DB}.swms-np.us-east-1.aws.sysco.net "
                                . /etc/profile;
                                export ORACLE_SWMS_USER="$ORACLE_SWMS_USER";
                                export ORACLE_SWMS_PASSWORD="$ORACLE_SWMS_PASSWORD";
                                beoracle_ci /tempfs/rds_configurations.sh
                                "
                            ''', returnStdout: true).trim() 
                            env.SWMS_VERSION = sh(script: "echo ${status} | grep 'Version Number' | cut -d' ' -f3 ", returnStdout: true).trim()
                        }
                    }
                }
            }
        }
        stage("Test Env") {
            steps {
                echo "Section: Test Env"
                script {
                    echo "$SWMS_VERSION"
                    env.SWMS_VERSION_NUMBER = "${env.SWMS_VERSION.substring(0,env.SWMS_VERSION.length()-2).replaceAll('\\.', '_')}"
                    // env.process = sh (script: "aws s3api list-objects --bucket swms-build-artifacts --prefix linux-${SWMS_VERSION_NUMBER} --query Contents[].Key", returnStdout: true ).trim()
                    def process = "aws s3api list-objects --bucket swms-build-artifacts --prefix linux-${SWMS_VERSION_NUMBER} --query Contents[].Key".execute()
                    env.version = process.text
                    echo "$version"
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

