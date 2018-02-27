
select
    dt,
    md.value2 as pt,
    mp.bu,
    mp.p_name,
    mp.m_name,
    mp.m_no,
    sum(uv) as uv,
    sum(pv) as pv
from (
    select
        partition_date as dt,
        app_name,
        event_id,
        approx_distinct(union_id) as uv,
        count(1) as pv
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
        and event_type='click'
    group by
        1,2,3
    ) as fmw
    join (
        select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
        and key_name='app_name'
        ) as md
    on md.key=fmw.app_name
    join (
    select 
        case when mp1.page_tag1=0 then '演出'
        else '平台' end as bu,
        mp1.name as p_name,
        mp2.value as event_id,
        mp2.name as m_name,
        mp2.page_tag2 as m_no
    from upload_table.myshow_pv as mp1
        join upload_table.myshow_pv as mp2
        on mp1.value=mp2.page
        and mp1.key='page_identifier'
        and mp2.key='event_id'
        and mp1.nav_flag<=1
        and mp1.page_tag1>-2
    ) mp 
    on mp.event_id=fmw.event_id
group by 
    1,2,3,4,5,6
;
