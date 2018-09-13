
select
    ery.city_name
from (
    select distinct
        cityname as city_name
    from origindb.dp_myshow__s_orderdelivery where 1=1
        and cityname is not null
        and cityname not like '%区划'
    ) as ery
    left join (
    select city_id, mt_city_id, city_name, province_id, province_name, area_1_level_id, area_1_level_name, area_2_level_id, area_2_level_name from mart_movie.dim_myshow_city where 1=1
    ) ity
    on ity.city_name=ery.city_name
where
    ity.city_name is null
;
