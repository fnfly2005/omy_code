/*新美大流量宽表*/
select
    partition_date as dt,
    stat_time,
    app_name,
    page_identifier,
    os,
    custom,
    union_id
from mart_flow.detail_flow_pv_wide_report
where partition_date>='$$begindate'
    and partition_date<'$$enddate'
    and partition_log_channel='movie'
    and partition_app in (
    select key
    from upload_table.myshow_dictionary
    where key_name='partition_app'
    )
    and page_identifier in (
    select value
    from upload_table.myshow_pv
    where key='page_identifier'
    )
