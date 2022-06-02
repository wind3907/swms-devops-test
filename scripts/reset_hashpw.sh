. /usr/lpp/oracle/.profile.19c

export TNS_ADMIN=/home2/dba/jcx/11gtords
export ORACLE_SID=swms_ci1

sqlplus root/$ROOTPW@$TARGETDB << EOF
CREATE OR REPLACE  PROCEDURE "SWMS_SYS"."SET_HASH_PASSWORD" 
    (p_username IN VARCHAR2) AS
  tmp        NUMBER(2);
  hash_val   NUMBER;
  out_val    NUMBER;
  return_val NUMBER;
  aix_user   VARCHAR2(35);
  out_msg    VARCHAR2(255);
  sql_stmt   VARCHAR2(80);
BEGIN
  aix_user := LOWER(REPLACE(UPPER(p_username),'OPS$'));
 
  SELECT 0
    INTO tmp
    FROM DBA_USERS
   WHERE username = 'OPS$' || UPPER(aix_user);
 
  return_val := frm_login.ora_getuserattr_int(aix_user,frm_login.f_s_id,
                                              out_val,frm_login.f_sec_int,out_msg);
 
  hash_val := frm_login.f_seed(aix_user,out_val);
 
  sql_stmt := 'ALTER USER OPS$' || UPPER(aix_user) || ' IDENTIFIED BY ' || TO_CHAR(hash_val);
 
  EXECUTE IMMEDIATE sql_stmt;
 
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR (-20001, 'Oracle user OPS$' || UPPER(aix_user) || ' does not exist.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR (-20002, SQLERRM);
 
END;
/

grant execute on SWMS_SYS.set_hash_password to swms_viewer;
grant execute on SWMS_SYS.set_hash_password to swms_user;
exit
EOF