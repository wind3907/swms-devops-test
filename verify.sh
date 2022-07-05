TARGETDB='lx739q17_db'
ROOTPW=$2

records=`grep -c $TARGETDB /home2/dba/jcx/11gtords/tnsnames-test.ora`
if [ $records == '0' ]                                                                                                    
then
    echo "Record is not in tnsnames"
    cat <> /home2/dba/jcx/11gtords/tnsnames-test.ora
    $TARGETDB =
    (DESCRIPTION =
        (ADDRESS_LIST =
        (ADDRESS = (PROTOCOL = TCP)(HOST =$TARGETDB-db.coz2zoxeiq71.us-east-1.rds.amazonaws.com)(PORT = 1521))
        )
    (CONNECT_DATA =
        (SID = swm1)
        )
    )
    EOF
else
    echo "Record is already in tnsnames"
fi