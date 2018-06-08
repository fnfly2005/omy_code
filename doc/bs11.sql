
select
    case when 1 in ($dim) then dt
    else 'all' end as dt,
    pt,
    avg(uv) uv
from (
    select
        dt,
        case when 2 in ($dim) then pt
        else 'all' end as pt,
        sum(firstpage_uv) as uv
    from (
        select dt, '猫眼' as pt, firpage_uv as firstpage_uv from aggr_movie_dau_client_core_page_daily where dt>='$$begindatekey' and dt<'$$enddatekey'
        union all
        select dt, '点评' as pt, firstpage_uv from aggr_movie_dianping_app_conversion_daily where dt>='$$begindatekey' and dt<'$$enddatekey'
        union all
        select dt, '微信演出赛事' as pt, firstpage_uv from aggr_movie_maoyan_weixin_daily where dt>='$$begindatekey' and dt<'$$enddatekey'
        union all
        select dt, '美团' as pt, firstpage_uv from aggr_movie_meituan_app_conversion_daily where dt>='$$begindatekey' and dt<'$$enddatekey'
        union all
        select dt, '微信吃喝玩乐' as pt, firstpage_uv from aggr_movie_weixin_app_conversion_daily where dt>='$$begindatekey' and dt<'$$enddatekey'
        ) as u 
    group by 
        1,2
    ) as su
group by
    1,2
;
