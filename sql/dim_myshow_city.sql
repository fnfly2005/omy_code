/*城市维表*/
select
    city_id,
    city_name,
    province_name
from
    mart_movie.dim_myshow_city
where
    city_id is not null
