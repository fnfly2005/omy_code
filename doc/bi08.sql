
select
    cit.city_id as parentdpcity_id,
    cit.city_name as parentdpcity_name,
    secondary_city_id as mtcity_id
from (
    select distinct
        city_id,
        secondary_city_id
    from mart_movie.dim_cinema where is_enabled=1
        and secondary_city_id<>city_id
        and city_name<>'资阳'
    ) cin
    left join (
        select city_id, mt_city_id, city_name, province_name, area_1_level_name, area_2_level_name from mart_movie.dim_myshow_city where dp_flag=0
        ) cit
        on cit.mt_city_id=cin.city_id
;
