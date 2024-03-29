. /usr/lpp/oracle/.profile.19c

SOURCEDB=$1
TARGETDB=$2
ROOTPW=$3
AIXDBBK=$4

export TNS_ADMIN=/home2/dba/jcx/11gtords
export ORACLE_SID=swms_ci1

sqlplus root/$ROOTPW@$TARGETDB << EOF
UPDATE SYS_CONFIG SET CONFIG_FLAG_VAL='STAGING TABLES' WHERE CONFIG_FLAG_NAME = 'HOST_COMM';
COMMIT;

UPDATE SYS_CONFIG SET CONFIG_FLAG_VAL='AS400' WHERE CONFIG_FLAG_NAME = 'HOST_TYPE';
COMMIT;
exit
EOF