TARGETDB=$1
TARGETDB_ALIAS=$(echo $TARGETDB | tr 'a-z' 'A-Z')

records=`grep -c "SWM1_${TARGETDB_ALIAS}" /u01/app/oracle/config/domains/frsdomain/config/fmwconfig/tnsnames-test.ora`
echo "${records}"
if [ $records == '0' ]                                                                                                    
then
    echo "Record is not in tnsnames"
    tee -a /u01/app/oracle/config/domains/frsdomain/config/fmwconfig/tnsnames-test.ora <<EOF
SWM1_${TARGETDB_ALIAS} =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = ${TARGETDB}-db.swms-np.us-east-1.aws.sysco.net)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SID = swm1)
    )
  )
EOF
else
    echo "Record is already in tnsnames"
fi


