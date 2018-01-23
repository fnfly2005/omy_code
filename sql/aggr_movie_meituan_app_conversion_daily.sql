/*猫眼漏斗_微信演出赛事*/
select
    dt,
    firstpage_uv
from
    aggr_movie_meituan_app_conversion_daily
where
    dt>='$time1'
    and dt<'$time2'
