TARGETDB='lx739q13-db.swms-np.us-east-1.aws.sysco.net'

sqlplus 'swms/swms@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST='lx739q13-db.swms-np.us-east-1.aws.sysco.net')(PORT='1521'))(CONNECT_DATA=(SID='SWM1')))'  << EOF
exit
EOF