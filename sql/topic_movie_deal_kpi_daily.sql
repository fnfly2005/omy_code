/*电影业务-选座核心交易指标主题表*/
select 
    sum(ordernum) as order_num,
    sum(seatnum) as ticket_num,
    sum(gmv) as gmv
from 
    mart_movie.topic_movie_deal_kpi_daily
where 
    dt='$$today_compact{-1d}'
    and source=8
    and channel_id=80001
