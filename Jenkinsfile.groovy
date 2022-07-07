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
        stage('Test'){
            steps {
                script {
                    sh "echo 'This is a test'"
                }
            }
        } 
    }
    post {
        always {
            script {
                env.SOURCE_DB = 'rs048e'
                env.TARGET_DB = 'lx048trn'
                dir("selector-academy") {
                    git branch: "master",
                    credentialsId: '4c5daf94-f77a-4854-8a88-03fae213f59b',
                    url: "https://github.com/SyscoCorporation/selector-academy.git"
                }
                env.EMAIL = sh(script: '''grep $TARGET_DB selector-academy/email_recipients.txt | awk '{ print $2 }' ''',returnStdout: true).trim()
                emailext body: 'Project: $PROJECT_NAME <br/>Build # $BUILD_NUMBER <br/>Status: $BUILD_STATUS <br/>Source Database: $SOURCE_DB <br/>Target Database: $TARGET_DB <br/>Check console output at $BUILD_URL to view the results.',
                    mimeType: 'text/html',
                    subject: "[SWMS-DATA-MIGRATION-AIX-RDS] - ${currentBuild.fullDisplayName}",
                    to: '${ENV,var="EMAIL"}'
                
                withCredentials([string(credentialsId: '/swms/jenkins/swms-data-migration', variable: 'TEAMS_WEBHOOK_URL')]) {
                    office365ConnectorSend webhookUrl: 'https://sysco.webhook.office.com/webhookb2/098bf2bd-d6c7-430d-a993-c584b867673e@b7aa4308-bf33-414f-9971-6e0c972cbe5d/JenkinsCI/0499dcd79e5b47918f3deb4b72ae7b21/52b05ab5-3f6f-48ee-a10f-1957d1592c08',
                        message: "Build # ${currentBuild.id}",
                        factDefinitions: [[name: "Remarks", template: "${currentBuild.getBuildCauses()[0].shortDescription}"],
                                         [name: "Last Commit", template: "${sh(returnStdout: true, script: 'git -C swms-devops-test log -1 --pretty=format:%h')}"],
                                         [name: "Last Commit Author", template: "${sh(returnStdout: true, script: 'git -C swms-devops-test log -1 --pretty=format:%an')}"],
                                         [name: "Source Database", template: "${params.SOURCE_DB}"],
                                         [name: "Target Database", template: "${params.TARGET_DB}"]],
                        color: (currentBuild.currentResult == 'SUCCESS') ? '#11fa1d' : '#FA113D',
                        status: currentBuild.currentResult
                }
            }
        }
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

