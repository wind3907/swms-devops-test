TARGETDB='lx739q13'
ROOTPW='ZXCK>MW*$uo%B6t?s'

sqlplus 'root/'"$ROOTPW"'@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST='"$TARGETDB"'-db.swms-np.us-east-1.aws.sysco.net)(PORT='1521'))(CONNECT_DATA=(SID='SWM1')))'  << EOF
exit
EOF