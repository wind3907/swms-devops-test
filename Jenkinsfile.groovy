pipeline {
    agent { label 'master' }
    environment {
        SSH_KEY = credentials('/swms/jenkins/swms-universal-build/svc_swmsci_000/key')   
    }
    parameters {
        string(name: 'SOURCE_DB', defaultValue: 'rsxxxe', description: 'Source Database. eg: rs040e')
        string(name: 'TARGET_DB', defaultValue: 'rds_trn_xxx', description: 'Target Database. eg: rds_trn_040')
        string(name: 'ROOT_PW', defaultValue: 'SwmsRoot1234', description: 'Root Password')
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
                echo "Section: Copying Scripts"
                sh '${WORKSPACE}/scripts/copying_scripts.sh'
            }
        }
        stage('Restore 11g db') {
            when {
                expression { 
                    params.SOURCE_DB.getAt(5) == 'e' && params.TARGET_DB.substring(0,7) == 'rds_trn' 
                }
            }
            steps {
                echo "Section: Restore 11g db,prepare db export and get db export"
                sh """
                    ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
                    . ~/.profile;
                    beoracle_ci /tempfs/11gtords/restore11g.sh ${params.SOURCE_DB} ${params.TARGET_DB} ${params.ROOT_PW} '/tempfs/DBBackup/SWMS/swm1_db_${params.SOURCE_DB}*.tar.gz'
                    "
                """
            }
        }
        stage('Prepare db export to RDS') {
            when {
                expression { 
                    params.SOURCE_DB.getAt(5) == 'e' && params.TARGET_DB.substring(0,7) == 'rds_trn' 
                }
            }
            steps {
                echo "Section: Restore 11g db,prepare db export and get db export"
                sh """
                    ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
                    . ~/.profile;
                    beoracle_ci /tempfs/11gtords/prepare_export2rds.sh
                    "
                """
            }
        }
        stage('Start db export to RDS') {
            when {
                expression { 
                    params.SOURCE_DB.getAt(5) == 'e' && params.TARGET_DB.substring(0,7) == 'rds_trn' 
                }
            }
            steps {
                echo "Section: Restore 11g db,prepare db export and get db export"
                sh """
                    ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
                    . ~/.profile;
                    beoracle_ci /tempfs/11gtords/start_export2rds.sh
                    "
                """
            }
        }
        stage('Prepare db import to RDS') {
            when {
                expression { 
                    params.SOURCE_DB.getAt(5) == 'e' && params.TARGET_DB.substring(0,7) == 'rds_trn' 
                }
            }
            steps {
                echo "Section: Prepare db import to RDS"
                sh """
                    ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
                    . ~/.profile;
                    beoracle_ci /tempfs/11gtords/prepare_import2rds.sh ${params.SOURCE_DB} ${params.TARGET_DB} ${params.ROOT_PW} '/tempfs/DBBackup/SWMS/swm1_db_${params.SOURCE_DB}*.tar.gz'
                    "
                """
            }
        }
        stage('Start db import to RDS') {
            when {
                expression { 
                    params.SOURCE_DB.getAt(5) == 'e' && params.TARGET_DB.substring(0,7) == 'rds_trn' 
                }
            }
            steps {
                echo "Section: Start db import to RDS"
                catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') {
                    sh """
                        ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
                        . ~/.profile;
                        beoracle_ci /tempfs/11gtords/startrdsimp.sh ${params.SOURCE_DB} ${params.TARGET_DB} ${params.ROOT_PW} '/tempfs/DBBackup/SWMS/swm1_db_${params.SOURCE_DB}*.tar.gz'
                        "
                    """
                }
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
                    beoracle_ci /tempfs/11gtords/verify.sh ${params.SOURCE_DB} ${params.TARGET_DB} ${params.ROOT_PW} '/tempfs/DBBackup/SWMS/swm1_db_${params.SOURCE_DB}*.tar.gz'
                    "
                """
            }
        }
    }
    post {
        always {
            script {
                logParser projectRulePath: "${WORKSPACE}/log_parse_rules" , useProjectRule: true
                // sh """
                //     ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
                //     . ~/.profile;
                //     beoracle_ci rm -r /tempfs/11gtords/
                //     "
                // """
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
