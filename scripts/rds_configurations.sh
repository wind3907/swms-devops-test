. /usr/lpp/oracle/.profile.19c

SOURCEDB=$1
TARGETDB=$2
ROOTPW=$3
AIXDBBK=$4

export TNS_ADMIN=/home2/dba/jcx/11gtords
export ORACLE_SID=swms_ci1

sqlplus swms/swms@$TARGETDB << EOF
@/home2/dba/jcx/11gtords/rdsconfig/type_log_message.sql
@/home2/dba/jcx/11gtords/rdsconfig/create_async_log_sq_ddl.sql
exit
EOF

sqlplus root/$ROOTPW@$TARGETDB << EOF
@/home2/dba/jcx/11gtords/rdsconfig/grants_for_aq.sql
exit
EOF