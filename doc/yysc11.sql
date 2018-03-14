
select
    area_2_level_name,
    province_name,
    '全部' city_name,
    approx_distinct(usermobileno) user_num
from (
    select city_id, mt_city_id, city_name, province_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
    ) ci
    join (
        select 
            usermobileno,
            city_id
        from 
            mart_movie.detail_myshow_saleorder
        where 
            order_create_time>='$$begindate'
            and order_create_time<'$$enddate'
    ) so
    on so.city_id=ci.city_id
group by
    1,2,3
union all
select
    area_2_level_name,
    province_name,
    city_name,
    approx_distinct(usermobileno) user_num
from (
    select city_id, mt_city_id, city_name, province_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
    ) ci
    join (
        select 
            usermobileno,
            city_id
        from 
            mart_movie.detail_myshow_saleorder
        where 
            order_create_time>='$$begindate'
            and order_create_time<'$$enddate'
    ) so
    on so.city_id=ci.city_id
group by
    1,2,3
;
