properties(
    [
        buildDiscarder(logRotator(numToKeepStr: '20')),
        parameters(
            [
                string(name: 'target_server_name', description: "The target server to deploy to. If the domain is not 'na.sysco.net' use the full address", defaultValue: ""),
                [
                    name: 'artifact_s3_bucket',
                    description: 'The build\'s targeted platform',
                    $class: 'ChoiceParameter',
                    choiceType: 'PT_SINGLE_SELECT',
                    filterLength: 1,
                    filterable: false,
                    randomName: 'choice-parameter-289390844205293',
                    script: [
                        $class: 'GroovyScript',
                        script: [classpath: [], sandbox: false, script: '''\
                            return [
                                \'swms-build-artifacts\',
                                \'swms-build-dev-artifacts\'
                            ]'''.stripIndent()
                        ]
                    ]
                ],
                [
                    name: 'platform',
                    description: 'The build\'s targeted platform',
                    $class: 'ChoiceParameter',
                    choiceType: 'PT_SINGLE_SELECT',
                    filterLength: 1,
                    filterable: false,
                    randomName: 'choice-parameter-289390844205293',
                    script: [
                        $class: 'GroovyScript',
                        script: [classpath: [], sandbox: false, script: '''\
                            return [
                                \'aix_11g_11g\',
                                \'aix_19c_12c\',
                                \'linux\'
                            ]'''.stripIndent()
                        ]
                    ]
                ],
                string(name: 'artifact_version', description: 'The swms version to deploy', trim: true),
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
                string(name: 'dba_masterfile_names', description: 'Comma seperated names of the Privileged master files to apply to the current database. Will not run if left blank. Ran before the master_file', defaultValue: '', trim: true),
                string(name: 'master_file_retry_count', description: 'Amount of attempts to apply the master file. This is setup to handle circular dependencies by running the same master file multiple times.', defaultValue: '3', trim: true)
            ]
        )
    ]
)
pipeline {
    agent any

    options {
        skipDefaultCheckout()
    }

    environment {
        SSH_KEY = credentials("/swms/jenkins/swms-universal-build/svc_swmsci_000/key")
        TARGET_SERVER = "${params['target_server_name'].split('\\.')[0]}"
        SERVER_DOMAIN = "${(params['target_server_name'].split('\\.').size() > 1) ? params['target_server_name'].split('\\.')[1..-1].join('.') : 'na.sysco.net'}"
        DB_TAR_GZ = "${params['platform']}-${SWMS_VERSION}-db.tar.gz"
        WORKING_DIR = "/tempfs/${JOB_NAME}_${BUILD_NUMBER}"
        DB_LOG_DIR = "${WORKING_DIR}/db_logs"
        SWMS_VERSION = "${params['artifact_version']}"
        AWS_DEFAULT_REGION = "us-east-1"
        RF_Java_app_health_URL = "http://${TARGET_SERVER}.${SERVER_DOMAIN}:8081/actuator/health"
        rust_api_health_url = "http://${TARGET_SERVER}.${SERVER_DOMAIN}:8088/health"
        BASE_DIRECTORY = "/swms/base"
    }

    stages {
        stage('Fetch requirements') {
            steps {
                script {
                    echo "Section: Fetch deployment scripts"
                    dir('scripts') {
                        checkout scm
                    }
                    // Pulling the artifact from S3
                    if (params.artifact_name?.trim()) {
                        sh "aws s3 cp s3://${params.artifact_s3_bucket}/${params.artifact_name} . --no-progress;"
                    } else {
                        error("The artifact_name cannot be empty")
                    }
                    // Extracting the artifact and taking the individual tars
                    sh "tar -xf ${params['artifact_name']}"
                    sh "rm ${params['artifact_name']}"
                    sh "mv ${params['platform']}-${SWMS_VERSION}*/${params['platform']}-${SWMS_VERSION}-db*.tar.gz ${DB_TAR_GZ}"
                    sh "tar -zcf db_deployment.tar.gz scripts ${DB_TAR_GZ}"
                }
            }
        }

        stage ('Setup Working and log directories') {
            steps {
                sh 'ssh -o StrictHostKeyChecking=No -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "mkdir -p ${WORKING_DIR}"'
                sh 'scp -o StrictHostKeyChecking=no -i $-o StrictHostKeyChecking=no _KEY db_deployment.tar.gz ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN}:${WORKING_DIR}'
                sh 'ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "gunzip -d ${WORKING_DIR}/db_deployment.tar.gz"'
                sh 'ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "tar -xf ${WORKING_DIR}/db_deployment.tar -C ${WORKING_DIR}"'
                sh 'ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "chmod -R 754 ${WORKING_DIR}"'

                sh 'ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "mkdir -p ${DB_LOG_DIR}"'
                sh 'ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "mkdir -p /tmp/swms/log"'
                sh 'ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "mkdir -p /tmp/swms/rf_upload"'
            }
        }

        stage('Locking server') {
            options {
                lock("deploy-${params['target_server_name']}");
            }
            stages {
                stage('Shutdown SWMS Application') {
                    when {
                        /* for production servers, we do not stop and start reserve instances. This is determined by the hostname ending with an e */
                        expression { env.TARGET_SERVER.split('').last().toLowerCase() != 'e' }
                    }
                    steps {
                        echo "Section: Shutdown SWMS Application"
                        
                        script {
                            sh '''
                            ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                            . /etc/profile;
                            beswms_ci ${WORKING_DIR}/scripts/bin/change_service_state.sh "stop" "non_prod"
                            "
                            '''
                        }
                        
                    }
                    
                }

                stage('Install SWMS files') {
                    steps {
                        echo "Section: Install SWMS files"
                        sh '''
                            ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                            . /etc/profile;
                            export SWMS_VERSION=${SWMS_VERSION};
                            export SWMS_ARTIFACT_PATH=${WORKING_DIR}/${DB_TAR_GZ};
                            export BASE_DIRECTORY=${BASE_DIRECTORY};
                            beswms_ci ${WORKING_DIR}/scripts/bin/db_install.sh;"
                        '''.stripIndent()
                    }
                }

                stage('AIX 19c setup') {
                    when {
                        expression { params.platform.split('-')[0] == "aix_19c_12c" }
                    }
                    steps {
                        echo "Section: Setup for Oracle 19c"
                        sh '''
                            ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                            . /etc/profile;
                            beswms_ci ${WORKING_DIR}/scripts/bin/aix_19c_setup.sh;"
                        '''.stripIndent()
                    }
                }

                stage('Apply DBA masterfile') {
                    when {
                        expression { params.dba_masterfile_names?.trim() && env.TARGET_SERVER.split('').last() != 'e' }
                    }
                    environment {
                        ORACLE_SWMS_ELEVATED_USR_SECRET_PATH = "/swms/deployment_automation/nonprod/oracle/user/swms_ci_privileged"
                        ORACLE_DBA_USR_SECRET_PATH = "/swms/deployment_automation/nonprod/oracle/master_creds/${TARGET_SERVER}"
                    }
                    steps {
                        withCredentials([usernamePassword(credentialsId: "${ORACLE_SWMS_ELEVATED_USR_SECRET_PATH}", usernameVariable: 'ORACLE_SWMS_USER', passwordVariable: 'ORACLE_SWMS_PASSWORD')]) {
                            script {
                                // Adding the privileged SMMS user to the DB
                                sh "(envsubst < scripts/templates/add_privileged_user.sql) > add_privileged_user.sql"
                                sh "(envsubst < scripts/templates/drop_user_if_exist.sql) > drop_user_if_exist.sql"
                                sh 'scp -o StrictHostKeyChecking=no -i $SSH_KEY add_privileged_user.sql drop_user_if_exist.sql ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN}:${WORKING_DIR}'

                                if (params.platform.split('-')[0] == "linux") {
                                    withCredentials([usernamePassword(credentialsId: "${ORACLE_DBA_USR_SECRET_PATH}", usernameVariable: 'ORACLE_DBA_USER', passwordVariable: 'ORACLE_DBA_PASSWORD')]) {
                                        script {
                                            sh '''
                                                ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                                                . /etc/profile;
                                                export DBA_CONN_STRING="${ORACLE_DBA_USER}/${ORACLE_DBA_PASSWORD}"
                                                ${WORKING_DIR}/scripts/bin/run_sql_dba.sh '${WORKING_DIR}/drop_user_if_exist.sql';
                                                ${WORKING_DIR}/scripts/bin/run_sql_dba.sh '${WORKING_DIR}/add_privileged_user.sql';"
                                            '''.stripIndent()   
                                        }
                                    }
                                } else {
                                    sh '''
                                        ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                                        . /etc/profile;
                                        beoracle_ci ${WORKING_DIR}/scripts/bin/run_sql_dba.sh '${WORKING_DIR}/drop_user_if_exist.sql';
                                        beoracle_ci ${WORKING_DIR}/scripts/bin/run_sql_dba.sh '${WORKING_DIR}/add_privileged_user.sql';"
                                    '''.stripIndent()  
                                }

                                String[] dba_master_files;
                                dba_master_files = params['dba_masterfile_names'].split(',');

                                for( String file : dba_master_files ) {
                                    def dba_file = file.trim();
                                    echo "Section: Applying dba masterfile ${dba_file}"
                                    env.TARGET_DBA_MASTER_FILE = "/swms/curr/schemas/${dba_file}";
                                    env.DBA_MASTER_FILE_LOG_PATH = "${env.DB_LOG_DIR}/${dba_file}.log"

                                    sh '''
                                        ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                                        . /etc/profile;
                                        export LOG_PATH="$DBA_MASTER_FILE_LOG_PATH";
                                        export ORACLE_SWMS_USER="$ORACLE_SWMS_USER";
                                        export ORACLE_SWMS_PASSWORD="$ORACLE_SWMS_PASSWORD";
                                        ${WORKING_DIR}/scripts/bin/run_sql.sh ${TARGET_DBA_MASTER_FILE};"
                                    '''.stripIndent()

                                    echo "Checking sqlplus errors"
                                    sh '''
                                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                                        . /etc/profile;
                                        ${WORKING_DIR}/scripts/bin/check_sqlplus_errors.sh $DBA_MASTER_FILE_LOG_PATH"
                                    '''.stripIndent()
                                }
                                //Remove the created privileged user
                                if (params.platform.split('-')[0] == "linux") {
                                    withCredentials([usernamePassword(credentialsId: "${ORACLE_DBA_USR_SECRET_PATH}", usernameVariable: 'ORACLE_DBA_USER', passwordVariable: 'ORACLE_DBA_PASSWORD')]) {
                                        script {
                                            sh '''
                                                ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                                                . /etc/profile;
                                                export DBA_CONN_STRING="${ORACLE_DBA_USER}/${ORACLE_DBA_PASSWORD}"
                                                ${WORKING_DIR}/scripts/bin/run_sql_dba.sh '${WORKING_DIR}/drop_user_if_exist.sql';"
                                            '''.stripIndent()   
                                        }
                                    }
                                } else {
                                    sh '''
                                        ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                                        . /etc/profile;
                                        beoracle_ci ${WORKING_DIR}/scripts/bin/run_sql_dba.sh '${WORKING_DIR}/drop_user_if_exist.sql';"
                                    '''.stripIndent()  
                                }
                            }
                        }
                    }
                }

                stage('Apply masterfile') {
                    when {
                        expression { env.TARGET_SERVER.split('').last() != 'e' }
                    }
                    environment {
                        ORACLE_SWMS_USR_SECRET_PATH = "/swms/deployment_automation/nonprod/oracle/user/swms"
                        MASTERFILE = "R${SWMS_VERSION}_master.sql"
                        MASTERFILE_PATH  = "/swms/curr/schemas/${MASTERFILE}"
                    }
                    steps {
                        script{
                            withCredentials([usernamePassword(credentialsId: "${ORACLE_SWMS_USR_SECRET_PATH}", usernameVariable: 'ORACLE_SWMS_USER', passwordVariable: 'ORACLE_SWMS_PASSWORD')]) {
                                script {
                                    Integer master_file_run_count = 0;
                                    retry(params.master_file_retry_count.toInteger()) {
                                        try {
                                            master_file_run_count++;
                                            echo "Section: Applying masterfile ${MASTERFILE}, try: ${master_file_run_count}"
                                            env.MASTER_FILE_RUN_COUNT = master_file_run_count;
                                            env.MASTERFILE_LOG_PATH = "${DB_LOG_DIR}/${MASTERFILE}.${MASTER_FILE_RUN_COUNT}.log"
                                            sh '''
                                                ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                                                . /etc/profile;
                                                cd ${WORKING_DIR}/src/;
                                                export LOG_PATH="$MASTERFILE_LOG_PATH";
                                                export ORACLE_SWMS_USER="$ORACLE_SWMS_USER";
                                                export ORACLE_SWMS_PASSWORD="$ORACLE_SWMS_PASSWORD";
                                                ${WORKING_DIR}/scripts/bin/run_sql.sh ${MASTERFILE_PATH};
                                                "
                                            '''.stripIndent()

                                            echo "INFO: Checking sqlplus errors"
                                            sh '''
                                                ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                                                . /etc/profile;
                                                ${WORKING_DIR}/scripts/bin/check_sqlplus_errors.sh ${MASTERFILE_LOG_PATH};"
                                            '''.stripIndent()
                                        } catch (e) {
                                            echo "INFO: Error applying master file."
                                            throw e
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                stage("APCOM Queue Length Modification") {
                    when {
                        expression { params.platform.split('-')[0] != "linux" }
                    }
                    environment {
                        APCOM_SSM_PREFIX = "/swms/deployment_automation/nonprod/apcom"
                    }
                    steps {
                        echo "Section: Apcom configuration"
                        withAWSParameterStore(naming: 'relative', path: "${APCOM_SSM_PREFIX}", regionName: "${AWS_DEFAULT_REGION}") {
                            sh '''
                                ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                                . /etc/profile;
                                export QUEUE_LIST='${QUEUE_NAMES}';
                                export LENGTHS_LIST='${QUEUE_LENGTHS}';
                                beswms_ci ${WORKING_DIR}/scripts/bin/apcom_modify_queue_length.sh;"
                            '''.stripIndent()
                        }
                    }
                }

                stage("Create SymLinks") {
                    steps {
                        echo "Section: Create SymLinks"
                        sh '''
                            ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                            . /etc/profile;
                            beswms_ci ${WORKING_DIR}/scripts/bin/create_sym_links.sh;"
                        '''.stripIndent()
                    }
                }

                stage("Apply TSID File Elevated Permissions Check") {
                    environment {
                        TSID_SSM_PREFIX="/swms/deployment_automation/nonprod/tsid"
                    }
                    steps {
                        echo "Section: Apply TSID Elevated Permissions"
                        withAWSParameterStore(naming: 'relative', path: "${TSID_SSM_PREFIX}", regionName: "${AWS_DEFAULT_REGION}") {
                            sh '''
                                ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                                . /etc/profile;
                                export TSID_FILES='${FILES}';
                                beswms_ci ${WORKING_DIR}/scripts/bin/tsid.sh;"
                            '''.stripIndent()
                        }
                    }
                }

                stage('Startup SWMS Application') {
                    steps {
                        
                        echo "Section: Startup SWMS Application"

                        script {
                            /* for production servers, we do not stop and start reserve instances. This is determined by the hostname ending with an e */
                            if (env.TARGET_SERVER.split('').last().toLowerCase() != 'e'){
                                
                                sh '''
                                    ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                                    . /etc/profile;
                                    beswms_ci ${WORKING_DIR}/scripts/bin/change_service_state.sh "start" "non_prod"
                                    "
                                '''
                            }
                            else{
                                sh '''
                                    ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                                    . /etc/profile;
                                    beswms_ci ${WORKING_DIR}/scripts/bin/change_service_state.sh "start" "prod"
                                    "
                                '''
                            }
                        }
                        
                    }
                }

                stage("RF configuration") {
                    steps {
                        echo "Section: RF configuration"
                        sh '''
                            ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                            . /etc/profile;
                            beswms_ci ${WORKING_DIR}/scripts/bin/rf_setup.sh;"
                        '''.stripIndent()
                    }
                }

                stage("WinCE deployment") {
                    steps {
                        echo "Section: WinCE deployment"
                        sh '''
                            ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                            . /etc/profile;
                            beswms_ci ${WORKING_DIR}/scripts/bin/wince_deploy.sh;"
                        '''.stripIndent()
                    }
                }

                stage("Copy Crontab files") {
                    steps {
                        echo "Section: Copy crontab files"
                        sh '''
                            ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                            . /etc/profile;
                            export BASE_DIRECTORY=${BASE_DIRECTORY};
                            beswms_ci ${WORKING_DIR}/scripts/bin/crontab_copy.sh;"
                        '''.stripIndent()
                    }
                }

                stage("Update version") {
                    when {
                        expression { env.TARGET_SERVER.split('').last() != 'e' }
                    }
                    environment {
                        ORACLE_SWMS_USR_SECRET_PATH = "/swms/deployment_automation/nonprod/oracle/user/swms"
                    }
                    steps {
                        script {
                            echo "Section: Update version"
                            // Converting version to a dot seperated number with atleast 2 decimals
                            env.SWMS_VERSION_NUMBER = "${env.SWMS_VERSION.replaceAll('_', '\\.')}"
                            while((env.SWMS_VERSION_NUMBER.split("\\.", -1).length - 1) < 2) {
                                env.SWMS_VERSION_NUMBER = "${env.SWMS_VERSION_NUMBER}.0"
                            }
                            // Substituting the above version numebr to upd_version.sql
                            sh "(envsubst < scripts/templates/upd_version.sql) > upd_version.sql"

                            sh 'scp -o StrictHostKeyChecking=no -i $SSH_KEY -p upd_version.sql ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN}:${WORKING_DIR}'
                            sh 'ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} ". /etc/profile; beswms_ci cp ${WORKING_DIR}/upd_version.sql /swms/curr/schemas;"'

                            withCredentials([usernamePassword(credentialsId: "${ORACLE_SWMS_USR_SECRET_PATH}", usernameVariable: 'ORACLE_SWMS_USER', passwordVariable: 'ORACLE_SWMS_PASSWORD')]) {
                                script {
                                    sh '''
                                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                                        . /etc/profile;
                                        export LOG_PATH="${DB_LOG_DIR}/upd_version.sql.log";
                                        export ORACLE_SWMS_USER="$ORACLE_SWMS_USER";
                                        export ORACLE_SWMS_PASSWORD="$ORACLE_SWMS_PASSWORD";
                                        ${WORKING_DIR}/scripts/bin/run_sql.sh /swms/curr/schemas/upd_version.sql;"
                                    '''.stripIndent()

                                    echo "INFO: Checking sqlplus errors"
                                    sh '''
                                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                                        . /etc/profile;
                                        ${WORKING_DIR}/scripts/bin/check_sqlplus_errors.sh ${DB_LOG_DIR}/upd_version.sql.log;"
                                    '''.stripIndent()
                                }
                            }
                        }
                    }
                }
                stage ('Health Check: RF Java app') {
                    steps {         
                        script { 
                            sh "chmod +x -R ${env.WORKSPACE}/scripts/bin/health_check_status.sh"
                            echo "***** sleep for 1 min before health check *****"
                            sh 'sleep 60'
                            def status = sh(script: "${env.WORKSPACE}/scripts/bin/health_check_status.sh ${RF_Java_app_health_URL}", returnStdout: true).trim() 
                            echo "${status}"

                            if (status == '') {
                                    echo "Service error when calling ${RF_Java_app_health_URL}"
                                    error("notify error")
                            }else if (status != "up" && status != "UP") {
                                    echo "Service error with status = ${status} when calling ${RF_Java_app_health_URL}"
                                    error("notify error")
                            }
                            else {
                                    echo "Service OK with status: ${status}"
                            }
                        }
                    }
                }
                stage ('Health Check: RUST API') {
                    when {
                        expression { params.platform.split('-')[0] == "linux" }
                    }
                    steps {         
                        script { 
                            def status = sh(script: "${env.WORKSPACE}/scripts/bin/health_check_status.sh ${rust_api_health_url}", returnStdout: true).trim() 
                            echo "${status}"
                            
                            if (status == '') {
                                    echo "Service error when calling ${rust_api_health_url}"
                                    error("notify error")
                            }else if (status != "Healthy" && status != "healthy" ) {
                                    echo "Service error with status = ${status} when calling ${RF_Java_app_health_URL}"
                                    error("notify error")
                            }else {
                                    echo "Service OK with status: ${status}"
                            }
                        }
                    }
                }
                stage ('Version Check: Win CE bundle directory') {
                    steps {         
                        script {
                            WinCE_Directory="${BASE_DIRECTORY}/curr_$SWMS_VERSION" 
                            WinCE_Directory_status = sh(script: "ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} test -d ${WinCE_Directory} && echo '1' || echo '0' ", returnStdout: true).trim()
                            if(WinCE_Directory_status=='1'){
                                echo "INFO: Win CE bundle direcyory exist"
                            } else {
                                echo "ERROR: Win CE bundle direcyory doesn't exist"
                                error("notify error")
                            }
                        }
                    }
                }
                stage("Health & Version Check: Database") {
                    when {
                        expression { env.TARGET_SERVER.split('').last() != 'e' }
                    }
                    environment {
                        ORACLE_SWMS_USR_SECRET_PATH = "/swms/deployment_automation/nonprod/oracle/user/swms"
                    }
                    steps {
                        script {

                            withCredentials([usernamePassword(credentialsId: "${ORACLE_SWMS_USR_SECRET_PATH}", usernameVariable: 'ORACLE_SWMS_USER', passwordVariable: 'ORACLE_SWMS_PASSWORD')]) {
                                script {
                                    sh '''
                                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "
                                        . /etc/profile;
                                        export LOG_PATH="${DB_LOG_DIR}/version_check.sql.log";
                                        export ORACLE_SWMS_USER="$ORACLE_SWMS_USER";
                                        export ORACLE_SWMS_PASSWORD="$ORACLE_SWMS_PASSWORD";
                                        ${WORKING_DIR}/scripts/bin/run_version_check_sql.sh ${SWMS_VERSION_NUMBER};"
                                    '''.stripIndent()
                                }
                            }
                        }
                    }
                }
            }   
                
        }
    }

    post {
        always {
            script {
                echo "Section: Post actions and cleanup"
                sh 'ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${SSH_KEY_USR}@${TARGET_SERVER}.${SERVER_DOMAIN} "rm -rf ${WORKING_DIR}"'
                logParser projectRulePath: "scripts/log_parse_rules" , useProjectRule: true
                deleteDir()
                dir("${WORKSPACE}@tmp") {
                    deleteDir()
                }
                dir("${WORKSPACE}@script") {
                    deleteDir()
                }
                dir("${WORKSPACE}@script@tmp") {
                    deleteDir()
                }

                emailext body: 'Project: $PROJECT_NAME <br/>Build # $BUILD_NUMBER <br/>Status: $BUILD_STATUS <br/>SWMS Version: ${ENV,var="SWMS_VERSION"} <br/>Targer Server: ${ENV,var="TARGET_SERVER"}.${ENV,var="SERVER_DOMAIN"}  <br/>Check console output at $BUILD_URL to view the results.',
                    mimeType: 'text/html',
                    subject: "[SWMS-OPCO-DEPLOYMENT] - ${currentBuild.fullDisplayName}",
                    recipientProviders: [requestor()]

                withCredentials([string(credentialsId: "/swms/jenkins/swms-opco-build/${(env.PIPELINE_NAME == 'swms-opco-deployment') ? 'teams-webhook-url-prod' : 'teams-webhook-url-nonprod'}", variable: 'TEAMS_WEBHOOK_URL')]) {
                    office365ConnectorSend webhookUrl: TEAMS_WEBHOOK_URL,
                        message: "Build # ${currentBuild.id}",
                        factDefinitions: [[name: "Remarks", template: "${currentBuild.getBuildCauses()[0].shortDescription}"],  
                                         [name: "SWMS Version", template: "${env.SWMS_VERSION}"],         
                                         [name: "Target Server", template: "${env.TARGET_SERVER}.${env.SERVER_DOMAIN}"]],
                        color: (currentBuild.currentResult == 'SUCCESS') ? '#11fa1d' : '#FA113D',
                        status: currentBuild.currentResult
                }
            }
        }
    }
}