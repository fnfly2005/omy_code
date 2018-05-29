
select
    spm.cid,
    spm.app_name,
    app_identifier,
    page_name,
    app_name as app_id2,
    page_identifier,
    uv
from (
    select distinct
        cid,
        app_name,
        app_identifier,
        page_name
    from (
        select cid, app_name, app_identifier, page_name from mart_flow.sdk_page_config_info where channel_identifier='movie' and partition_date='$$today{-1d}' and cid is not null and ( page_name like '%演出%' or app_name like '%格瓦拉%' )
        ) spc
        left join (
        select nav_flag, value, name, page, page_tag1, page_tag2 from upload_table.myshow_pv where key='page_identifier'
        ) mp
        on mp.value=spc.cid
    where
        mp.value is null
    ) spm
    left join (
    select
        app_name,
        page_identifier,
        count(distinct union_id) as uv
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
        and (
            app_name='gewara'
            or page_identifier like '%演出%'
            )
    group by
        1,2
    ) fpw
    on fpw.page_identifier=spm.cid
;
