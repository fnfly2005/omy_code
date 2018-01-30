/*新美大流量宽表-活动*/
select
    partition_date as dt,
    url_parameters,
    page_name,
    union_id
from mart_flow.detail_flow_pv_wide_report
where partition_date>='$time1'
    and partition_date<'$time2'
    and partition_log_channel='firework'
    and partition_app in (
    select key
    from upload_table.myshow_dictionary
    where key_name='partition_app'
    )
    and page_bg='猫眼文化'
