select
    
from (
    select
        stat_time,
        app_name,
        page_identifier,
        union_id,
        user_id
    from
        mart_flow.detail_flow_pv_wide_report    
    where
        partition_date='$$today{-1d}'
        and partition_log_channel='movie'
        and partition_app in (
        'movie',
        'dianping_nova',
        'other_app',
        'dp_m',
        'group'
        )
    ) as pv
    join (
    select
        nav_flag,
        value
    from
        upload_table.myshow_pv
    where
        key='page_identifier'
        and page_tag1>=-1
    ) as mp
    on pv.page_identifier=mp.value
    ) sp
