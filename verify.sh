TARGETDB=$1
ROOTPW=$2

records=`grep -c lx0349trn_db /home2/dba/jcx/11gtords/tnsnames.ora`
if [ $records == '0' ]                                                                                                    
then
    echo "Record is not in tnsnames"                                                                                        
else
    echo "Record is already in tnsnames"       
fi