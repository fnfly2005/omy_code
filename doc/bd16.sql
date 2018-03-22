
select distinct
    cinema_id
from (
    select distinct
        mt_city_id
    from (
        select city_id, mt_city_id, city_name, province_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
        and province_name in ('$name')
        union all
        select city_id, mt_city_id, city_name, province_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
        and city_name in ('$name')
        ) c1
    ) cit
    left join (
    select cinema_id, city_id from mart_movie.dim_cinema
    where machine_type=1
    ) cin
    on cin.city_id=cit.mt_city_id
;
