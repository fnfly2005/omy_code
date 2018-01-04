select 
    partition_date,
    case new_app_name
    when '微信演出赛事' then '微信钱包'
    when '微信吃喝玩乐' then '微信点评'
    when '未知'     then '其他'
    else new_app_name
    end as new_app_name,
    sum(uv) as uv,
    sum(pv) as pv
from 
    mart_movie.aggr_myshow_pv_platform
where 
    partition_date>='$time1'
    and partition_date<'$time2'
group by 
    1,
    2
