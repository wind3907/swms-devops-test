TARGETDB='lx739q13-db.swms-np.us-east-1.aws.sysco.net'
CONNECTION="swms/swms@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$TARGETDB)(PORT='1521'))(CONNECT_DATA=(SID='SWM1')))"
# ROOTPW="ZXCK>MW*$uo%B6t?"
echo '$CONNECTION'
echo $CONNECTION
# sqlplus $CONNECTION  << EOF
# exit
# EOF