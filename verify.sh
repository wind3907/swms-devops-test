TARGETDB=$1
ROOTPW=$2

echo "$TARGETDB"
echo "$ROOTPW"

result=`sqlplus 'root/'$ROOTPW'@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST='$TARGETDB'-db.swms-np.us-east-1.aws.sysco.net')(PORT='1521'))(CONNECT_DATA=(SID='SWM1')))' << EOF
exit
EOF`

echo $result
                                                                                              
if echo $result | grep -q "Connected"                                                                                                    
    then echo 'Connected Successfulyy'                                                                                                            
    else exit 1                                                                                                                          
fi  

