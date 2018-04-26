
select 
    mobile,
    $send_performance_id as send_performance_id,
    '$$enddate' as send_date,
    cast(floor(rand()*$batch_code) as bigint)+1 as batch_code,
    '$sendtag' as sendtag
from (
    select
        mobile,
        row_number() over (order by 1) rank
    from (
        select distinct
            mobile
        from (
            select
                mobile
            from
                mart_movie.dim_myshow_movieuser
            where
                active_date>=date_add('day',-$at,current_date)
                and city_id in (
                    select 
                        mt_city_id
                    from (
                        select city_id, mt_city_id, city_name, province_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
                        and province_name in ('$name')
                        union all
                        select city_id, mt_city_id, city_name, province_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
                        and city_name in ('$name')
                        ) c1
                    )
                and (
                    movie_id in ($movie_id)
                    or -99 in ($movie_id)
                    )
            union all
            select
                mobile
            from
                mart_movie.dim_myshow_movieusera
            where
                active_date>=date_add('day',-$at,current_date)
                and city_id in (
                    select distinct
                        mt_city_id
                    from (
                        select city_id, mt_city_id, city_name, province_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
                        and province_name in ('$name')
                        union all
                        select city_id, mt_city_id, city_name, province_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
                        and city_name in ('$name')
                        ) c1
                    )
                and (
                    movie_id in ($movie_id)
                    or -99 in ($movie_id)
                    )
            ) mu
        ) mou
        left join (
        select mobile
        from upload_table.send_fn_user
        where send_date>=date_add('day',-$id,current_date)
        union all 
        select mobile
        from upload_table.send_wdh_user
        where send_date>=date_add('day',-$id,current_date)
            ) mm
        on mm.mobile=mou.mobile
    where
        mm.mobile is null
    ) as c
where
    rank<=$limit
;
