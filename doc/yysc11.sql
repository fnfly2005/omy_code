
select
    cit.province_name,
    cit.city_name,
    approx_percentile(phone_num,0.5) as num
from (
    select city_id, mt_city_id, city_name, province_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
    ) cit
    join (
    select
        active_date,
        mou.city_id,
        approx_distinct(mobile) as phone_num
    from (
        select mobile, city_id, active_date from mart_movie.dim_myshow_movieuser where active_date>='$$begindate' and active_date<'$$enddate'
        ) mou
    group by
        1,2
    ) sc
    on sc.city_id=cit.mt_city_id
group by
    1,2
union all
select
    province_name,
    '全部' city_name,
    approx_percentile(phone_num,0.5) as num
from (
    select
        active_date,
        cit.province_name,
        approx_distinct(mobile) as phone_num
    from (
        select city_id, mt_city_id, city_name, province_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
        ) cit
        join (
            select mobile, city_id, active_date from mart_movie.dim_myshow_movieuser where active_date>='$$begindate' and active_date<'$$enddate'
            ) mou
        on mou.city_id=cit.mt_city_id
    group by
        1,2
    ) as cm
group by
    1,2
;
