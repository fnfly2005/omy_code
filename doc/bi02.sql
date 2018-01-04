
select
    performance_id,
    sum(totalprice) as totalprice
from
    (
    select partition_date, order_id, sellchannel, customer_id, performance_id, totalprice, grossprofit from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
    ) as spo
group by
    1
;
