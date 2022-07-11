# swms-platform-deployment

Jenkins deployment automation for swms-opco

## Table of Contents

- [Environment Variables](#environment-variables)
- [Secrets](#secrets)
- [APCOM Configuration](#apcom-configuration)
- [TSID Configuration](#tsid-configuration)

## Environment Variables

Variables used to customize deployment. Declared variables will be used
in the Jenkins Pipeline. Will be stored in AWS SystemsManager Parameter Store

> Note: Values recorded here are **not** secure values and are in plain text.

### AWS SSM Namespacing

Non Production: /swms/deployment_automation/nonprod/\<RELATIVE_PATH>

Production: /swms/deployment_automation/prod/\<RELATIVE_PATH>

## Secrets

Variables used to customize deployment but are also not to be made public.
Declared variables can be used in the Jenkins Pipeline Will be stored in AWS
SecretsManager.

> Note: Secrets will be converted into asterisks in the Jenkins Log.

### AWS SecretsManager Namespacing

Non Production: /swms/deployment_automation/nonprod/\<RELATIVE_PATH>

Production: /swms/deployment_automation/prod/\<RELATIVE_PATH>

Jenkins Usage: https://plugins.jenkins.io/aws-secrets-manager-credentials-provider/

## Apply DBA masterfile

The DBA masterfile is only applied for certain version updates. If the **dba_masterfile_names** parameter is left empty, this stage will not run.

### Applying DBA masterfile on Linux RDS

The RDS master user's credentials are required here. These credentials need to be stored in AWS Secrets Manager under the path **/swms/deployment_automation/nonprod/oracle/master_creds/<TARGET_SERVER>** with the master user's password as the Plaintext value. If the secret is not present for the linux environment, the deployment will fail.

In order for the credentials to work with Jenkins, the following two tags must be added to the secret as well.
| Key | Value |
|---|---|
| jenkins:credentials:type | usernamePassword |
|jenkins:credentials:username | <master_username> |

Example (not real environments or credentials):
| Environment | Secret path | Value (Plaintext) | jenkins:credentials:username value |
|---|---|---|---|
| lx001q1 | /swms/deployment_automation/nonprod/oracle/master_creds/lx001q1 | kH%sRsz!#2 | root |
| lx002q2 | /swms/deployment_automation/nonprod/oracle/master_creds/lx002q2 | xwE1s$2s@Lk | root |

You can add the first example given above to secrets manager using the following command:

`aws secretsmanager create-secret --name '/swms/deployment_automation/nonprod/oracle/master_creds/lx001q1' --region us-east-1 --secret-string 'kH%sRsz!#2' --tags 'Key=jenkins:credentials:type,Value=usernamePassword' 'Key=jenkins:credentials:username,Value=root' --description 'The master credentials for the RDS of lx001q1'`

## APCOM Configuration

Configuration of the APCOM installations.

### Edit Queue Length

To edit the queue length, the Queue names and Length changes will be updated in AWS
SystemsManager Parameter store

| SSM Path       | Example Value (line seprated examples)                                                                            |
| -------------- | ----------------------------------------------------------------------------------------------------------------- |
| Non Production | /swms/deployment_automation/nonprod/apcom/queue_names<br/>/swms/deployment_automation/nonprod/apcom/queue_lengths |
| Production     | /swms/deployment_automation/prod/apcom/queue_names<br/>/swms/deployment_automation/prod/apcom/queue_lengths       |

Each unique value will be space separated and both values must have **identical
lengths of values**.

**If not used then leave the ssm value as a space (" ", without the quotes).**

Example:
|SSM Path|Value|
|---|---|
| /swms/deployment_automation/nonprod/apcom/queue_names | "AB CD EF GH IJ" |
| /swms/deployment_automation/prod/apcom/queue_lengths | "255 166 294 404 503" |

## TSID Configuration

Gives specific applications elevated permissions

Each of the file must be in **DIR="$SWMS_HOME"/bin** at deployment time (This
will be done by the pipeline as long as the files are in the tar file.)

### List location

To edit the list of files, it will be stored in AWS Parameter Store

| SSM Path       | Example Value (line seprated examples)         |
| -------------- | ---------------------------------------------- |
| Non Production | /swms/deployment_automation/nonprod/tsid/files |
| Production     | /swms/deployment_automation/prod/tsid/files    |

### Format

Comma separated values files.

e.g:

- ABC, DEF, HIJ, JKL
- ABC,DEF,HIJ,JKL

Example:

| SSM Path                                       | Value                      |
| ---------------------------------------------- | -------------------------- |
| /swms/deployment_automation/nonprod/tsid/files | file1, file2, file3, file4 |
