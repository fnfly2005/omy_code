/*新美大流量小时级数据*/
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
    mart_flow.detail_flow_all_report_hourly
where
    partition_date='$$today{-0d}'
    and partition_log_channel='movie'
    and log_channel='movie'
    and partition_app in (
        'movie',
        'dianping_nova',
        'other_app',
        'dp_m',
        'group'
        )
