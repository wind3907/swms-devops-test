properties(
    [
        buildDiscarder(logRotator(numToKeepStr: '20')),
        parameters(
            [
                string(name: 'SOURCE_DB', defaultValue: 'rsxxxe', description: 'Source Database. eg: rs040e'),
                string(name: 'TARGET_DB', defaultValue: 'rds_trn_xxx', description: 'Target Database. eg: rds_trn_040'),
                string(name: 'ROOT_PW', defaultValue: 'SwmsRoot123', description: 'Root Password'),
                string(name: 'TARGET_SERVER', defaultValue: 'lxxxxtrn', description: 'Host ec2 instance. eg: lx036trn'),
                choice(name: 'artifact_s3_bucket', choices: ['swms-build-artifacts', 'swms-build-dev-artifacts'], description: 'The build\'s targeted platform'),
                choice(name: 'platform', choices: ['linux','aix_11g_11g', 'aix_19c_12c'], description: 'The build\'s targeted platform'),
                string(name: 'artifact_version', defaultValue: '50_0', description: 'The swms version to deploy', trim: true),
                [
                            name: 'artifact_name',
                            description: 'The name of the artifact to deploy',
                            $class: 'CascadeChoiceParameter',
                            choiceType: 'PT_SINGLE_SELECT',
                            filterLength: 1,
                            filterable: false,
                            randomName: 'choice-parameter-artifact_name',
                            referencedParameters: 'artifact_s3_bucket, platform, artifact_version',
                            script: [
                                $class: 'GroovyScript',
                                script: [classpath: [], sandbox: false, script: '''\
                                        if (platform?.trim() && artifact_version?.trim()) {
                                            def process = "aws s3api list-objects --bucket ${artifact_s3_bucket} --prefix ${platform}-${artifact_version} --query Contents[].Key".execute()
                                            return process.text.replaceAll('"', "").replaceAll("\\n","").replaceAll(" ","").tokenize(',[]')
                                        } else {
                                            return []
                                        }
                                    '''.stripIndent()
                                ]
                            ]
                        ],
                string(name: 'dba_masterfile_names', description: 'The name of the artifact to deploy', defaultValue: 'R50_0_dba_master.sql', trim: true),
                string(name: 'master_file_retry_count', description: 'Amount of attempts to apply the master file. This is setup to handle circular dependencies by running the same master file multiple times.', defaultValue: '3', trim: true),
                separator(name: "test", sectionHeader: "Data Migration Parameters", separatorStyle: "border-color: orange;", separatorHeaderStyle: "font-weight: bold; line-height: 1.5em; font-size: 1.5em;")
            ]
        )
    ]
)
pipeline {
    agent { label 'master' }
    environment {
        SSH_KEY = credentials('/swms/jenkins/swms-universal-build/svc_swmsci_000/key')
        S3_ACCESS_ARN="arn:aws:iam::546397704060:role/ec2_s3_role";
        AWS_ROLE_SESSION_NAME="swms-data-migration";
        RDS_INSTANCE="${params.TARGET_SERVER}-db"
    }
    stages {
        stage('Verifying parameters') {
            steps {
                echo "Section: Verifying parameters"
                echo "test ${params.SOURCE_DB}"
            }
        }
        // stage('Create AWS RDS snapshot') {
        //     steps {
        //         echo "Section: Create AWS RDS snapshot"
        //         script{
        //             sh(
        //                 script: '''
        //                     set +x
        //                     aws_creds="$(aws sts assume-role --role-arn "${S3_ACCESS_ARN}" \
        //                                             --role-session-name "${AWS_ROLE_SESSION_NAME}" \
        //                                             --duration-seconds 900 | jq --raw-output '.Credentials')"
        //                     export AWS_ACCESS_KEY_ID="$(echo $aws_creds | jq --raw-output '.AccessKeyId')";
        //                     export AWS_SECRET_ACCESS_KEY="$(echo $aws_creds | jq --raw-output '.SecretAccessKey')";
        //                     export AWS_SESSION_TOKEN="$(echo $aws_creds | jq --raw-output '.SessionToken')";   
        //                     export DATE_TIME=$(date +'%m-%d-%Y-%H-%M')
        //                     export SNAPSHOT_NAME="before-data-migration-$DATE_TIME"
        //                     aws rds create-db-snapshot \
        //                         --db-instance-identifier $RDS_INSTANCE \
        //                         --db-snapshot-identifier $SNAPSHOT_NAME
        //                     aws rds wait db-snapshot-available \
        //                         --db-instance-identifier $RDS_INSTANCE \
        //                         --db-snapshot-identifier $SNAPSHOT_NAME
        //                 '''.stripIndent(),
        //                 returnStatus: true)
        //         }
        //     }
        // }
        stage('Cleaning Older RDS snapshot') {
            steps {
                echo "Section: Cleaning Older RDS snapshot"
                // return process.text
                script{
                    sh(script: '''
                        export DATE_TIME=$(date +'%m-%d-%Y-%H-%M')
                        export SNAPSHOT_NAME="before-data-migration-$DATE_TIME"
                    ''',
                    returnStdout: true)
                    def process = "aws s3 cp --quiet s3://swms-data-migration/${TARGET_SERVER}/snapshot.version /dev/stdout".execute()
                    echo "Output: ${process.text}"
                    // current_snapshot_version = sh(
                    //     script: "aws s3 cp --quiet s3://swms-data-migration/${TARGET_SERVER}/snapshot.version /dev/stdout".stripIndent(),
                    //     returnStatus: true)
                    // echo "Output: ${current_snapshot_version}"
                }
            }
        }
        stage('Test name') {
            steps {
                echo "Section: Test name"
                script{
                    sh(script: '''
                        echo "data: $DATE_TIME"
                    ''')
                }
            }
        }
        // stage('Verifying parameters') {
        //     steps {
        //         echo "Section: Verifying parameters"
        //         sh """
        //             echo "Source DB: ${params.SOURCE_DB}"
        //             echo "Target DB: ${params.TARGET_DB}"
        //             if [ "`echo ${params.SOURCE_DB} | cut -c6`" = "e" ]; then
        //             echo Good This is E box ${params.SOURCE_DB}
        //             else
        //             echo Error: Please use rsxxxe
        //             exit
        //             fi 
        //         """
        //     }
        // }
        // stage('Copying Scripts') {
        //     when {
        //         expression { 
        //             params.SOURCE_DB.getAt(5) == 'e' && params.TARGET_DB.substring(0,2) == 'lx' && params.TARGET_DB.substring(5,8) == 'trn' 
        //         }
        //     }
        //     steps {
        //         echo "Section: Copying Scripts"
        //         sh '${WORKSPACE}/scripts/copying_scripts.sh'
        //     }
        // }
        // stage('Restore 11g db') {
        //     steps {
        //         echo "Section: Restore 11g db,prepare db export and get db export"
        //         sh """
        //             ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
        //             . ~/.profile;
        //             beoracle_ci /tempfs/11gtords/restore11g.sh ${params.SOURCE_DB} ${params.TARGET_DB} ${params.ROOT_PW} '/tempfs/DBBackup/SWMS/swm1_db_${params.SOURCE_DB}*.tar.gz'
        //             "
        //         """
        //     }
        // }
        // stage('Prepare db export to RDS') {
        //     steps {
        //         echo "Section: Restore 11g db,prepare db export and get db export"
        //         sh """
        //             ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
        //             . ~/.profile;
        //             beoracle_ci /tempfs/11gtords/prepare_export2rds.sh
        //             "
        //         """
        //     }
        // }
        // stage('Start db export to RDS') {
        //     steps {
        //         echo "Section: Restore 11g db,prepare db export and get db export"
        //         sh """
        //             ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
        //             . ~/.profile;
        //             beoracle_ci /tempfs/11gtords/start_export2rds.sh
        //             "
        //         """
        //     }
        // }
        // stage('Prepare db import to RDS') {
        //     steps {
        //         echo "Section: Prepare db import to RDS"
        //         sh """
        //             ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
        //             . ~/.profile;
        //             beoracle_ci /tempfs/11gtords/prepare_import2rds.sh ${params.SOURCE_DB} ${params.TARGET_DB} ${params.ROOT_PW} '/tempfs/DBBackup/SWMS/swm1_db_${params.SOURCE_DB}*.tar.gz'
        //             "
        //         """
        //     }
        // }
        // stage('Start db import to RDS') {
        //     steps {
        //         echo "Section: Start db import to RDS"
        //         catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') {
        //             sh """
        //                 ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
        //                 . ~/.profile;
        //                 beoracle_ci /tempfs/11gtords/start_import2rds.sh ${params.SOURCE_DB} ${params.TARGET_DB} ${params.ROOT_PW} '/tempfs/DBBackup/SWMS/swm1_db_${params.SOURCE_DB}*.tar.gz'
        //                 "
        //             """
        //         }
        //     }
        // }
        // stage('Verify') {
        //     steps {
        //         echo "Section: Verify"
        //         sh """
        //             ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
        //             . ~/.profile;
        //             beoracle_ci /tempfs/11gtords/verify.sh ${params.SOURCE_DB} ${params.TARGET_DB} ${params.ROOT_PW} '/tempfs/DBBackup/SWMS/swm1_db_${params.SOURCE_DB}*.tar.gz'
        //             "
        //         """
        //     }
        // }
        // stage('Execute 45 Script') {
        //     steps {
        //         echo "Section: Execute 45 Script"
        //         sh """
        //             scp -i $SSH_KEY ${WORKSPACE}/scripts/all_target_45_2.sh ${SSH_KEY_USR}@${params.TARGET_SERVER}.swms-np.us-east-1.aws.sysco.net:/tempfs/
        //         """
        //         timeout(time: 3, unit: 'MINUTES') {
        //             sh """
        //                 ssh -i $SSH_KEY ${SSH_KEY_USR}@${params.TARGET_SERVER}.swms-np.us-east-1.aws.sysco.net "
        //                 /ts/curr/bin/beswms_ci cp /tempfs/all_target_45_2.sh /swms/curr/schemas/;
        //                 /ts/curr/bin/beswms_ci /swms/curr/schemas/all_target_45_2.sh swms swms;
        //                 "
        //             """
        //         }       
        //     }
        // }
        // stage("Trigger deployment") {
        //     steps {
        //         script {
        //             try {
        //                 build job: "${DEPLOY_PIPELINE_NAME}", parameters: [
        //                     string(name: 'target_server_name', value: "${params.TARGET_SERVER}.swms-np.us-east-1.aws.sysco.net"),
        //                     string(name: 'artifact_s3_bucket', value: "${params.S3_BUCKET_NAME}"),
        //                     string(name: 'platform', value: "${params.PLATFORM}"),
        //                     string(name: 'artifact_version', value: "${params.SWMS_VERSION}"),
        //                     string(name: 'artifact_name', value: "${params.S3_ARTIFACT_NAME}"),
        //                     string(name: 'dba_masterfile_names', value: "${params.PRIV_MASTER_SCRIPT_FILES}"),
        //                     string(name: 'master_file_retry_count', value: "${params.MASTER_FILE_RETRY_COUNT}")
        //                 ]
        //                 env.DEPLOY_STATUS = "SUCCESSFUL"
        //             } catch (e) {
        //                 env.DEPLOY_STATUS = "FAILED"
        //                 throw e
        //             }
        //         }
        //     }
        // }
        // stage('RDS Configurations') {
        //     steps {
        //         echo "Section: RDS Configurations"
        //         dir("swms-opco")
        //         {
        //             git branch: 'develop',
        //             credentialsId: scm.getUserRemoteConfigs()[0].getCredentialsId(),
        //             url: 'git@github.com:SyscoCorporation/swms-opco.git'
        //         }
        //         sh 'scp -i $SSH_KEY ${WORKSPACE}/swms-opco/configuration/rds/queues/* ${SSH_KEY_USR}@rs1060b1.na.sysco.net:/home2/dba/jcx/11gtords/rdsconfig/'
        //         sh """
        //             ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
        //             . ~/.profile;
        //             beoracle_ci /tempfs/11gtords/rds_configurations.sh ${params.SOURCE_DB} ${params.TARGET_DB} ${params.ROOT_PW} '/tempfs/DBBackup/SWMS/swm1_db_${params.SOURCE_DB}*.tar.gz'
        //             "
        //         """           
        //     }
        // }
        // stage('Reset Hash Password') {
        //     steps {
        //         echo "Section: Reset Hash Password"
        //         sh """
        //             ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
        //             . ~/.profile;
        //             beoracle_ci /tempfs/11gtords/reset_hashpw.sh ${params.SOURCE_DB} ${params.TARGET_DB} ${params.ROOT_PW} '/tempfs/DBBackup/SWMS/swm1_db_${params.SOURCE_DB}*.tar.gz'
        //             "
        //         """           
        //     }
        // }
        // stage('Alter USER SWMS') {
        //     steps {
        //         echo "Section: Alter USER SWMS"
        //         sh """
        //             ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
        //             . ~/.profile;
        //             beoracle_ci /tempfs/11gtords/alter_user.sh ${params.SOURCE_DB} ${params.TARGET_DB} ${params.ROOT_PW} '/tempfs/DBBackup/SWMS/swm1_db_${params.SOURCE_DB}*.tar.gz'
        //             "
        //         """
        //     }
        // }
        // stage('Reset network ACLs on RDS') {
        //     steps {
        //         echo "Section: Reset network ACLs on RDS"
        //         script {
        //             def HOST_IP = sh(script: "dig +short ${params.TARGET_SERVER}.swms-np.us-east-1.aws.sysco.net | head -n 1", returnStdout: true)                   
        //             sh """
        //                 ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
        //                 . ~/.profile;
        //                 beoracle_ci /tempfs/11gtords/reset_network_acls.sh ${params.SOURCE_DB} ${params.TARGET_DB} ${params.ROOT_PW} '/tempfs/DBBackup/SWMS/swm1_db_${params.SOURCE_DB}*.tar.gz' ${HOST_IP}
        //                 "
        //             """
        //         }
        //     }
        // }
        // stage('Update sys_config') {
        //     steps {
        //         echo "Section: Update sys_config"
        //         sh """
        //             ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
        //             . ~/.profile;
        //             beoracle_ci /tempfs/11gtords/update_sysconfig.sh ${params.SOURCE_DB} ${params.TARGET_DB} ${params.ROOT_PW} '/tempfs/DBBackup/SWMS/swm1_db_${params.SOURCE_DB}*.tar.gz'
        //             "
        //         """
        //     }
        // }
    }
    post {
        // always {
        //     script {
        //         logParser projectRulePath: "${WORKSPACE}/log_parse_rules" , useProjectRule: true
        //         sh """
        //             ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
        //             . ~/.profile;
        //             beoracle_ci rm -r /tempfs/11gtords/
        //             "
        //         """
        //     }
        // }
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
