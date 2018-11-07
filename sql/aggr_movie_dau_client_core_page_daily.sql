/*mysensitive漏斗_mysensitive*/
select
    dt,
    'mysensitive' as pt,
    firpage_uv as firstpage_uv
from
    aggr_movie_dau_client_core_page_daily
where
    dt>='$$begindatekey'
    and dt<'$$enddatekey'
