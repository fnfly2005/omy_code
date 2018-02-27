/*新美大流量MV宽表*/
select
    partition_etl_source,
    partition_date as dt,
    custom,
    union_id
from
    mart_flow.detail_flow_mv_wide_report
where
    partition_date>='$$begindate'
    and partition_date<'$$enddate'
    and partition_log_channel='movie'
    and partition_etl_source='2_5x'
    and partition_app in (
    'movie',
    'dianping_nova',
    'other_app',
    'dp_m',
    'group'
    )
    and event_id in (
    select value
    from upload_table.myshow_pv
    where key='event_id'
    and page_tag1>=1
    and page_tag1<6
    )
