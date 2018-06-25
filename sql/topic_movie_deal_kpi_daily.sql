/*电影业务-选座核心交易指标主题表from_unixtime(unix_timestamp(dt,'yyyyMMdd'),'yyyy-MM-dd') as dt,*/
select 
    substr(date_parse(dt,'%Y%m%d'),1,10) as dt,
    ordernum,
    seatnum,
    gmv
from 
    mart_movie.topic_movie_deal_kpi_daily
where 
    dt>='$$begindatekey'
    and dt<'$$enddatekey'
    and source=8
    and channel_id=80001
