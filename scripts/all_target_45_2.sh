ORACLE_USER=$1
ORACLE_PW=$2

sqlplus -s ${ORACLE_USER}/${ORACLE_PW}@SWM1_PROD <<EOF
var rc number;
whenever sqlerror exit :rc;
exec :rc:=1;

select '------------ ' || to_char(sysdate,'MM/DD/RRRR HH24:MI') ||
 ' ------------' "CURRENT TIME" from dual;

Prompt Running file: verify_access.sql
@/swms/curr/schemas/verify_access.sql

PROMPT *** RUNNING PLATFORM SETUP FIRST  ***
Prompt Running file: pl_platform.sql
@pl_platform.sql
Prompt Running file: pl_call_rest.sql
@pl_call_rest.sql                    
Prompt Running file: FRM_login.sql
@FRM_login.sql                    

PROMPT *** RUNNING DATABASE VIEWS ***
Prompt Running file: v_sos_status.sql
@v_sos_status.sql
Prompt Running file: v_fh1ra_sum.sql
@v_fh1ra_sum.sql
Prompt Running file: v_merge_batch_time.sql
@v_merge_batch_time.sql
Prompt Running file: v_rp2ri.sql
@v_rp2ri.sql
Prompt Running file: v_rp2ri_detl.sql
@v_rp2ri_detl.sql
Prompt Running file: v_ds_merge_batch_time.sql
@v_ds_merge_batch_time.sql
Prompt Running file: v_ds_non_merge_batch_time.sql
@v_ds_non_merge_batch_time.sql
Prompt Running file: v_ds_audit_manual_operation.sql
@v_ds_audit_manual_operation.sql
Prompt Running file: v_ds_pickup_points.sql
@v_ds_pickup_points.sql
Prompt Running file: v_ds_floats.sql
@v_ds_floats.sql
Prompt Running file: v_ds1sb_invalid_locations.sql
@v_ds1sb_invalid_locations.sql
Prompt Running file: v_ds1sb_missing_locations.sql
@v_ds1sb_missing_locations.sql
Prompt Running file: v_missing_labels.sql
@v_missing_labels.sql
Prompt Running file: v_missing_op_batches.sql
@v_missing_op_batches.sql
Prompt Running file: v_conn_batch_vw.sql
@v_conn_batch_vw.sql
Prompt Running file: v_la1ra.sql
@v_la1ra.sql
Prompt Running file: v_non_merge_batch_time.sql
@v_non_merge_batch_time.sql
Prompt Running file: v_dmd_loc.sql
@v_dmd_loc.sql
Prompt Running file: sts_route_view.sql
@sts_route_view.sql
Prompt Running file: v_sts_equipment.sql
@v_sts_equipment.sql
Prompt Running file: v_sts_equipment_cust.sql
@v_sts_equipment_cust.sql
Prompt Running file: v_sts_equipment_truck.sql
@v_sts_equipment_truck.sql
Prompt Running file: v_slstrb.sql
@v_slstrb.sql
Prompt Running file: v_cool_item.sql
@v_cool_item.sql
Prompt Running file: v_ord_cool.sql
@v_ord_cool.sql
Prompt Running file: v_ord_cool_batch.sql
@v_ord_cool_batch.sql
Prompt Running file: v_cool_item_count.sql
@v_cool_item_count.sql
Prompt Running file: v_mn1sa.sql
@v_mn1sa.sql
Prompt Running file: v_mn1rb.sql
@v_mn1rb.sql
Prompt Running file: v_mn1rc.sql
@v_mn1rc.sql
Prompt Running file: v_mn1rd.sql
@v_mn1rd.sql
Prompt Running file: v_mn1re.sql
@v_mn1re.sql
Prompt Running view: v_mx_views.sql
@v_mx_views.sql
Prompt Running view: v_mx_out_sys15.sql
@v_mx_out_sys15.sql
Prompt Running file: v_add_on_route_check.sql 
@v_add_on_route_check.sql 
Prompt Running file: v_dmg_reason_cds.sql
@v_dmg_reason_cds.sql
Prompt Running file: v_manifestqty.sql
@v_manifestqty.sql
Prompt Running file: v_route_close.sql
@v_route_close.sql
Prompt Running file: v_replen_type.sql
@v_replen_type.sql

PROMPT *** RUNNING DB TYPES ***
Prompt Running file: type_rf_msg.sql
@type_rf_msg.sql
Prompt Running file: type_msg_time_rec.sql
@type_msg_time_rec.sql
Prompt Running file: type_pallet_details_rec.sql
@type_pallet_details_rec.sql
Prompt Running file: type_order_response_details_rec.sql
@type_order_response_details_rec.sql
Prompt Running file: type_pallet_id_list_rec
@type_pallet_id_list_rec
Prompt Running file: type_product_details_rec.sql
@type_product_details_rec.sql
Prompt Running file: type_rf_matrix_replen_list.sql
@type_rf_matrix_replen_list.sql
Prompt Running file: type_stk_status.sql
@type_stk_status.sql
Prompt Running file: type_rf_print_lp.sql
@type_rf_print_lp.sql
Prompt Running file: type_rf_get_reason_codes.sql
@type_rf_get_reason_codes.sql
Prompt Running file: type_pl_rf_swap_drop.sql
@type_pl_rf_swap_drop.sql
Prompt Running file: type_pl_rf_swap_pick.sql
@type_pl_rf_swap_pick.sql
Prompt Running file: type_rf_stk_swap.sql
@type_rf_stk_swap.sql

PROMPT *** RUNNING DB PACKAGES PROCEDURES ***
Prompt Running file: pl_log.sql
@pl_log.sql
Prompt Running file: pl_text_log.sql
@pl_text_log.sql
Prompt Running file: pl_matrix_op.sql
@pl_matrix_op.sql
Prompt Running file: pl_order_processing.sql
@pl_order_processing.sql
Prompt Running file: pl_replenishments.sql
@pl_replenishments.sql
Prompt Running file: v_ndm_replen_info.sql
@v_ndm_replen_info.sql
Prompt Running file: pl_replen_rf.sql
@pl_replen_rf.sql
Prompt Running file: pl_vr_matrix_eligible.sql
@pl_vr_matrix_eligible.sql
Prompt Running file: v_replen_bulk.sql
@v_replen_bulk.sql
Prompt Running file: pl_audit.sql
@pl_audit.sql
Prompt Running file: pl_pflow.sql
@pl_pflow.sql
Prompt Running file: pl_exc.sql
@pl_exc.sql
Prompt Running file: pl_lmc.sql
@pl_lmc.sql
Prompt Running file: pl_lma.sql
@pl_lma.sql
Prompt Running file: pl_lmg.sql
@pl_lmg.sql
Prompt Running file: pl_lmg_adjust_qty.sql
@pl_lmg_adjust_qty.sql
Prompt Running file: pl_lmd_drop_point.sql
@pl_lmd_drop_point.sql
Prompt Running file: pl_lmf.sql
@pl_lmf.sql
Prompt Running file: pl_matrix_common.sql
@pl_matrix_common.sql

PROMPT *** RUNNING DB TRIGGERS ***
Prompt Running file: abc_trigger.sql
@abc_trigger.sql
Prompt Running file: trg_ins_floats_brow.sql
@trg_ins_floats_brow.sql
Prompt Running file: trg_ins_putawaylst_status_brow.sql
@trg_ins_putawaylst_status_brow.sql
Prompt Running file: trg_upd_sel_method_arow.sql
@trg_upd_sel_method_arow.sql
Prompt Running file: trg_upd_sel_equip_arow.sql
@trg_upd_sel_equip_arow.sql
Prompt Running file: trg_insupd_replenlst_brow.sql
@trg_insupd_replenlst_brow.sql
Prompt Running file: trg_insupd_putawaylst_brow.sql
@trg_insupd_putawaylst_brow.sql
Prompt Running file: trg_insdelupd_sel_method_zone_arow.sql
@trg_insdelupd_sel_method_zone_arow.sql
Prompt Running file: trg_insdel_ssl_master_arow.sql
@trg_insdel_ssl_master_arow.sql
Prompt Running file: pl_lm_time.sql
@pl_lm_time.sql
Prompt Running file: pl_rtn_lm.sql
@pl_rtn_lm.sql
Prompt Running file: plsql_chk_put.sql
@plsql_chk_put.sql
Prompt Running file: pl_task_assign.sql
@pl_task_assign.sql
Prompt Running file: pl_task_indirect.sql
@pl_task_indirect.sql
Prompt Running file: pl_task_merge.sql
@pl_task_merge.sql
Prompt Running file: pl_task_regular.sql
@pl_task_regular.sql
Prompt Running file: pl_task_retro.sql
@pl_task_retro.sql
Prompt Running file: pl_sysco_msg.sql
@pl_sysco_msg.sql
Prompt Running file: pl_validations.sql
@pl_validations.sql
Prompt Running file: pl_common.sql
@pl_common.sql
Prompt Running file: pl_debug.sql
@pl_debug.sql
Prompt Running file: pl_insert_replen_trans.sql
@pl_insert_replen_trans.sql
Prompt Running file: pl_lm1.sql
@pl_lm1.sql
Prompt Running file: pl_lm_msku.sql
@pl_lm_msku.sql
Prompt Running file: pl_lm_retro.sql
@pl_lm_retro.sql
Prompt Running file: pl_lmd.sql
@pl_lmd.sql
Prompt Running file: pl_lm_ds.sql
@pl_lm_ds.sql
Prompt Running file: pl_lm_sel.sql
@pl_lm_sel.sql
Prompt Running file: pl_rpt1.sql
@pl_rpt1.sql
Prompt Running file: pl_rtn_dtls.sql
@pl_rtn_dtls.sql
Prompt Running file: pl_exc.sql                       
@pl_exc.sql                                           
Prompt Running file: pl_putaway_utilities.sql         
@pl_putaway_utilities.sql                             
Prompt Running file: pl_split_and_floating_putaway.sql
@pl_split_and_floating_putaway.sql                    
Prompt Running file: pl_general_rule.sql              
@pl_general_rule.sql                                  
Prompt Running file: pl_pallet_label2.sql             
@pl_pallet_label2.sql                                 
Prompt Running file: pl_alloc_inv.sql             
@pl_alloc_inv.sql
Prompt Running file: pl_alloc_inv_matrix.sql
@pl_alloc_inv_matrix.sql
Prompt Running file: pl_msku.sql             
@pl_msku.sql
Prompt Running file: pl_process_osd.sql             
@pl_process_osd.sql
Prompt Running file: pl_sos_reassign.sql             
@pl_sos_reassign.sql
Prompt Running file: v_prod_ml_uom.sql
@v_prod_ml_uom.sql
Prompt Running file: pl_ml_common.sql             
@pl_ml_common.sql
Prompt Running file: pl_ml_cleanup.sql
@pl_ml_cleanup.sql
Prompt Running file: pl_miniload_processing.sql             
@pl_miniload_processing.sql
Prompt Running file: pl_op_vrt_alloc.sql             
@pl_op_vrt_alloc.sql
Prompt Running file: pl_purge_stagetable.sql
@pl_purge_stagetable.sql
Prompt Running file: pl_rf_get_reason_codes.sql
@pl_rf_get_reason_codes.sql

Prompt Running file: trg_del_replenlst_row.sql
@trg_del_replenlst_row.sql
Prompt Running file: trg_ins_replenlst_row.sql
@trg_ins_replenlst_row.sql
Prompt Running file: trg_upd_replenlst_row.sql
@trg_upd_replenlst_row.sql
Prompt Running file: trg_del_loc_reference_arow.sql
@trg_del_loc_reference_arow.sql
Prompt Running file: trg_del_returns_brow.sql
@trg_del_returns_brow.sql
Prompt Running file: trg_delupd_loc_reference_brow.sql
@trg_delupd_loc_reference_brow.sql
Prompt Running file: trg_ins_loc_reference_arow.sql
@trg_ins_loc_reference_arow.sql
Prompt Running file: trg_insupd_arch_batch_brow.sql
@trg_insupd_arch_batch_brow.sql
Prompt Running file: trg_insupd_batch_brow.sql
@trg_insupd_batch_brow.sql
Prompt Running file: trg_ins_label_master_brow.sql
@trg_ins_label_master_brow.sql
Prompt Running file: trg_insupddel_inv.sql  
@trg_insupddel_inv.sql                      
Prompt Running file: trg_insupd_loc_brow.sql
@trg_insupd_loc_brow.sql                    
Prompt Running file: trg_insupd_pm_brow.sql 
@trg_insupd_pm_brow.sql                     
Prompt Running file: trg_insupd_trans_brow.sql
@trg_insupd_trans_brow.sql
Prompt Running file: trg_ins_trans_brow.sql 
@trg_ins_trans_brow.sql                     
Prompt Running file: trg_IDU_spl_rqst_customer_brow.sql
@trg_IDU_spl_rqst_customer_brow.sql                     
Prompt Running file: trg_del_inv_brow.sql
@trg_del_inv_brow.sql                     
Prompt Running file: trg_upd_pallet_type_arow.sql
@trg_upd_pallet_type_arow.sql                     
Prompt Running file: trg_insupd_usrauth_arow.sql
@trg_insupd_usrauth_arow.sql
Prompt Running file: trg_upd_inv_arow.sql
@trg_upd_inv_arow.sql
Prompt Running file: trg_insupd_door_brow.sql
@trg_insupd_door_brow.sql
Prompt Running file: v_dmd_aisle.sql
@v_dmd_aisle.sql
Prompt Running file: v_fh1ra.sql
@v_fh1ra.sql
Prompt Running file: v_las_truck_check.sql
@v_las_truck_check.sql
Prompt Running file: v_las_truck.sql
@v_las_truck.sql
Prompt Running file: v_mh2ra.sql
@v_mh2ra.sql
Prompt Running file: v_mi1ra_2.sql
@v_mi1ra_2.sql
Prompt Running file: v_mi1rb.sql
@v_mi1rb.sql
Prompt Running file: v_ml1ra.sql
@v_ml1ra.sql
Prompt Running file: v_ml1rb.sql
@v_ml1rb.sql
Prompt Running file: v_ml1rc.sql
@v_ml1rc.sql
Prompt Running file: v_ml1rd.sql
@v_ml1rd.sql
Prompt Running file: v_ml1re.sql
@v_ml1re.sql
Prompt Running file: v_mt1ra.sql
@v_mt1ra.sql
Prompt Running file: v_mt1rb.sql
@v_mt1rb.sql
Prompt Running file: v_ob1rb.sql
@v_ob1rb.sql
Prompt Running file: v_ob1rc.sql
@v_ob1rc.sql
Prompt Running file: v_op1ra.sql
@v_op1ra.sql
Prompt Running file: v_oo1ra.sql
@v_oo1ra.sql
Prompt Running file: v_prp1sc.sql
@v_prp1sc.sql
Prompt Running file: v_rdc_po_details.sql
@v_rdc_po_details.sql
Prompt Running file: v_sn_po_xref.sql
@v_sn_po_xref.sql
Prompt Running file: v_rp1sd.sql
@v_rp1sd.sql
Prompt Running file: v_rp1sl.sql
@v_rp1sl.sql
Prompt Running file: v_rp2ra.sql
@v_rp2ra.sql
Prompt Running file: v_rp2rb.sql
@v_rp2rb.sql
Prompt Running file: v_rp2rc.sql
@v_rp2rc.sql
Prompt Running file: v_rp3ra1.sql
@v_rp3ra1.sql
Prompt Running file: v_rp3ra.sql
@v_rp3ra.sql
Prompt Running file: v_new_rp1ra.sql
@v_new_rp1ra.sql
Prompt Running file: v_rp4ra.sql
@v_rp4ra.sql
Prompt Running file: v_batch_no_null_kvi.sql        
@v_batch_no_null_kvi.sql                            
Prompt Running file: v_job_code_no_null_tmu.sql     
@v_job_code_no_null_tmu.sql                         
Prompt Running file: v_fk_audit_manual_operation.sql
@v_fk_audit_manual_operation.sql
Prompt Running file: v_rdc_po_details.sql
@v_rdc_po_details.sql
Prompt Running file: v_dmd_repl_trans.sql
@v_dmd_repl_trans.sql
Prompt Running file: v_dmd_replen_cnt.sql
@v_dmd_replen_cnt.sql
Prompt Running file: v_new_ndm_replen_cnt.sql
@v_new_ndm_replen_cnt.sql
Prompt Running file: v_sos_short_sum.sql
@v_sos_short_sum.sql
Prompt Running file: v_sosldcur.sql
@v_sosldcur.sql
Prompt Running file: v_sosldhst.sql
@v_sosldhst.sql
Prompt Running file: v_sos_training.sql
@v_sos_training.sql
Prompt Running file: v_vendor_RDC_PO_master.sql
@v_vendor_RDC_PO_master.sql
Prompt Running file: sos_training_view.sql
@sos_training_view.sql
Prompt Running file: v_vrt_prod.sql
@v_vrt_prod.sql
Prompt Running file: v_wis_qualify.sql
@v_wis_qualify.sql
Prompt Running file: v_wis_mispick.sql
@v_wis_mispick.sql
Prompt Running file: v_wis_errors.sql
@v_wis_errors.sql
Prompt Running file: v_wis_inc_detail.sql
@v_wis_inc_detail.sql
Prompt Running file: v_wis_inc_hist.sql
@v_wis_inc_hist.sql
Prompt Running file: v_wis_inc_mst.sql
@v_wis_inc_mst.sql
Prompt Running file: v_wis_inc_hist_mst.sql
@v_wis_inc_hist_mst.sql
Prompt Running file: v_li1sh.sql
@v_li1sh.sql
Prompt Running file: v_rtn_stage_loc.sql
@v_rtn_stage_loc.sql
Prompt Running file: v_trans.sql
@v_trans.sql
Prompt Running file: v_research.sql
@v_research.sql
Prompt Running file: v_ob1rg.sql
@v_ob1rg.sql
Prompt Running file: v_ob1rh.sql
@v_ob1rh.sql
Prompt Running file: v_swms_session.sql
@v_swms_session.sql
Prompt Running file: v_dod_label_detail.sql
@v_dod_label_detail.sql
Prompt Running file: v_dod_label_detail_bckup.sql
@v_dod_label_detail_bckup.sql
Prompt Running file: trg_insupd_msku_pt_mixed_brow.sql
@trg_insupd_msku_pt_mixed_brow.sql
Prompt Running file: sts_build_route_external_proc.sql
@sts_build_route_external_proc.sql
Prompt Running file: sts_write_log_proc.sql
@sts_write_log_proc.sql
Prompt Running file: sts_populate_route_proc.sql
@sts_populate_route_proc.sql
Prompt Running file: sts_return_proc.sql
@sts_return_proc.sql
Prompt Running file: sts_package.sql
@sts_package.sql
Prompt Running file: trg_insupd_float_hist_brow.sql
@trg_insupd_float_hist_brow.sql
Prompt Running file: trg_del_cel_brow.sql
@trg_del_cel_brow.sql
Prompt Running file: trg_insdel_usr_arow.sql
@trg_insdel_usr_arow.sql
Prompt Running file: trg_insdel_reason_cds_arow.sql
@trg_insdel_reason_cds_arow.sql
Prompt Running file: trg_upd_pm_last_rec_date.sql
@trg_upd_pm_last_rec_date.sql
Prompt Running file: trg_ins_inv_brow.sql
@trg_ins_inv_brow.sql
Prompt Running file: trg_ins_erd_lpn_brow.sql
@trg_ins_erd_lpn_brow.sql
Prompt Running file: trg_ins_upc_info_arow.sql
@trg_ins_upc_info_arow.sql
Prompt Running file: trg_insupd_miniload_message.sql
@trg_insupd_miniload_message.sql                    
Prompt Running file: trg_insupd_cc.sql              
@trg_insupd_cc.sql                                  
Prompt Running file: trg_insupd_cc_edit.sql         
@trg_insupd_cc_edit.sql                             
Prompt Running file: trg_insupd_role_auth.sql
@trg_insupd_role_auth.sql                    
Prompt Running file: trg_insupd_swms_role.sql
@trg_insupd_swms_role.sql                    
Prompt Running file: v_ny1rb_1.sql
@v_ny1rb_1.sql                    
Prompt Running file: v_ny1rg.sql
@v_ny1rg.sql
Prompt Running file: v_ny1rh.sql
@v_ny1rh.sql
Prompt Running file: v_ny1rcde.sql
@v_ny1rcde.sql
Prompt Running file: v_stop_line_home.sql
@v_stop_line_home.sql
Prompt Running file: v_stop_line_floating.sql
@v_stop_line_floating.sql
Prompt Running file: v_stop_line_miniload.sql
@v_stop_line_miniload.sql
Prompt Running file: v_miniload_induction.sql
@v_miniload_induction.sql
Prompt Running file: pl_dmd_replenishment.sql
@pl_dmd_replenishment.sql
Prompt Running file: pl_dci.sql
@pl_dci.sql
Prompt Running file: pl_rcv_open_po_types.sql
@pl_rcv_open_po_types.sql
Prompt Running file: pl_rcv_open_po_cursors.sql
@pl_rcv_open_po_cursors.sql
Prompt Running file: pl_rcv_open_po_pallet_list.sql
@pl_rcv_open_po_pallet_list.sql
Prompt Running file: pl_rcv_open_po_matrix.sql
@pl_rcv_open_po_matrix.sql
Prompt Running file: pl_rcv_open_po_lr.sql
@pl_rcv_open_po_lr.sql
Prompt Running file: pl_rcv_open_po_find_slot.sql
@pl_rcv_open_po_find_slot.sql
Prompt Running file: pl_rcv_open_po_ml.sql
@pl_rcv_open_po_ml.sql
Prompt Running file: pl_acc_track.sql
@pl_acc_track.sql
Prompt Running file: pl_gen_batch.sql
@pl_gen_batch.sql
Prompt Running file: pl_utility.sql
@pl_utility.sql
Prompt Running file: pl_miniload_interface.sql
@pl_miniload_interface.sql
Prompt Running file: v_inv_at_induction_loc.sql
@v_inv_at_induction_loc.sql
Prompt Running file: gen_v_order_proc_syspars.sql
@gen_v_order_proc_syspars.sql
Prompt Running file: v_kvi_selected.sql
@v_kvi_selected.sql
Prompt Running file: v_kvi_short.sql
@v_kvi_short.sql
Prompt Running file: v_kvi_new.sql
@v_kvi_new.sql
Prompt Running file: v_equip_safety_hist.sql
@v_equip_safety_hist.sql
Prompt Running file: v_equip_safety_hist_unsafed.sql
@v_equip_safety_hist_unsafed.sql
Prompt Running file: v_sos_equipment.sql
@v_sos_equipment.sql
Prompt Running file: v_sos_batch_info.sql
@v_sos_batch_info.sql
Prompt Running file: v_sos_batch_info_short.sql
@v_sos_batch_info_short.sql                    
Prompt Running file: pl_sos.sql
@pl_sos.sql
Prompt Running file: v_slt_equip_log.sql
@v_slt_equip_log.sql
Prompt Running file: v_calc_time_total.sql
@v_calc_time_total.sql
Prompt Running file: v_lxli_exception.sql
@v_lxli_exception.sql
Prompt Running file: v_dock.sql
@v_dock.sql
Prompt Running file: v_whmove_valid_ml_ind_loc_item.sql
@v_whmove_valid_ml_ind_loc_item.sql
Prompt Running file: v_whmove_newloc.sql
@v_whmove_newloc.sql
Prompt Running file: trg_insupd_sos_batch_brow.sql
@trg_insupd_sos_batch_brow.sql                    
Prompt Running file: v_las_pallet.sql
@v_las_pallet.sql                    
Prompt Running file: v_vsn_summary.sql
@v_vsn_summary
Prompt Running file: pl_nos.sql
@pl_nos.sql
Prompt Running file: pl_nos_reassign.sql
@pl_nos_reassign.sql
Prompt Running file: pl_ml_dec.sql
@pl_ml_dec.sql
Prompt Running file: pl_ml_enc.sql
@pl_ml_enc.sql                    
Prompt Running file: pl_ml_split.sql
@pl_ml_split.sql                    
Prompt Running file: pl_ml_merge.sql
@pl_ml_merge.sql                    
Prompt Running file: pl_ml_config.sql
@pl_ml_config.sql                    
Prompt Running file: pl_wh_move_utilities.sql
@pl_wh_move_utilities.sql
Prompt Running file: trg_insupd_enc_mnl.sql
@trg_insupd_enc_mnl.sql
Prompt Running file: trg_insupd_pm_astmt.sql
@trg_insupd_pm_astmt.sql                    
Prompt Running file: trg_insupddel_sos_usr_arow.sql
@trg_insupddel_sos_usr_arow.sql                    
Prompt Running file: trg_insupddel_usr_brow.sql
@trg_insupddel_usr_brow.sql                    
Prompt Running file: trg_insupddel_usrauth_brow.sql
@trg_insupddel_usrauth_brow.sql                    
Prompt Running file: trg_insupd_hdo_whmove_brow.sql
@trg_insupd_hdo_whmove_brow.sql                    
Prompt Running file: trg_upd_ord_cool_brow.sql
@trg_upd_ord_cool_brow.sql                    
Prompt Running file: v_sls_equipment.sql
@v_sls_equipment.sql                    
Prompt Running file: v_las_truck_sort.sql
@v_las_truck_sort.sql                    
Prompt Running file: v_sls_loader.sql
@v_sls_loader.sql                    
Prompt Running file: v_truck_accessory_acctype.sql
@v_truck_accessory_acctype.sql                    
Prompt Running file: v_truck_accessory_ship_date.sql
@v_truck_accessory_ship_date.sql                    
Prompt Running file: v_truck_accessory_truck.sql
@v_truck_accessory_truck.sql                    
Prompt Running file: v_truck_accessory_user.sql
@v_truck_accessory_user.sql                    
Prompt Running file: v_truck_accessory.sql
@v_truck_accessory.sql                    
Prompt Running file: v_rp1rk.sql
@v_rp1rk.sql                    
Prompt Running file: v_pn1ra.sql
@v_pn1ra.sql
Prompt Running file: v_pn1ra_select.sql
@v_pn1ra_select.sql
Prompt Running file: v_pn1rb.sql
@v_pn1rb.sql
Prompt Running file: pl_sos_sls_lm.sql
@pl_sos_sls_lm.sql                    
Prompt Running file: pl_planned_order.sql
@pl_planned_order.sql                    
Prompt Running file: trg_sts_dataload.sql
@trg_sts_dataload.sql
Prompt Running file: trg_upd_returns.sql
@trg_upd_returns.sql
Prompt Running file: v_ml_replen_info.sql   
@v_ml_replen_info.sql                       
Prompt Running file: v_ml_reserve_info.sql  
@v_ml_reserve_info.sql                      
Prompt Running file: v_ml_spl_rpl_info.sql
@v_ml_spl_rpl_info.sql
Prompt Running file: v_ml_rcv_dest_loc.sql
@v_ml_rcv_dest_loc.sql
Prompt Running file: pl_swms_error_codes.sql
@pl_swms_error_codes.sql                    
Prompt Running file: pl_ml_repl.sql         
@pl_ml_repl.sql                             
Prompt Running file: pl_ml_repl_rf.sql      
@pl_ml_repl_rf.sql                          
Prompt Running file: pl_sap_interfaces.sql
@pl_sap_interfaces.sql
Prompt Running file: pl_syntelic_interfaces.sql
@pl_syntelic_interfaces.sql
Prompt Running file: pl_cubitron_interfaces.sql
@pl_cubitron_interfaces.sql
Prompt Running file: pl_swms_execute_sql.sql
@pl_swms_execute_sql.sql
Prompt Running file: pl_ndr.sql
@pl_ndr.sql
Prompt Running file: pl_equip_out.sql
@pl_equip_out.sql
Prompt Running file: trg_ins_sap_cs_in_brow.sql
@trg_ins_sap_cs_in_brow.sql
Prompt Running file: trg_ins_sap_pm_misc_in_arow.sql
@trg_ins_sap_pm_misc_in_arow.sql
Prompt Running file: sts_equipment_update_proc.sql
@sts_equipment_update_proc.sql
Prompt Running file: trg_upd_route_arow.sql
@trg_upd_route_arow.sql
Prompt Running file: trg_equip_safety_hist_arow.sql
@trg_equip_safety_hist_arow.sql
Prompt Running file: trg_ins_swms_log_arow.sql
@trg_ins_swms_log_arow.sql
Prompt Running file: trg_ins_upd_container_arow.sql
@trg_ins_upd_container_arow.sql
Prompt Running file: trg_ins_upd_cr_arow.sql
@trg_ins_upd_cr_arow.sql
Prompt Running file: trg_ins_upd_cs_arow.sql
@trg_ins_upd_cs_arow.sql
Prompt Running file: trg_ins_upd_cu_arow.sql
@trg_ins_upd_cu_arow.sql
Prompt Running file: trg_ins_upd_equip_arow.sql
@trg_ins_upd_equip_arow.sql
Prompt Running file: trg_ins_upd_equip.sql
@trg_ins_upd_equip.sql
Prompt Running file: trg_ins_upd_ia_arow.sql
@trg_ins_upd_ia_arow.sql
Prompt Running file: trg_ins_upd_im_arow.sql
@trg_ins_upd_im_arow.sql
Prompt Running file: trg_ins_upd_mf_arow.sql
@trg_ins_upd_mf_arow.sql
Prompt Running file: trg_ins_upd_ml_arow.sql
@trg_ins_upd_ml_arow.sql
Prompt Running file: trg_ins_upd_or_arow.sql
@trg_ins_upd_or_arow.sql
Prompt Running file: trg_ins_upd_ow_arow.sql
@trg_ins_upd_ow_arow.sql
Prompt Running file: trg_ins_upd_po_arow.sql
@trg_ins_upd_po_arow.sql
Prompt Running file: trg_ins_upd_rt_arow.sql
@trg_ins_upd_rt_arow.sql
Prompt Running file: trg_ins_upd_sn_arow.sql
@trg_ins_upd_sn_arow.sql
Prompt Running file: trg_ins_upd_wh_arow.sql
@trg_ins_upd_wh_arow.sql
Prompt Running file: trg_insupd_batch_brow.sql
@trg_insupd_batch_brow.sql
Prompt Running file: trg_insupd_cubi_itemmaster.sql
@trg_insupd_cubi_itemmaster.sql
Prompt Running file: trg_insupd_cubi_measurement.sql
@trg_insupd_cubi_measurement.sql
Prompt Running file: trg_insupd_synt_loadmapping.sql
@trg_insupd_synt_loadmapping.sql
Prompt Running file: trg_insert_sap_po_in_brow.sql
@trg_insert_sap_po_in_brow.sql
Prompt Running file: pl_format_rf_version.sql
@pl_format_rf_version.sql
Prompt Running file: v_rf_client_version.sql
@v_rf_client_version.sql
Prompt Running file: daily_inv_hist_vw.sql
@daily_inv_hist_vw.sql
Prompt Running file: v_rp1rc.sql
@v_rp1rc.sql
Prompt Running file: v_rp1spa.sql
@v_rp1spa.sql
Prompt Running file: v_ordcw.sql
@v_ordcw.sql
Prompt Running file: 33527_trg_DU_fs_inbound_brow.sql
@33527_trg_DU_fs_inbound_brow.sql
Prompt Running file: trg_ins_fs_inbound_arow.sql
@trg_ins_fs_inbound_arow.sql
Prompt Running file: trg_insupd_haccp_codes_temp.sql
@trg_insupd_haccp_codes_temp.sql
Prompt Running file: trg_insupd_pm_hazardous.sql
@trg_insupd_pm_hazardous.sql
Prompt Running file: trg_ins_manifest_stops_brow.sql
@trg_ins_manifest_stops_brow.sql
Prompt Running file: trg_insupd_miniload_order.sql        
@trg_insupd_miniload_order.sql                            
Prompt Running file: pl_rf.sql
@pl_rf.sql
Prompt Running file: pl_rf_stk_status.sql
@pl_rf_stk_status.sql
Prompt Running file: pl_rf_print_lp.sql
@pl_rf_print_lp.sql
Prompt Running file: soap_api.sql
@soap_api.sql
Prompt Running file: pl_rf_matrix_replen_list.sql
@pl_rf_matrix_replen_list.sql
Prompt Running file: pl_rf_matrix_replen_pick.sql
@pl_rf_matrix_replen_pick.sql
Prompt Running file: pl_rf_matrix_replen_drop.sql
@pl_rf_matrix_replen_drop.sql
Prompt Running file: pl_rf_matrix_replen_common.sql
@pl_rf_matrix_replen_common.sql
Prompt Running file: pl_rf_item_master.sql
@pl_rf_item_master.sql
Prompt Running file: pl_rf_one_sided_adj.sql
@pl_rf_one_sided_adj.sql
Prompt Running file: pl_mx_gen_label.sql
@pl_mx_gen_label.sql
Prompt Running file: pl_mx_stg_to_swms.sql
@pl_mx_stg_to_swms.sql
Prompt Running file: pl_mx_swms_to_pm_out.sql
@pl_mx_swms_to_pm_out.sql
Prompt Running file: pl_matrix_repl.sql
@pl_matrix_repl.sql
Prompt Running file: pl_symbotic_alerts.sql
@pl_symbotic_alerts.sql
Prompt Running file: pl_mx_inv_sync.sql
@pl_mx_inv_sync.sql
Prompt Running file: pl_op_pick_zone.sql
@pl_op_pick_zone.sql
Prompt Running file: pl_libswmslm.sql
@pl_libswmslm.sql
Prompt Running file: v_matrix_replen_list.sql   
@v_matrix_replen_list.sql                       
Prompt Running file: v_matrix_reserve_info.sql  
@v_matrix_reserve_info.sql                      
Prompt Running file: v_matrix_splithome_info.sql
@v_matrix_splithome_info.sql                    
Prompt Running file: v_matrix_open_homeslot.sql 
@v_matrix_open_homeslot.sql                    
Prompt Running file: trg_ins_upd_del_pm.sql
@trg_ins_upd_del_pm.sql
Prompt Running file: trg_ins_upd_del_pm_upc.sql
@trg_ins_upd_del_pm_upc.sql
Prompt Running file: trg_ins_upd_mx_in.sql
@trg_ins_upd_mx_in.sql
Prompt Running file: trg_ins_upd_mx_out.sql
@trg_ins_upd_mx_out.sql
Prompt Running file: trg_ins_upd_mx_pm_out.sql
@trg_ins_upd_mx_pm_out.sql
Prompt Running file: trg_ins_upd_mx_pm_bulk_out.sql
@trg_ins_upd_mx_pm_bulk_out.sql                    
Prompt Running file: trg_upd_pm_chk_elg.sql        
@trg_upd_pm_chk_elg.sql
Prompt Running file: pl_mx_gen_label.sql
@pl_mx_gen_label.sql
Prompt Running file: v_mi1rf.sql      
@v_mi1rf.sql                          
Prompt Running file: v_matrix_area.sql
@v_matrix_area.sql
Prompt Running file: pl_matrix_eligible.sql
@pl_matrix_eligible.sql
Prompt Running file: pl_matrix_repl.sql
@pl_matrix_repl.sql
Prompt Running file: v_stop_line_matrix.sql
@v_stop_line_matrix.sql                    
Prompt Running file: pl_vr_matrix_eligible.sql
@pl_vr_matrix_eligible.sql
Prompt Running file: pl_digisign.sql
@pl_digisign.sql
Prompt Running file: pl_event.sql
@pl_event.sql
Prompt Running file: pl_short.sql
@pl_short.sql
Prompt Running file: trg_ins_upd_mx_inv_bulk_in.sql
@trg_ins_upd_mx_inv_bulk_in.sql
Prompt Running Trigger: trg_upd_matrix_maint.sql
@/swms/curr/schemas/trg_upd_matrix_maint.sql
Prompt Running Trigger: trg_ins_ordcw.sql
@/swms/curr/schemas/trg_ins_ordcw.sql
Prompt Running file: v_rp4rb.sql
@/swms/curr/schemas/v_rp4rb.sql
Prompt Running file: v_putaway_complete.sql
@/swms/curr/schemas/v_putaway_complete.sql
Prompt Running file: pl_short.sql
@/swms/curr/schemas/pl_short.sql
Prompt Running file: v_tmp_weight.sql
@v_tmp_weight.sql
Prompt Running file: trg_ins_pm_arow.sql
@trg_ins_pm_arow.sql                    
Prompt Running file: trg_del_pm_brow.sql
@trg_del_pm_brow.sql
Prompt Running file: pl_sts_interfaces.sql
@pl_sts_interfaces.sql
Prompt Running file: pl_auto_route_close.sql
@pl_auto_route_close.sql
Prompt Running file: pl_dod_label_gen.sql
@pl_dod_label_gen.sql
Prompt Running file: pl_cross_dock_order_processing.sql
@pl_cross_dock_order_processing.sql
Prompt Running file: f_get_short_user.sql
@f_get_short_user.sql
Prompt Running file: v_available_inv.sql
@v_available_inv.sql
Prompt Running file: v_sos_short.sql
@v_sos_short.sql
Prompt Running file: pl_matrix_sys06.sql
@pl_matrix_sys06.sql
Prompt Running file: pl_rf_sys06_case_removal.sql
@pl_rf_sys06_case_removal.sql
Prompt Running file: pl_lxli_file_gen.sql
@pl_lxli_file_gen.sql
Prompt Running file: pl_dbms_host_command_func.sql
@pl_dbms_host_command_func.sql
Prompt Running file: load_blob_table_proc.sql
@load_blob_table_proc.sql                    
Prompt Running file: pl_queue_ops.sql
@pl_queue_ops.sql                    
Prompt Running file: pl_text_log.sql
@pl_text_log.sql                    

Prompt Running file: trg_upd_dod_detail_brow.sql
@trg_upd_dod_detail_brow.sql
Prompt Running file: trg_upd_dod_detail_bckup_brow.sql
@trg_upd_dod_detail_bckup_brow.sql
Prompt Running file: trg_ins_upd_staging_hdr.sql
@trg_ins_upd_staging_hdr.sql
Prompt Running file: trg_upd_goaltime_in.sql
@trg_upd_goaltime_in.sql                    
Prompt Running file: trg_upd_staging_fkh.sql
@trg_upd_staging_fkh.sql                    
Prompt Running file: trg_upd_staging_fki.sql
@trg_upd_staging_fki.sql                    
Prompt Running file: trg_upd_staging_ld.sql
@trg_upd_staging_ld.sql                    
Prompt Running file: trg_upd_staging_sl.sql
@trg_upd_staging_sl.sql                    
Prompt Running file: pl_weight_validation.sql
@pl_weight_validation.sql
Prompt Running file: type_pallet_id_list_rec.sql
@type_pallet_id_list_rec.sql
Prompt Running file: type_rf_live_receiving.sql
@type_rf_live_receiving.sql
rem Prompt Running file: type_rf_log.sql
rem @type_rf_log.sql
Prompt Running file: type_sos_short.sql
@type_sos_short.sql
Prompt Running file: pl_StringTranslation.sql
@pl_StringTranslation.sql
Prompt Running file: pl_rcv_print_po.sql
@pl_rcv_print_po.sql
Prompt Running file: pl_rf_caching.sql
@pl_rf_caching.sql
Prompt Running file: pl_rf_live_receiving.sql
@pl_rf_live_receiving.sql
Prompt Running file: pl_trg_dor_trans.sql
@pl_trg_dor_trans.sql
Prompt Running file: sts_route_status_trg.sql
@sts_route_status_trg.sql
Prompt Running file: trg_del_ordd_brow.sql
@trg_del_ordd_brow.sql
Prompt Running file: trg_ins_planned_order_dtl.sql
@trg_ins_planned_order_dtl.sql
Prompt Running file: trg_ins_upd_chk_po_pm.sql
@trg_ins_upd_chk_po_pm.sql
Prompt Running file: trg_ins_upd_lm_arow.sql
@trg_ins_upd_lm_arow.sql
Prompt Running file: trg_insupd_planned_order_hdr.sql
@trg_insupd_planned_order_hdr.sql
Prompt Running file: trg_swms_upd_whmveloc_hist.sql
@trg_swms_upd_whmveloc_hist.sql
Prompt Running file: trg_upd_ordcw_brow.sql
@trg_upd_ordcw_brow.sql
Prompt Running file: trig_insupd_enc_mnl.sql
@trig_insupd_enc_mnl.sql
Prompt Running file: v_batch_reseq_flag.sql
@v_batch_reseq_flag.sql
Prompt Running file: trg_del_lxli_staging_hdr_out.sql
@trg_del_lxli_staging_hdr_out.sql
Prompt Running file: v_ob1ra.sql
@v_ob1ra.sql
Prompt Running file: v_ob1rf.sql
@v_ob1rf.sql
Prompt Running file: v_pavpa.sql
@v_pavpa.sql
Prompt Running file: v_pick_slots.sql
@v_pick_slots.sql
Prompt Running file: v_pn2ra.sql
@v_pn2ra.sql
Prompt Running file: v_resrv_slots.sql
@v_resrv_slots.sql
Prompt Running file: v_rp1rb.sql
@v_rp1rb.sql
Prompt Running file: v_rp1rn.sql
@v_rp1rn.sql
Prompt Running file: v_slstrd.sql
@v_slstrd.sql
Prompt Running file: weekly_pick_hist_vw.sql
@weekly_pick_hist_vw.sql
Prompt Running file: pl_spl_cu_in.sql            
@pl_spl_cu_in.sql             
Prompt Running file: pl_spl_im_in.sql            
@pl_spl_im_in.sql             
Prompt Running file: pl_spl_po_in.sql            
@pl_spl_po_in.sql             
Prompt Running file: pl_spl_or_in.sql            
@pl_spl_or_in.sql             
Prompt Running file: pl_spl_mf_in.sql
@pl_spl_mf_in.sql                    
Prompt Running file: pl_spl_out.sql              
@pl_spl_out.sql               
rem Prompt Running file: pl_spl_send_receive_msgs.sql
rem @pl_spl_send_receive_msgs.sql 
Prompt Running file: trg_ins_upd_mq_queue_in.sql 
@trg_ins_upd_mq_queue_in.sql  
Prompt Running file: trg_ins_upd_mq_queue_out.sql
@trg_ins_upd_mq_queue_out.sql 
Prompt Running file: trg_upd_mq_maint.sql        
@trg_upd_mq_maint.sql         
Prompt Running file: pl_spl_cs_in.sql        
@pl_spl_cs_in.sql         
Prompt Running file: pl_spl_ml_in.sql        
@pl_spl_ml_in.sql         
Prompt Running file: pl_spl_in.sql
@pl_spl_in.sql
Prompt Running file: trg_upd_sys_config_arow.sql
@trg_upd_sys_config_arow.sql                    
Prompt Running file: pl_xml_sts_route_in.sql
@pl_xml_sts_route_in.sql                    
Prompt Running file: pl_rf_build_master_lp.sql
@pl_rf_build_master_lp.sql                    
Prompt Running file: pl_swms_sts_routeout.sql
@pl_swms_sts_routeout.sql                    
Prompt Running file: trg_del_inbound_cust_brow.sql
@trg_del_inbound_cust_brow.sql                    
Prompt Running file: trg_ins_upd_inbound_cust_arow.sql
@trg_ins_upd_inbound_cust_arow.sql                    
Prompt Running file: R30_6_7_DDL_Jira1669_trg_inv_cases.sql
@R30_6_7_DDL_Jira1669_trg_inv_cases.sql                    
Prompt Running file: R30_6_7_DDL_Jira1669_trg_inv_del.sql
@R30_6_7_DDL_Jira1669_trg_inv_del.sql                    
Prompt Running file: R30_6_7_DDL_Jira1669_trg_inv_upd.sql
@R30_6_7_DDL_Jira1669_trg_inv_upd.sql                    
Prompt Running file: trg_ins_gs1_finish_good_in.sql
@trg_ins_gs1_finish_good_in.sql                    
Prompt Running file: R30_6_7_DDL_trg_sts_route_out_ins.sql
@R30_6_7_DDL_trg_sts_route_out_ins.sql                    
Prompt Running file: R30_6_7_DDL_Jira2170_trg_ordm.sql
@R30_6_7_DDL_Jira2170_trg_ordm.sql                    
Prompt Running file: v_stop_detail.sql
@v_stop_detail.sql 
Prompt Running file: pl_ups_float_detail.sql
@pl_ups_float_detail.sql 
Prompt Running file: pl_meat_rcv.sql
@pl_meat_rcv.sql 
Prompt Running file: pl_rcv_po_close.sql
@pl_rcv_po_close.sql
Prompt Running file: pl_rcv_cross_dock.sql
@pl_rcv_cross_dock.sql 
Prompt Running file: pl_cmu_ins_cross_dock.sql
@pl_cmu_ins_cross_dock.sql                    
Prompt Running file: pl_rpt_order_status.sql
@pl_rpt_order_status.sql                    
Prompt Running file: pl_types_for_cmu_inv_report.sql
@pl_types_for_cmu_inv_report.sql                    
Prompt Running file: pl_cmu_inv_stgng_rpt.sql
@pl_cmu_inv_stgng_rpt.sql                    
Prompt Running file: trg_ins_sn_header_cmpnd.sql
@trg_ins_sn_header_cmpnd.sql                    
Prompt Running file: trg_upd_inv_cmpnd.sql
@trg_upd_inv_cmpnd.sql                    
Prompt Running file: pl_call_rest.sql
@pl_call_rest.sql                    
Prompt Running file: pl_get_doc_id.sql
@pl_get_doc_id.sql                    
Prompt Running file: pl_sts_pod_interface_in.sql
@pl_sts_pod_interface_in.sql                    
Prompt Running file: trg_insupd_sap_ml_in_brow.sql
@trg_insupd_sap_ml_in_brow.sql                    
Prompt Running file: trg_ins_manifests_arow.sql
@trg_ins_manifests_arow.sql                    
Prompt Running file: kill_session_proc.sql
@kill_session_proc.sql 
                   
PROMPT *** RUNNING RF Modules for R41.0 ***
Prompt     Running Iteration 1:
Prompt Running line9: pl_text_log.sql
@pl_text_log.sql                      
Prompt Running line10: type_rf_chkin_req.sql
@type_rf_chkin_req.sql
Prompt Running line11: pl_check_upc.sql
@pl_check_upc.sql
Prompt Running line12: pl_rf_chkin_req.sql
@pl_rf_chkin_req.sql
Prompt Running line13: type_rf_chkin_upd.sql
@type_rf_chkin_upd.sql
Prompt Running line14: pl_rf_chkin_upd.sql
@pl_rf_chkin_upd.sql
Prompt Running line15: type_rf_tm_close_receipt.sql
@type_rf_tm_close_receipt.sql                   
Prompt Running line16: pl_rf_tm_close_receipt.sql
@pl_rf_tm_close_receipt.sql
Prompt Running line17: type_rf_calc_avw.sql
@type_rf_calc_avw.sql                   
Prompt Running line18: pl_rf_calc_avw.sql
@pl_rf_calc_avw.sql                   
Prompt Running line19: type_lm_distance_obj.sql
@type_lm_distance_obj.sql
Prompt Running line20: type_lm_goaltime.sql
@type_lm_goaltime.sql
Prompt Running line21: type_rf_putaway.sql
@type_rf_putaway.sql
Prompt Running line22: lmf.sql
@lmf.sql
Prompt Running line23: pl_rf_lm_common.sql
@pl_rf_lm_common.sql
Prompt Running line24: pl_lm_goal_pb.sql
@pl_lm_goal_pb.sql
Prompt Running line25: pl_lm_goal_dd.sql
@pl_lm_goal_dd.sql
Prompt Running line26: pl_lm_goal_di.sql
@pl_lm_goal_di.sql
Prompt Running line27: pl_lm_goal_fl.sql
@pl_lm_goal_fl.sql
Prompt Running line28: pl_lm_goaltime.sql
@pl_lm_goaltime.sql
Prompt Running line29: pl_lm_distance.sql
@pl_lm_distance.sql
Prompt Running line30: pl_lm_forklift.sql
@pl_lm_forklift.sql
Prompt Running line31: pl_rf_lm_common.sql
@pl_rf_lm_common.sql
Prompt Running line32: pl_lm_goal_pb.sql
@pl_lm_goal_pb.sql
Prompt Running line33: pl_lm_goal_dd.sql
@pl_lm_goal_dd.sql
Prompt Running line34: pl_lm_goal_di.sql
@pl_lm_goal_di.sql
Prompt Running line35: pl_lm_goal_fl.sql
@pl_lm_goal_fl.sql
Prompt Running line36: pl_lm_goaltime.sql
@pl_lm_goaltime.sql
Prompt Running line37: pl_lm_distance.sql
@pl_lm_distance.sql
Prompt Running line38: pl_lm_forklift.sql
@pl_lm_forklift.sql
Prompt Running line39: pl_rf_putaway.sql
@pl_rf_putaway.sql
Prompt Running line40: type_rf_pre_putaway.sql
@type_rf_pre_putaway.sql
Prompt Running line41: pl_batch_download.sql
@pl_batch_download.sql
Prompt Running line42: pl_returns_lm_bats.sql
@pl_returns_lm_bats.sql
Prompt Running line43: pl_rf_pre_putaway.sql
@pl_rf_pre_putaway.sql
Prompt Running line44: type_rf_validate.sql
@type_rf_validate.sql
Prompt Running line45: pl_rf_validate.sql
@pl_rf_validate.sql
Prompt Running line46: type_msku_objects.sql
@type_msku_objects.sql
Prompt Running line47: pl_rf_process_msku.sql
@pl_rf_process_msku.sql
Prompt Running line48: type_food_safety_objects.sql
@type_food_safety_objects.sql
Prompt Running line49: pl_rf_foodsafety.sql
@pl_rf_foodsafety.sql

PROMPT *** RUNNING APP Modules for R41.0 ***
Prompt Running line53: pl_dbms_host_command_ext.sql
@pl_dbms_host_command_ext.sql
Prompt Running line54: pl_dbms_host_command.sql
@pl_dbms_host_command.sql
Prompt Running line55: type_c_prams_list.sql
@type_c_prams_list.sql
Prompt Running line56: pl_split_prams.sql
@pl_split_prams.sql
Prompt Running line57: pl_rcv_po_close.sql
@pl_rcv_po_close.sql
Prompt Running line58: pl_api.sql
@pl_api.sql
Prompt Running line59: pl_one_pallet_label.sql
@pl_one_pallet_label.sql
Prompt Running line60: pl_demand_pallet.sql
@pl_demand_pallet.sql
Prompt Running line61: pl_one_pallet_label.sql
@pl_one_pallet_label.sql                      
Prompt Running line62: pl_demand_pallet.sql
@pl_demand_pallet.sql                      
Prompt Running line63: pl_rcv_po_open.sql
@pl_rcv_po_open.sql
Prompt Running line64: pl_run_worksheet.sql
@pl_run_worksheet.sql
Prompt Running line65: pl_confirm_putaway.sql
@pl_confirm_putaway.sql
Prompt Running line66: pl_receive_return.sql
@pl_receive_return.sql

PROMPT *** RUNNING APP Modules for R42.0 ***   
Prompt Running: type_rf_sos_sls_equip_check.sql
@type_rf_sos_sls_equip_check.sql               
Prompt Running: pl_rf_sos_sls_equip_check.sql  
@pl_rf_sos_sls_equip_check.sql                 
Prompt Running: type_rf_stk_trsfer_obj.sql     
@type_rf_stk_trsfer_obj.sql                    
Prompt Running: pl_rf_stk_trsfer.sql           
@pl_rf_stk_trsfer.sql                          
Prompt Running: type_collect_upc_obj.sql       
@type_collect_upc_obj.sql                      
Prompt Running: pl_rf_collect_upc.sql          
@pl_rf_collect_upc.sql                         
Prompt Running: type_rf_cte_cc_tsk.sql         
@type_rf_cte_cc_tsk.sql                        
Prompt Running: pl_rf_cte_cc_tsk.sql           
@pl_rf_cte_cc_tsk.sql                          
Prompt Running: type_rf_upd_cc_tsk.sql         
@type_rf_upd_cc_tsk.sql                        
Prompt Running: pl_rf_upd_cc_tsk.sql         
@pl_rf_upd_cc_tsk.sql                        
Prompt Running: type_rf_req_cc_area.sql      
@type_rf_req_cc_area.sql                     
Prompt Running: pl_rf_req_cc_area.sql        
@pl_rf_req_cc_area.sql                       
Prompt Running: type_rf_req_cc_grup.sql      
@type_rf_req_cc_grup.sql                     
Prompt Running: pl_rf_req_cc_grup.sql        
@pl_rf_req_cc_grup.sql                       
Prompt Running: type_rf_req_cc_slot.sql      
@type_rf_req_cc_slot.sql                     
Prompt Running: pl_rf_req_cc_slot.sql        
@pl_rf_req_cc_slot.sql                       
Prompt Running: type_rf_req_cc_tsk.sql       
@type_rf_req_cc_tsk.sql                      
Prompt Running: pl_rf_req_cc_tsk.sql         
@pl_rf_req_cc_tsk.sql                        
Prompt Running: type_rf_upd_mnl_pk_client.sql
@type_rf_upd_mnl_pk_client.sql               
Prompt Running: pl_rf_upd_mnl_pk.sql         
@pl_rf_upd_mnl_pk.sql                        
Prompt Running: pl_lm_fork.sql             
@pl_lm_fork.sql                            
Prompt Running: pl_reset_task.sql          
@pl_reset_task.sql                         
Prompt Running: pl_create_ndm.sql          
@pl_create_ndm.sql                         
Prompt Running: pl_rf_swap_common.sql
@pl_rf_swap_common.sql               
Prompt Running: pl_rf_replen_list.sql      
@pl_rf_replen_list.sql                     
Prompt Running: type_rf_replen_pick.sql    
@type_rf_replen_pick.sql                   
Prompt Running: pl_rf_replen_pick.sql      
@pl_rf_replen_pick.sql                     
Prompt Running: pl_update_scan_function.sql
@pl_update_scan_function.sql               
Prompt Running: type_rf_replen_drop.sql    
@type_rf_replen_drop.sql                   
Prompt Running: pl_rf_replen_drop.sql      
@pl_rf_replen_drop.sql                     
Prompt Running: type_rf_bulk_to_home.sql   
@type_rf_bulk_to_home.sql                  
Prompt Running: pl_rf_bulk_to_home.sql     
@pl_rf_bulk_to_home.sql                    
Prompt Running: type_rf_bulk_to_door.sql
@type_rf_bulk_to_door.sql               
Prompt Running: pl_rf_bulk_to_door.sql  
@pl_rf_bulk_to_door.sql                 
Prompt Running: type_rf_bulk_cw_list.sql
@type_rf_bulk_cw_list.sql               
Prompt Running: pl_rf_bulk_cw_list.sql  
@pl_rf_bulk_cw_list.sql                 
Prompt Running: type_rf_bulk_cw_upd.sql 
@type_rf_bulk_cw_upd.sql                
Prompt Running: pl_rf_bulk_cw_upd.sql   
@pl_rf_bulk_cw_upd.sql                  
Prompt Running: type_rf_bulk_cw_ovw.sql 
@type_rf_bulk_cw_ovw.sql                
Prompt Running: pl_rf_bulk_cw_ovw.sql   
@pl_rf_bulk_cw_ovw.sql                  
Prompt Running: type_rf_stk_swap.sql    
@type_rf_stk_swap.sql                   
Prompt Running: pl_rf_stk_swap.sql      
@pl_rf_stk_swap.sql                     
Prompt Running: pl_rf_swap_common.sql      
@pl_rf_swap_common.sql                     
Prompt Running: pl_rf_swap_drop.sql      
@pl_rf_swap_drop.sql                     
Prompt Running: pl_rf_swap_pick.sql      
@pl_rf_swap_pick.sql                     
Prompt Running: pl_tp_cte_cc.sql        
@pl_tp_cte_cc.sql                       
Prompt Running: pl_rf_rel_cc_task.sql
@pl_rf_rel_cc_task.sql               

PROMPT *** RUNNING APP Modules for R43.0 ***
Prompt Running: type_rf_process_mf.sql
@type_rf_process_mf.sql               
Prompt Running: pl_dci_common.sql     
@pl_dci_common.sql                    
Prompt Running: type_rf_wh_move.sql
@type_rf_wh_move.sql
Prompt Running: pl_rf_wh_move.sql
@pl_rf_wh_move.sql
Prompt Running: type_rf_req_mnl_area.sql
@type_rf_req_mnl_area.sql
Prompt Running: pl_rf_req_mnl_area.sql
@pl_rf_req_mnl_area.sql
Prompt Running: type_rf_req_mnl_aisle.sql
@type_rf_req_mnl_aisle.sql
Prompt Running: pl_rf_req_mnl_aisle.sql
@pl_rf_req_mnl_aisle.sql
Prompt Running: type_rf_req_mnl_dr.sql
@type_rf_req_mnl_dr.sql
Prompt Running: pl_rf_req_mnl_dr.sql
@pl_rf_req_mnl_dr.sql
Prompt Running: type_rf_upd_mnl_pb_client.sql
@type_rf_upd_mnl_pb_client.sql
Prompt Running: pl_rf_upd_mnl_pb.sql
@pl_rf_upd_mnl_pb.sql
Prompt Running: type_rf_inv_dmg_dtls.sql
@type_rf_inv_dmg_dtls.sql
Prompt Running: pl_rf_inv_dmg_dtls.sql
@pl_rf_inv_dmg_dtls.sql
Prompt Running: type_rf_adj_status_obj.sql
@type_rf_adj_status_obj.sql
Prompt Running: pl_rf_adj_status.sql
@pl_rf_adj_status.sql
Prompt Running: type_rf_req_adj_qty.sql
@type_rf_req_adj_qty.sql
Prompt Running: pl_rf_req_adj_qty.sql
@pl_rf_req_adj_qty.sql
Prompt Running: type_rf_upd_adj_qty.sql
@type_rf_upd_adj_qty.sql
Prompt Running: pl_rf_upd_adj_qty.sql
@pl_rf_upd_adj_qty.sql
Prompt Running: type_rf_req_hst_loc_obj.sql
@type_rf_req_hst_loc_obj.sql
Prompt Running: pl_rf_req_hst_loc.sql
@pl_rf_req_hst_loc.sql
Prompt Running: type_rf_task_assign_obj.sql
@type_rf_task_assign_obj.sql
Prompt Running: pl_rf_task_assign.sql
@pl_rf_task_assign.sql
Prompt Running: type_rf_sls_data_req_obj.sql
@type_rf_sls_data_req_obj.sql
Prompt Running: pl_rf_sls_data_req.sql
@pl_rf_sls_data_req.sql
Prompt     Running Extra Iteration 3: App Modules
Prompt Running: pl_bulk_pull.sql
@pl_bulk_pull.sql
Prompt Running: pl_combin_pull.sql
@pl_combin_pull.sql
Prompt Running: type_gen_float.sql
@type_gen_float.sql
Prompt Running: pl_gen_float.sql
@pl_gen_float.sql
Prompt Running: pl_allocate_inv.sql
@pl_allocate_inv.sql
Prompt Running: pl_gen_batch2.sql
@pl_gen_batch2.sql
Prompt Running: pl_crt_lbr_mgmt_bats.sql
@pl_crt_lbr_mgmt_bats.sql
Prompt Running: pl_order_proc.sql
@pl_order_proc.sql
Prompt Running: pl_crt_order_proc.sql
@pl_crt_order_proc.sql
Prompt Running: pl_recover_lbr_mgmt_bats.sql
@pl_recover_lbr_mgmt_bats.sql
Prompt Running: pl_order_recovery.sql
@pl_order_recovery.sql
Prompt Running: pl_awm.sql
@pl_awm.sql
Prompt     Running Iteration 3: Scheduler Modules
Prompt Running: pl_swms_purge_orders.sql
@pl_swms_purge_orders.sql
Prompt Running: pl_purge_stagetable.sql
@pl_purge_stagetable.sql
Prompt Running: pl_aged_item_check.sql
@pl_aged_item_check.sql

PROMPT *** RUNNING Modules for R44.0 ***
Prompt Running: pl_rf_dci_pod.sql
@pl_rf_dci_pod.sql
Prompt Running: type_rf_dci_pod.sql
@type_rf_dci_pod.sql
Prompt Running: pl_rf_sleeve_sel.sql
@pl_rf_sleeve_sel.sql
Prompt Running: pl_sleeve_sel.sql
@pl_sleeve_sel.sql
Prompt Running: pl_rf_dci_fst_qry.sql
@pl_rf_dci_fst_qry.sql
Prompt Running: pl_rf_dci_fst_upd.sql
@pl_rf_dci_fst_upd.sql
Prompt Running: pl_rf_process_truck_accessory.sql
@pl_rf_process_truck_accessory.sql
Prompt Running: pl_rf_tmlog_in_out.sql
@pl_rf_tmlog_in_out.sql
Prompt Running: type_dci_fst_upd.sql
@type_dci_fst_upd.sql
Prompt Running: type_rf_dci_fst_qry.sql
@type_rf_dci_fst_qry.sql
Prompt Running: type_rf_process_truck_accessory.sql
@type_rf_process_truck_accessory.sql
Prompt Running: type_rf_tm_login.sql
@type_rf_tm_login.sql
Prompt Running: pl_lxli_batch.sql

PROMPT *** RUNNING Modules for R45.0 ***

Prompt Running: type_rf_sos_batchsel.sql
@type_rf_sos_batchsel.sql
Prompt Running: pl_rf_sos_batchsel.sql
@pl_rf_sos_batchsel.sql
Prompt Running: type_rf_sos_batchupd_obj.sql
@type_rf_sos_batchupd_obj.sql
Prompt Running: pl_rf_sos_batchupd.sql
@pl_rf_sos_batchupd.sql
Prompt Running: type_rf_sos_batchcmp.sql
@type_rf_sos_batchcmp.sql
Prompt Running: pl_rf_sos_batchcmp.sql
@pl_rf_sos_batchcmp.sql
Prompt Running: type_rf_sos_datacol.sql
@type_rf_sos_datacol.sql
Prompt Running: pl_rf_sos_datacol.sql
@pl_rf_sos_datacol.sql
Prompt Running: type_rf_sos_mxshort_obj.sql
@type_rf_sos_mxshort_obj.sql
Prompt Running: pl_rf_sos_mxshort.sql
@pl_rf_sos_mxshort.sql
Prompt Running: type_rf_sos_login.sql
@type_rf_sos_login.sql
Prompt Running: pl_rf_sos_login.sql
@pl_rf_sos_login.sql
Prompt Running: type_rf_sos_logout.sql
@type_rf_sos_logout.sql
Prompt Running: pl_rf_sos_logout.sql
@pl_rf_sos_logout.sql
Prompt Running: pl_tp_signoff_from_fklft_batch.sql
@pl_tp_signoff_from_fklft_batch.sql
Prompt Running: type_lxli_batch_obj.sql
@type_lxli_batch_obj.sql
Prompt Running: pl_lxli_batch.sql
@pl_lxli_batch.sql
Prompt Running: type_lxli_forklift_obj.sql
@type_lxli_forklift_obj.sql
Prompt Running: pl_lxli_forklift.sql
@pl_lxli_forklift.sql
Prompt Running: type_pl_lxli_loader_batch.sql
@type_pl_lxli_loader_batch.sql
Prompt Running: pl_lxli_loader_batch.sql
@pl_lxli_loader_batch.sql
Prompt Running: pl_rf_print_report.sql
@pl_rf_print_report.sql
Prompt Running: v_mntswp_select.sql
@v_mntswp_select.sql               
Prompt Running: swp_nonperfrm_task_on_hold.sql
@swp_nonperfrm_task_on_hold.sql               

Prompt Running file: verify_access.sql
@/swms/curr/schemas/verify_access.sql

Prompt Running: fix_cascading_invalidations.sql
@fix_cascading_invalidations.sql               

exec :rc:=0;
exit;
EOF