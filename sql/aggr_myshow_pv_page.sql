/*流量分页面*/
select
    partition_date,
    new_page_name,
    pv,
    uv
from
    mart_movie.aggr_myshow_pv_page
where
    partition_date>='$time1'
    and partition_date<'$time2'
