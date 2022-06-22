TARGETDB=$1
ROOTPW=$2

echo "Hi Im inside"
sqlplus root/$ROOTPW@$TARGETDB:1521/SWM1 << EOF
exit
EOF