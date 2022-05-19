. /usr/lpp/oracle/.profile.19c
TARGET_DB=$1
ROOTPW=$2
export TNS_ADMIN=/home2/dba/jcx/11gtords
export ORACLE_SID=swms_ci1
cd /home2/dba/jcx/11gtords
sed "s/swm1_lx739q3/$TARGET_DB/g" create_dblink.sql.swm1_lx739q3|sed "s/xxxxxx/$ROOTPW/g" >create_dblink.sql
sed "s/swm1_lx739q3/$TARGET_DB/g" transfertoRDS.sql.swm1_lx739q3 >transfertoRDS.sql
sqlplus root/$ROOTPW@$TARGET_DB << EOF
exec utl_file.fremove('DATA_PUMP_DIR','expswms.dmp');
drop user swms cascade;
exit
EOF
sqlplus / as sysdba << EOF
CREATE OR REPLACE DIRECTORY "DATA_PUMP_DIR" as '/dbf/swm1/export';
@create_dblink.sql
@transfertoRDS.sql
exit
EOF