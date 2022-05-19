ssh -i $SSH_KEY ${SSH_KEY_USR}@rs1060b1.na.sysco.net ". ~/.profile; beoracle_ci mkdir /tempfs"
scp -i $SSH_KEY ${WORKSPACE}/scripts/* ${SSH_KEY_USR}@rs1060b1.na.sysco.net:/tempfs/11gtords/