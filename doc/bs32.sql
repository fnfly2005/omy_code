
select
    performance_name,
    city_name,
    shop_name,
    category_name,
	order_num,
	totalprice
from (
    select
        performance_id,
        count(distinct order_id) as order_num,
        sum(totalprice) as totalprice
    from 
        mart_movie.detail_myshow_saleorder
    where
        pay_time is not null
        and meituan_userid=1275075496
    group by
        1
    ) so
    join (
        select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
        ) per
    on per.performance_id=so.performance_id
limit 1000;
