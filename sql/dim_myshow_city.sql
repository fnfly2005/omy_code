/*城市维表*/
select
    city_id,
    mt_city_id,
    city_name,
    province_name,
    area_1_level_name,
    area_2_level_name
from
    mart_movie.dim_myshow_city
where
    city_id is not null
