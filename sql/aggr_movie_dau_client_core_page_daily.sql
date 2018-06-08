/*猫眼漏斗_猫眼*/
select
    dt,
    '猫眼' as pt,
    firpage_uv as firstpage_uv
from
    aggr_movie_dau_client_core_page_daily
where
    dt>='$$begindatekey'
    and dt<'$$enddatekey'
