/*电影业务-选座核心交易指标主题表*/
select 
    from_unixtime(unix_timestamp(dt,'yyyyMMdd'),'yyyy-MM-dd') as dt,
    sum(ordernum) as order_num,
    sum(seatnum) as ticket_num,
    sum(gmv) as gmv
from 
    mart_movie.topic_movie_deal_kpi_daily
where 
    dt>='$$begindatekey'
    and dt<'$$enddatekey'
    and source=8
    and channel_id=80001
group by
    from_unixtime(unix_timestamp(dt,'yyyyMMdd'),'yyyy-MM-dd')
