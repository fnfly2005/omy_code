select
    substr(so.pay_time,1,7) as mt,
    sellchannel,
    category_name,
    count(distinct so.order_id) as order_num,
    sum(so.totalprice) as totalprice
from
    (
    select order_id, case sellchannel when 1 then '点评' when 2 then '美团' when 3 then '微信大众点评' when 4 then '微信搜索小程序' when 5 then '猫眼' when 6 then '微信钱包' when 7 then '微信钱包' else '其他' end as sellchannel, totalprice, customer_id, performance_id, pay_time from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$time1' and pay_time<'$time2'
    ) as so
    join 
    (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name from mart_movie.dim_myshow_performance
    ) as dp
    using(performance_id)
group by
    1,2,3
;
