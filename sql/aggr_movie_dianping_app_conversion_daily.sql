/*mysensitive漏斗_dpsensitive*/
select
    dt,
    'dpsensitive' as pt,
    firstpage_uv
from
    aggr_movie_dpsensitive_app_conversion_daily
where
    dt>='$$begindatekey'
    and dt<'$$enddatekey'
