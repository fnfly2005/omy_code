/*城市维表*/
select 
    city_id,
    mt_city_id,
    case when mt_city_id=0 then '其他城市'
    else city_name end as city_name,
    case when mt_city_id=0 then '其他城市'
    else province_name end as province_name,
    area_1_level_name,
    area_2_level_name
from
    mart_movie.dim_myshow_city
where
    city_id is not null
