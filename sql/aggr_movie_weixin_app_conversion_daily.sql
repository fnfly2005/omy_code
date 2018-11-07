/*mysensitive漏斗_微信dpsensitive*/
select
    dt,
    '微信dpsensitive' as pt,
    firstpage_uv
from
    aggr_movie_weixin_app_conversion_daily
where
    dt>='$$begindatekey'
    and dt<'$$enddatekey'
