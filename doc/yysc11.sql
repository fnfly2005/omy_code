
select
    province_name,
    coalesce(city_name,'全部') as city_name,
    coalesce(category_name,'全部') as category_name,
    count(distinct usermobileno) as user_num
from (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
    ) per
    join (
        select 
            usermobileno,
            performance_id
        from 
            mart_movie.detail_myshow_saleorder
        where 
            order_create_time>='$$begindate'
            and order_create_time<'$$enddate'
        ) so
    on so.performance_id=per.performance_id
group by
    category_name,
    province_name,
    city_name
grouping set(
    (province_name),
    (province_name,city_name),
    (category_name,province_name),
    (category_name,province_name,city_name)
    ) 
;
