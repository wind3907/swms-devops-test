TARGETDB='lx739q13-db.swms-np.us-east-1.aws.sysco.net'
# ROOTPW="ZXCK>MW*$uo%B6t?"

sqlplus """swms/swms@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$TARGETDB)(PORT='1521'))(CONNECT_DATA=(SID='SWM1')))"""  << EOF
exit
EOF