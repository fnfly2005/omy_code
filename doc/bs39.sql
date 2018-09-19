
select
    substr(date_parse(dt,'%Y%m%d'),1,10) as dt,
    sum(ordernum) as ordernum,
    sum(seatnum) as seatnum,
    sum(gmv) as gmv
from mart_movie.topic_movie_deal_kpi_daily where dt>='$$begindatekey' and dt<'$$enddatekey' and source=8 and channel_id=80001
group by
    1
;
