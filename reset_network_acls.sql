DECLARE
	v_swms_host_exists NUMBER := 0;
	acl_count Number;
	swms_host VARCHAR2(20) := '&1';
BEGIN
	$if swms.platform.SWMS_REMOTE_DB $then
		SELECT COUNT(*) INTO  v_swms_host_exists FROM  swms.sys_config
			WHERE config_flag_name = 'SWMS_HOST';

		IF v_swms_host_exists = 0 THEN
			INSERT INTO swms.sys_config
				(seq_no, application_func, config_flag_name, config_flag_desc,
				config_flag_val, value_required, value_updateable, value_is_boolean, data_type,
				data_precision, sys_config_list, sys_config_help, validation_type)
			VALUES
				((SELECT MAX(seq_no)+1 FROM swms.sys_config), 'GENERAL', 'SWMS_HOST', 'SWMS Server Box URL',
				swms_host, 'Y', 'N', 'N', 'CHAR', 20, 'N', 'SWMS Server URL', 'NONE');
			COMMIT;
		ELSE
			UPDATE swms.sys_config SET config_flag_val = swms_host WHERE config_flag_name = 'SWMS_HOST';
			COMMIT;
		END IF;

		-- Allow Network ACL for http-logger (PL_TEXT_LOG PACKAGE)
		SELECT count(*) INTO acl_count FROM DBA_NETWORK_ACLS
			WHERE acl = '/sys/acls/swms_http_logger.xml';

		IF acl_count = 0 THEN
			BEGIN
				DBMS_NETWORK_ACL_ADMIN.CREATE_ACL ( acl => 'swms_http_logger.xml', description => 'Permission for SWMS to invoke HTTP logger API', principal => 'PUBLIC', is_grant => TRUE, privilege => 'connect' );
				COMMIT;
			END;
			BEGIN
				DBMS_NETWORK_ACL_ADMIN.add_privilege ( acl => 'swms_http_logger.xml', principal => 'SWMS', is_grant => TRUE, privilege => 'connect' );
				COMMIT;
			END;
			BEGIN
				DBMS_NETWORK_ACL_ADMIN.assign_acl(acl => 'swms_http_logger.xml', host => swms_host, lower_port => 39005, upper_port => 39005);
			END;
		END IF;

		-- Allow Network ACL for swms-executer (PL_CALL_REST PACKAGE)
		SELECT count(*) INTO acl_count FROM DBA_NETWORK_ACLS
			WHERE acl = '/sys/acls/swms_executer.xml';

		IF acl_count = 0 THEN
			BEGIN
				DBMS_NETWORK_ACL_ADMIN.CREATE_ACL ( acl => 'swms_executer.xml', description => 'Permission for SWMS to invoke SWMS-Executer API', principal => 'PUBLIC', is_grant => TRUE, privilege => 'connect' );
				COMMIT;
			END;
			BEGIN
				DBMS_NETWORK_ACL_ADMIN.add_privilege ( acl => 'swms_executer.xml', principal => 'SWMS', is_grant => TRUE, privilege => 'connect' );
				COMMIT;
			END;
			BEGIN
				DBMS_NETWORK_ACL_ADMIN.assign_acl(acl => 'swms_executer.xml', host => swms_host, lower_port => 8088, upper_port => 8088);
			END;
		END IF;
	$else
		dbms_output.put_line('This DML is not executable in non-remote SWMS DB'); 
	$end
END;
/