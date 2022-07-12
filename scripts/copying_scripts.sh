ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net ". ~/.profile; beoracle_ci mkdir -p /tempfs/11gtords"
ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net ". ~/.profile; beoracle_ci mkdir -p /home2/dba/jcx/11gtords/rdsconfig"
scp -i $SSH_KEY ${WORKSPACE}/scripts/* ${SSH_KEY_USR}@rs1060b1.na.sysco.net:/tempfs/11gtords/