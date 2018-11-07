/*mysensitive漏斗_微信ycsensitive赛事*/
select
    dt,
    'mtsensitive' as pt,
    firstpage_uv
from
    aggr_movie_mtsensitive_app_conversion_daily
where
    dt>='$$begindatekey'
    and dt<'$$enddatekey'
