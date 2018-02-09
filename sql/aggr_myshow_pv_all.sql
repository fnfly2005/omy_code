/*流量分来源分平台分页面*/
select
    partition_date as dt,
    new_app_name,
    new_page_name,
    pv,
    uv
from
    mart_movie.aggr_myshow_pv_all
where
    new_app_name='微信演出赛事'
    and partition_date>='$$begindate'
    and partition_date<'$$enddate'
