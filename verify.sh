TARGETDB=$1
ROOTPW=$2

records=`grep -c lx059trn_db /home2/dba/jcx/11gtords/tnsnames.ora`
if [ $records == '0' ]                                                                                                    
then
    echo "Record is already in tnsnames"                                                                                                           
else
    echo "Record is not in tnsnames"  
fi