/*场次维表*/
select
    show_id,
    performance_id,
    activity_id,
    category_name,
    area_1_level_name,
    area_2_level_name,
    shop_id,
    show_starttime,
    show_endtime
from
    mart_movie.dim_myshow_show
where
    show_id is not null
