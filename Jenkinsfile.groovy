properties(
    [
        buildDiscarder(logRotator(numToKeepStr: '20')),
        parameters(
            [
                string(name: 'TARGET_DB', description: 'The rf-host-service branch to be built and included', defaultValue: 'lx036trn',  trim: true),
            ]
        )
    ]
)
pipeline {
    agent { label 'master' }
    options {
        skipDefaultCheckout()
    }
    stages {
        stage('Checkout SCM') {
            steps {
                dir('swms-devops-test') { checkout scm }
            }
        } 
    }
    post {
        success {
            script {
                dir("email-repo") {
                    git branch: "main",
                    credentialsId: scm.getUserRemoteConfigs()[0].getCredentialsId(),
                    url: "https://github.com/wind3907/cron.git"
                }
                env.TARGET_DB = "${params.TARGET_DB}"
                env.EMAIL = sh(script: '''grep $TARGET_DB email-repo/email_recipients.txt | awk '{ print $2 }' ''',returnStdout: true).trim()  
                echo 'Data migration from Oracle 11 AIX to Oracle 19 RDS is successful!'
                
                emailext body: 'Project: $PROJECT_NAME <br/>Build # $BUILD_NUMBER <br/>Status: $BUILD_STATUS <br/>Target Database: $TARGET_DB <br/>Check console output at $BUILD_URL to view the results.',
                    mimeType: 'text/html',
                    subject: "[SWMS-DATA-MIGRATION-AIX-RDS] - ${currentBuild.fullDisplayName}",
                    to: '${ENV,var="EMAIL"}'

                // office365ConnectorSend webhookUrl: 'https://sysco.webhook.office.com/webhookb2/ea773582-604e-4b79-bae7-681359dc45b6@b7aa4308-bf33-414f-9971-6e0c972cbe5d/JenkinsCI/3d4a4f7ca2c142e48f993d7b37e7028a/52b05ab5-3f6f-48ee-a10f-1957d1592c08',
                //         message: "Build # ${currentBuild.id}",
                //         factDefinitions: [[name: "Remarks", template: "${currentBuild.getBuildCauses()[0].shortDescription}"],
                //                          [name: "Last Commit", template: "${sh(returnStdout: true, script: 'git -C swms-devops-test log -1 --pretty=format:%h')}"],
                //                          [name: "Last Commit Author", template: "${sh(returnStdout: true, script: 'git -C swms-devops-test log -1 --pretty=format:%an')}"],
                //                          [name: "Target Database", template: "${params.TARGET_DB}"]],
                //         color: (currentBuild.currentResult == 'SUCCESS') ? '#11fa1d' : '#FA113D',
                //         status: currentBuild.currentResult
            }
        }
        failure {
            script {
                echo 'Data migration from Oracle 11 AIX to Oracle 19 RDS is failed!'
            }
        }
    }
}

