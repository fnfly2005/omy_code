
select
    substr(so.pay_time,1,7) mt,
    dc.customer_type_name,
    customer_lvl1_name,
    dmp.city_name,
    dmp.performance_name,
    dmp.shop_name,
    sum(TotalPrice) TotalPrice
from
    (
    select order_id, sellchannel, totalprice, customer_id, performance_id, meituan_userid, pay_time from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$time1' and pay_time<'$time2'
    ) so
    join
    (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance
    ) dmp
    on so.performance_id=dmp.performance_id
    join 
    (
    select customer_id, case when customer_type_id=1 then customer_shortname else customer_type_name end customer_lvl0_name, customer_type_id, customer_type_name, customer_lvl1_name from mart_movie.dim_myshow_customer where customer_id is not null
    ) dc
    on so.customer_id=dc.customer_id
where
    dmp.shop_name like '%$shop%'
    and dmp.city_name like '%$city%'
group by
    1,2,3,4,5,6
;