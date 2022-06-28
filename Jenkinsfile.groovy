properties(
    [
        buildDiscarder(logRotator(numToKeepStr: '20')),
        parameters(
            [
                string(name: 'SOURCE_DB', defaultValue: 'rsxxxe', description: 'Source Database. eg: rs040e'),
                // string(name: 'TARGET_DB', defaultValue: 'rds_trn_xxx', description: 'Target Database. eg: rds_trn_040'),
                // string(name: 'ROOT_PW', defaultValue: 'SwmsRoot123', description: 'Root Password'),
                // string(name: 'TARGET_SERVER', defaultValue: 'lxxxxtrn', description: 'Host ec2 instance. eg: lx036trn'),
                // choice(name: 'artifact_s3_bucket', choices: ['swms-build-artifacts', 'swms-build-dev-artifacts'], description: 'The build\'s targeted platform'),
                // choice(name: 'platform', choices: ['linux','aix_11g_11g', 'aix_19c_12c'], description: 'The build\'s targeted platform'),
                // string(name: 'artifact_version', defaultValue: '50_0', description: 'The swms version to deploy', trim: true),
                // [
                //             name: 'artifact_name',
                //             description: 'The name of the artifact to deploy',
                //             $class: 'CascadeChoiceParameter',
                //             choiceType: 'PT_SINGLE_SELECT',
                //             filterLength: 1,
                //             filterable: false,
                //             randomName: 'choice-parameter-artifact_name',
                //             referencedParameters: 'artifact_s3_bucket, platform, artifact_version',
                //             script: [
                //                 $class: 'GroovyScript',
                //                 script: [classpath: [], sandbox: false, script: '''\
                //                         if (platform?.trim() && artifact_version?.trim()) {
                //                             def process = "aws s3api list-objects --bucket ${artifact_s3_bucket} --prefix ${platform}-${artifact_version} --query Contents[].Key".execute()
                //                             return process.text.replaceAll('"', "").replaceAll("\\n","").replaceAll(" ","").tokenize(',[]')
                //                         } else {
                //                             return []
                //                         }
                //                     '''.stripIndent()
                //                 ]
                //             ]
                //         ],
                // string(name: 'dba_masterfile_names', description: 'The name of the artifact to deploy', defaultValue: 'R50_0_dba_master.sql', trim: true),
                // string(name: 'master_file_retry_count', description: 'Amount of attempts to apply the master file. This is setup to handle circular dependencies by running the same master file multiple times.', defaultValue: '3', trim: true),
                // separator(name: "test", sectionHeader: "Data Migration Parameters", separatorStyle: "border-color: orange;", separatorHeaderStyle: "font-weight: bold; line-height: 1.5em; font-size: 1.5em;")
            ]
        )
    ]
)
pipeline {
    agent { label 'terraform-slave' }
    environment {
        SSH_KEY = credentials('/swms/jenkins/swms-universal-build/svc_swmsci_000/key')
        S3_ACCESS_ARN="arn:aws:iam::546397704060:role/ec2_s3_role";
        AWS_ROLE_SESSION_NAME="swms-data-migration";
        RDS_INSTANCE="${params.TARGET_SERVER}-db"
        S3_BUCKET="swms-jenkins-chef-ci"
    }
    stages {
        stage('Checkout SCM') {
            steps {
                cleanWs()
                checkout scm
                echo "Building ${env.JOB_NAME}..."
            }
        }
        stage('Copy Chef Resources to S3') {
            when {
                expression {
                    params.TERRAFORM_COMMAND == 'create'
                }
            }
            steps {
                script{
                    sh """
                        mkdir -p ${WORKSPACE}/.kitchen
                        cat "Testline1 " >  ${WORKSPACE}/.kitchen/dev-client-rhel-7.yml
                        cat "Testline2 " >>  ${WORKSPACE}/.kitchen/dev-client-rhel-7.yml
                        aws s3 cp --recursive ${WORKSPACE}/.kitchen s3://${S3_BUCKET}/chef_state_files/lx739q14
                    """
                }
            }
        }
    }
    post {
        // always {
        //     script {
        //         sh """
        //             ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net "
        //             . ~/.profile;
        //             beoracle_ci rm -r /tempfs/terraform/
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

