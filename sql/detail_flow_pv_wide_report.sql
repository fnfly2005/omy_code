/*新美大流量宽表*/
select
    partition_date as dt,
    stat_time,
    app_name,
    page_identifier,
    os,
    custom,
    utm_source,
    url_parameters,
    url_path,
    url,
    union_id,
    user_id
from 
    mart_flow.detail_flow_pv_wide_report
where partition_date>='$$begindate'
    and partition_date<'$$enddate'
    and partition_log_channel='movie'
    and partition_app in (
        'movie',
        'dianping_nova',
        'other_app',
        'dp_m',
        'group'
        )
/*    and page_identifier in (*/
/*        select value*/
/*        from upload_table.myshow_pv*/
/*        where key='page_identifier')*/
