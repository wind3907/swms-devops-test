TARGETDB='lx739q17'

records=`grep -c "${TARGETDB}_db" /tempfs/tnsnames-test.ora`
echo "${records}"
if [ $records == '0' ]                                                                                                    
then
    echo "Record is not in tnsnames"
    cat <<EOT >> /tempfs/tnsnames-test.ora
    lx739q17_db =
        (DESCRIPTION =
            (ADDRESS_LIST =
            (ADDRESS = (PROTOCOL = TCP)(HOST =lx739q17-db.coz2zoxeiq71.us-east-1.rds.amazonaws.com)(PORT = 1521))
            )
        (CONNECT_DATA =
            (SID = swm1)
            )
        )
    EOT
else
    echo "Record is already in tnsnames"
fi