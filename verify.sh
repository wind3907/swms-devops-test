TARGETDB=$1
ROOTPW=$2

export ORACLE_SID=swms_ci1
export TNS_ADMIN=/home2/dba/jcx/11gtords

result=`sqlplus 'root/'$ROOTPW'@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST='$TARGETDB-db.swms-np.us-east-1.aws.sysco.net')(PORT='1521'))(CONNECT_DATA=(SID='SWM1')))' << EOF
exit
EOF`

echo $result

