. /usr/lpp/oracle/.profile.19c

SOURCEDB=$1
TARGETDB=$2
ROOTPW=$3
AIXDBBK=$4

export TNS_ADMIN=/home2/dba/jcx/11gtords
export ORACLE_SID=swms_ci1
sqlplus root/$ROOTPW@$TARGETDB << EOF >/dev/null
@transferfromRDS.sql
spool 5.log;
select max(trans_date) from trans;
select * from swms.maintenance where component='COMPANY';
select * from table(RDSADMIN.RDS_FILE_UTIL.LISTDIR('DATA_PUMP_DIR')) order by mtime;
spool off
exit
EOF

grep ". . imported " swms_imprds.log
##grep -v "already exists" swms_imprds.log|grep -v "does not exist"|grep -v CONV_USER|grep -v "Failing sql"|grep -v "ORA-39083"
sqlplus root/$ROOTPW@$TARGETDB << EOF
select max(trans_date) from trans;
select * from swms.maintenance where component='COMPANY';
exit
EOF