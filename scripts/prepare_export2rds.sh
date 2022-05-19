. /usr/lpp/oracle/.profile11.1
export ORACLE_SID=swm1
echo "shutdown immediate;" | sqlplus -s "/ as sysdba"
rm -rf /dbf/swm1/d1
rm -rf /dbf/swm1/d2
rm /dbf/swm1/arch/swm1_arch*
cd /dbf/swm1/export
gunzip *e.tar.gz -c | tar -xvpf -
rm /dbf/swm1/d1/initswm1.ora
cp /dbf/swm1/initswm1.ora /dbf/swm1/d1/initswm1.ora
sqlplus / as sysdba <<! > /home2/dba/jcx/11gtords/activate.log
shutdown immediate;
startup mount;
ALTER DATABASE ACTIVATE STANDBY DATABASE;
exit;
!
grep "ERROR at line 1" /home2/dba/jcx/11gtords/activate.log
if [ $? -eq 0 ]; then
  echo "Error recopy initswm1.ora1 "
cp /dbf/swm1/initswm1.ora1 /dbf/swm1/d1/initswm1.ora
sqlplus / as sysdba <<! 
shutdown immediate;
startup mount;
shutdown immediate;
startup mount;
ALTER DATABASE ACTIVATE STANDBY DATABASE;
exit;
!
fi 
sqlplus / as sysdba <<! 
alter database set standby to maximize performance;
alter database open;
show parameter local;
execute sys.SET_HASH_PASSWORD('OPS\$dblu9632');
select * from swms.maintenance where component='COMPANY';
select max(trans_date) from trans;
CREATE OR REPLACE DIRECTORY "DATA_PUMP_DIR" as '/dbf/swm1/export';
exit;
!
rm /dbf/swm1/export/expswms.dmp
cd /dbf/swm1/export/11gtords