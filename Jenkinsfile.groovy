pipeline {
    agent { label 'master' }
    environment {
        ROOTPW = credentials('SWMS_Devops_Rootpw')
        SSH_KEY = credentials('/swms/jenkins/swms-universal-build/svc_swmsci_000/key')   
    }
    parameters {
        string(name: 'SOURCE_DB', defaultValue: 'rsxxxe', description: 'Source Database. eg: rs040e')
        string(name: 'TARGET_DB', defaultValue: 'rds_trn_xxx', description: 'Target Database. eg: rds_trn_040')
    }
    stages {
        stage('Verifying parameters') {
            steps {
                echo "Section: Verifying parameters"
                sh """
                    echo "Source DB: ${params.SOURCE_DB}"
                    echo "Target DB: ${params.TARGET_DB}"
                    if [ "`echo ${params.SOURCE_DB} | cut -c6`" = "e" ]; then
                    echo Good This is E box ${params.SOURCE_DB}
                    else
                    echo Error: Please use rsxxxe
                    exit
                    fi 
                    if [ "`echo ${params.TARGET_DB} | cut -c1-7`" = "rds_trn" ]; then
                    echo Good This is RDS db server ${params.TARGET_DB}
                    else
                    echo Error: Please use rds_trn_xxx
                    exit
                    fi
                """
            }
        }
        stage('Copying Scripts') {
            when {
                expression { 
                    params.SOURCE_DB.getAt(5) == 'e' && params.TARGET_DB.substring(0,7) == 'rds_trn' 
                }
            }
            steps {
                echo "Section: Verify"
                sh 'scp -i $SSH_KEY ${WORKSPACE}/verify.sh ${SSH_KEY_USR}@rs1060b1.na.sysco.net:/tempfs'
            }
        }
        stage('Verify') {
            when {
                expression { 
                    params.SOURCE_DB.getAt(5) == 'e' && params.TARGET_DB.substring(0,7) == 'rds_trn' 
                }
            }
            steps {
                echo "Section: Verify"
                sh """
                    ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
                    . ~/.profile;
                    beoracle_ci ${WORKSPACE}/verify.sh ${params.SOURCE_DB} ${params.TARGET_DB}
                    "
                """
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
                echo 'Data migration from Oracle 11 AIX to Oracle 19 RDS is successful!'
            }
        }
        failure {
            script {
                echo 'Data migration from Oracle 11 AIX to Oracle 19 RDS is failed!'
            }
        }
    }
}
