/*流量分来源分平台分页面*/
select
    partition_date,
    new_page_name,
    pv,
    uv
from
    mart_movie.aggr_myshow_pv_all
where
    new_app_name='微信演出赛事'
    and partition_date>='$time1'
    and partition_date<'$time2'
