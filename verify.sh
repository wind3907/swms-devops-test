TARGETDB=$1
ROOTPW="ZXCK>MW*$uo%B6t?"

echo "Hi Im inside"

sqlplus 'root/$ROOTPW@lx739q13-db.swms-np.us-east-1.aws.sysco.net:1521/SWM1' << EOF
exit
EOF