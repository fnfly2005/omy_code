/*猫眼漏斗_微信演出赛事*/
select
    dt,
    '美团' as pt,
    firstpage_uv
from
    aggr_movie_meituan_app_conversion_daily
where
    dt>='$$begindatekey'
    and dt<'$$enddatekey'
