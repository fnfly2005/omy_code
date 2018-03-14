
select
    so.usermobileno,
    ci.city_name
from (
    select
        city_id,
        city_name
    from (
        select city_id, mt_city_id, city_name, province_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
        and province_name in ('$name')
        union all
        select city_id, mt_city_id, city_name, province_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
        and city_name in ('$name')
        ) c1
    group by
        1,2
    ) ci
    join (
    select
        usermobileno,
        city_id
    from
        mart_movie.detail_myshow_saleorder
    where order_create_time>='$$begindate'
        and order_create_time<'$$enddate'
    group by
        1,2
    ) so
    on so.city_id=ci.city_id
;
