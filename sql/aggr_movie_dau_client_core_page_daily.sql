/*猫眼漏斗_猫眼*/
select
    dt,
    firpage_uv as firstpage_uv
from
    aggr_movie_dau_client_core_page_daily
where
    dt>='$time1'
    and dt<'$time2'
