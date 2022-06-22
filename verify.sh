. /usr/lpp/oracle/.profile.19c

TARGETDB=$1
ROOTPW=$2

echo $TARGETDB
echo $ROOTPW

export ORACLE_SID=swms_ci1
export TNS_ADMIN=/home2/dba/jcx/11gtords

sqlplus 'root/'"$ROOTPW"'@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST='"$TARGETDB"'-db.swms-np.us-east-1.aws.sysco.net)(PORT='1521'))(CONNECT_DATA=(SID='SWM1')))'  << EOF
exit
EOF