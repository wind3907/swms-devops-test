pipeline {
    agent { label 'master' }
    parameters {
        string(name: 'SOURCE_DB', defaultValue: 'rsxxxe', description: 'Source Database. eg: rs040e')
        string(name: 'TARGET_DB', defaultValue: 'rds_trn_xxx', description: 'Target Database. eg: rds_trn_040')
        string(name: 'ROOT_PW', defaultValue: 'SwmsRoot1234', description: 'Root Password')
        string(name: 'HOST', defaultValue: 'lxxxxtrn', description: 'Host ec2 instance. eg: lx036trn')
    }
    environment {
        SSH_KEY = credentials('/swms/jenkins/swms-universal-build/svc_swmsci_000/key')
        ORACLE_KEY = credentials("/swms/deployment_automation/nonprod/oracle/master_creds/${params['HOST']}")   
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
                """
            }
        }
        stage('Copying Scripts') {
            when {
                expression { 
                    params.SOURCE_DB.getAt(5) == 'e' && params.TARGET_DB.substring(0,2) == 'lx' && params.TARGET_DB.substring(5,8) == 'trn' 
                }
            }
            steps {
                echo "Section: Copying Scripts"
                sh '${WORKSPACE}/scripts/copying_scripts.sh'
            }
        }
        // stage('Execute 45 Script') {
        //     steps {
        //         echo "Section: Execute 45 Script"
        //         sh """
        //             scp -i $SSH_KEY ${WORKSPACE}/scripts/all_target_45_2.sh ${SSH_KEY_USR}@${params.HOST}.swms-np.us-east-1.aws.sysco.net:/tempfs/
        //         """
        //         sh """
        //             ssh -i $SSH_KEY ${SSH_KEY_USR}@${params.HOST}.swms-np.us-east-1.aws.sysco.net "
        //             /ts/curr/bin/beswms_ci cp -r /tempfs/all_target_45_2.sh /swms/curr/schemas/;
        //             /ts/curr/bin/beswms_ci /swms/curr/schemas/all_target_45_2.sh ${ORACLE_KEY_USR} ${ORACLE_KEY};
        //             "
        //         """           
        //     }
        // }
        stage('RDS Configurations') {
            steps {
                echo "Section: RDS Configurations"
                dir("swms-opco")
                {
                    git branch: 'develop',
                    credentialsId: scm.getUserRemoteConfigs()[0].getCredentialsId(),
                    url: 'git@github.com:SyscoCorporation/swms-opco.git'
                }
                sh 'scp -i $SSH_KEY ${WORKSPACE}/swms-opco/configuration/rds/queues/* ${SSH_KEY_USR}@rs1060b1.na.sysco.net:/home2/dba/jcx/11gtords/rdsconfig/'
                sh """
                    ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
                    . ~/.profile;
                    beoracle_ci /tempfs/11gtords/rds_configurations.sh ${params.SOURCE_DB} ${params.TARGET_DB} ${params.ROOT_PW} '/tempfs/DBBackup/SWMS/swm1_db_${params.SOURCE_DB}*.tar.gz'
                    "
                """           
            }
        }
    }
    post {
        always {
            script {
                sh """
                    ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
                    . ~/.profile;
                    beoracle_ci rm -r /tempfs/11gtords/;
                    "
                """
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
