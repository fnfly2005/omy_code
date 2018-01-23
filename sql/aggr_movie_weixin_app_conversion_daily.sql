/*猫眼漏斗_微信吃喝玩乐*/
select
    dt,
    firstpage_uv
from
    aggr_movie_weixin_app_conversion_daily
where
    dt>='$time1'
    and dt<'$time2'
