/*页面配置表*/
select
    cid,
    app_name,
    app_identifier,
    page_name
from
    mart_flow.sdk_page_config_info
where
    channel_identifier='movie'
    and partition_date='$$today{-1d}'
    and cid is not null
    and (
        page_name like '%演出%'
        or app_name like '%格瓦拉%'
        )
