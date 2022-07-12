. /usr/lpp/oracle/.profile.19c

TARGETDB=$1
ROOTPW=$2

echo "$TARGETDB"
echo "$ROOTPW"

export TNS_ADMIN=/home2/dba/jcx/11gtords
export ORACLE_SID=swms_ci1

sqlplus root/$ROOTPW@$TARGETDB << EOF
alter user swms identified by swms;
exit
EOF