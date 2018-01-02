
select
    substr(partition_date,1,7) mt,
    value2,
    0 as sp_num,
    count(distinct order_id) as order_num,
    sum(TotalPrice) as gmv
from
    (
    select partition_date, order_id, sellchannel, performance_id, totalprice, grossprofit from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
    ) as spo
    left join 
    (
    select key, value1, value2, value3 from upload_table.dictionary001 where key_name is not null
    and key_name='sellchannel'
    ) as md
    on spo.sellchannel=md.key
group by
    1,2
union all
select
    substr(partition_date,1,7) mt,
    '全部' as value2,
    count(distinct performance_id) as sp_num,
    count(distinct order_id) as order_num,
    sum(TotalPrice) as gmv
from
    (
    select partition_date, order_id, sellchannel, performance_id, totalprice, grossprofit from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
    ) as spo
    left join 
    (
    select key, value1, value2, value3 from upload_table.dictionary001 where key_name is not null
    and key_name='sellchannel'
    ) as md
    on spo.sellchannel=md.key
group by
    1,2 
;
