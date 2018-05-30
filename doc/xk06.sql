
select
    fpw.dt,
    mp.key,
    value,
    name,
    page,
    nav_flag,
    page_tag1,
    case when mp.key='page_identifier' then fpw.uv
    else fmw.uv end as uv,
    md1.value2 as nav_name,
    md2.value2 as page_name
from (
    select key, value, name, page, nav_flag, page_tag1, page_tag2 from upload_table.myshow_pv
    ) mp
    left join (
        select
            partition_date as dt,
            page_identifier,
            approx_distinct(union_id) uv
        from mart_flow.detail_flow_pv_wide_report where partition_date>='$$today{-1d}' and partition_date<'$$today{-0d}' and partition_log_channel='movie' and partition_app in ( 'movie', 'dianping_nova', 'other_app', 'dp_m', 'group' )
        and page_identifier in (
            select value
            from upload_table.myshow_pv
            where key='page_identifier')
        group by
            1,2
            ) fpw
    on mp.value=fpw.page_identifier
    and mp.key='page_identifier'
    left join (
        select
            partition_date as dt,
            event_id,
            approx_distinct(union_id) uv
        from mart_flow.detail_flow_mv_wide_report where partition_date>='$$today{-1d}' and partition_date<'$$today{-0d}' and partition_log_channel='movie' and partition_etl_source='2_5x' and partition_app in ( 'movie', 'dianping_nova', 'other_app', 'dp_m', 'group' )
        and event_id in (
            select value
            from upload_table.myshow_pv
            where key='event_id') 
        group by
            1,2
            ) fmw
    on fmw.event_id=mp.value
    and mp.key='event_id'
    left join (
        select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where key_name is not null
        and key_name='nav_flag'
        ) md1
    on md1.key=mp.nav_flag
    left join (
        select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where key_name is not null
        and key_name='page_tag1'
        ) md2
    on md2.key=mp.page_tag1
order by
	mp.key desc,
    page,
    page_tag1 desc,
    nav_flag,
    8 desc
;
