/*mysensitive漏斗_微信ycsensitive赛事*/
select
    dt,
    '微信ycsensitive赛事' as pt,
    firstpage_uv
from
    aggr_movie_mysensitive_weixin_daily
where
    dt>='$$begindatekey'
    and dt<'$$enddatekey'
