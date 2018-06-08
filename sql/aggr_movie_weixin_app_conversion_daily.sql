/*猫眼漏斗_微信吃喝玩乐*/
select
    dt,
    '微信吃喝玩乐' as pt,
    firstpage_uv
from
    aggr_movie_weixin_app_conversion_daily
where
    dt>='$$begindatekey'
    and dt<'$$enddatekey'
