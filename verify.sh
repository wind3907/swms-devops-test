TARGETDB="lx739q13-db.swms-np.us-east-1.aws.sysco.net:1521/SWM1"
ROOTPW="ZXCK>MW*$uo%B6t?"
CONNECTION='root/$ROOTPW@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST='lx739q13-db.swms-np.us-east-1.aws.sysco.net')(PORT='1521'))(CONNECT_DATA=(SID='SWM1')))'

echo "$CONNECTION"

# sqlplus root/$ROOTPW@$TARGETDB

# sqlplus 'root/$ROOTPW@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST='lx739q13-db.swms-np.us-east-1.aws.sysco.net')(PORT='1521'))(CONNECT_DATA=(SID='SWM1')))'  << EOF
# exit
# EOF