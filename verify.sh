. /usr/lpp/oracle/.profile.19c
ROOTPW=`cat /home2/dba/jcx/11gtords/.rootpw`
if [ $# -ne 2 ]; then
   echo "Usage: $0 Source_11g_DB Target_19cRDS; Eg:$0 rs040e rds_trn_040"
   exit
fi
SOURCEDB=$1
TARGETDB=$2
AIXDBBK=/tempfs/DBBackup/SWMS/swm1_db_$1*.tar.gz
if [ "`echo $SOURCEDB | cut -c6`" = "e" ]; then
    echo Good This is E box $SOURCEDB
else
    echo Error: Please use rsxxxe
    exit
fi

if [ "`echo $TARGETDB | cut -c1-7`" = "rds_trn" ]; then
    echo Good This is RDS db server $TARGETDB
else
    echo Error: Please use rds_trn_xxx
    exit
fi

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
alter user swms identified by swms;
exit
EOF
