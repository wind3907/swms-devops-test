#!/bin/bash
version_dbcol=`sqlplus -s ${ORACLE_SWMS_USER}/${ORACLE_SWMS_PASSWORD} <<!
set pages 0 echo off feed off
select attribute_value
  FROM maintenance m
  WHERE attribute = 'LEVEL'
    AND application = 'SWMS'
    AND component = 'SCHEMA'
    AND create_date = ( SELECT max(create_date)
                          FROM maintenance d
                          WHERE d.attribute = m.attribute
                          AND d.component = m.component
                          AND d.application = m.application
                      );
commit;
!
`
echo "Version Number" $version_dbcol