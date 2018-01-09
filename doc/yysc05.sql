
select
mt,
coalesce(value2,'全部') as sellchannel,
coalesce(category_name,'全部') as category_name,
user_num,
order_num,
totalprice
from
(select
    substr(so.pay_time,1,7) as mt,
    dic.value2,
    dp.category_name,
    count(distinct so.meituan_userid) as user_num,
    count(distinct so.order_id) as order_num,
    sum(so.totalprice) as totalprice
from
    (
    select order_id, sellchannel, totalprice, customer_id, performance_id, meituan_userid, pay_time from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$time1' and pay_time<'$time2'
    ) as so
    join 
    (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name from mart_movie.dim_myshow_performance
    ) as dp
    on so.performance_id=dp.performance_id
    left join
    (
    select key, value1, value2, value3 from upload_table.dictionary001 where key_name is not null
    and key_name='sellchannel'
    ) as dic
    on dic.key=so.sellchannel
group by
    substr(so.pay_time,1,7),
    dic.value2,
    dp.category_name
grouping sets
    (
    (substr(so.pay_time,1,7),
    dic.value2,
    dp.category_name),
    substr(so.pay_time,1,7)
    )) as test
;