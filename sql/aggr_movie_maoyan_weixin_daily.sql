/*猫眼漏斗_微信演出赛事*/
select
    dt,
    '微信演出赛事' as pt,
    firstpage_uv
from
    aggr_movie_maoyan_weixin_daily
where
    dt>='$$begindatekey'
    and dt<'$$enddatekey'
