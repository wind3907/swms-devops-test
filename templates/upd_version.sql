UPDATE maintenance m
  SET attribute_value = '${SWMS_VERSION_NUMBER}'
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
