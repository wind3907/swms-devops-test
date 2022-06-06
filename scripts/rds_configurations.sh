. /usr/lpp/oracle/.profile.19c

SOURCEDB=$1
TARGETDB=$2
ROOTPW=$3
AIXDBBK=$4

export TNS_ADMIN=/home2/dba/jcx/11gtords
export ORACLE_SID=swms_ci1

sqlplus root/$ROOTPW@$TARGETDB << EOF
@rdsconfig/type_log_message.sql
@rdsconfig/create_async_log_sq_ddl.sql
@rdsconfig/grants_for_aq.sql
exit
EOF