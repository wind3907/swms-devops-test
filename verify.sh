TARGETDB=$1
ROOTPW=$2

export ORACLE_SID=swms_ci1
export TNS_ADMIN=/home2/dba/jcx/11gtords

echo "$TARGETDB"
echo "$ROOTPW"

result=`sqlplus 'root/f:U:&yQMgaX_Lt1$@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST='lx739q18-db.swms-np.us-east-1.aws.sysco.net')(PORT='1521'))(CONNECT_DATA=(SID='SWM1')))' << EOF
exit
EOF`

echo $result
                                                                                              
if echo $result | grep -q "Connected"                                                                                                    
    then echo 'Connected Successfulyy'                                                                                                            
    else exit 1                                                                                                                          
fi  

