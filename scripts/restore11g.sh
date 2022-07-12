SOURCEDB=$1
TARGETDB=$2
ROOTPW=$3
AIXDBBK=$4

rm -rf /dbf/swm1/export/*.tar.gz
rcp -rp $SOURCEDB:$AIXDBBK /dbf/swm1/export/$SOURCEDB.tar.gz