/*项目维表*/
select
    performance_id,
    activity_id,
    performance_name,
    category_id,
    category_name,
    area_1_level_name,
    area_2_level_name,
    city_id,
    city_name
from
    mart_movie.dim_myshow_performance