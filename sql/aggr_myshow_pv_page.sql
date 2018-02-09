/*流量分页面*/
select
    partition_date as dt,
    new_page_name,
    pv,
    uv
from
    mart_movie.aggr_myshow_pv_page
where
    partition_date>='$$begindate'
    and partition_date<'$$enddate'
