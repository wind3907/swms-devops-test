. /usr/lpp/oracle/.profile.19c

SOURCEDB=$1
TARGETDB=$2
ROOTPW=$3
TARGETDB_IP=$4
AIXDBBK=$5


export TNS_ADMIN=/home2/dba/jcx/11gtords
export ORACLE_SID=swms_ci1


sqlplus root/$ROOTPW@$TARGETDB << EOF
@/tempfs/terraform/reset_network_acls.sql $TARGETDB_IP
exit
EOF