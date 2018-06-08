/*猫眼漏斗_点评*/
select
    dt,
    '点评' as pt,
    firstpage_uv
from
    aggr_movie_dianping_app_conversion_daily
where
    dt>='$$begindatekey'
    and dt<'$$enddatekey'
