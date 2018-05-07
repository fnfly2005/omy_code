
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
                        select city_id, mt_city_id, city_name, province_name, area_1_level_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
                        and province_name in ('$name')
                        union all
                        select city_id, mt_city_id, city_name, province_name, area_1_level_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
                        and city_name in ('$name')
                        ) c1
                    )
                and (
                    movie_id in ($movie_id)
                    or -99 in ($movie_id)
                    )
                and 1 in ($dim)
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
                        select city_id, mt_city_id, city_name, province_name, area_1_level_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
                        and province_name in ('$name')
                        union all
                        select city_id, mt_city_id, city_name, province_name, area_1_level_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
                        and city_name in ('$name')
                        ) c1
                    )
                and (
                    movie_id in ($movie_id)
                    or -99 in ($movie_id)
                    )
                and 1 in ($dim)
            union all
            select
                cast(mobile as bigint) mobile
            from
                upload_table.fn_uploadmobile_data
            where
                2 in ($dim)
                and length(mobile)=11
                and mobile is not null
                and regexp_like(mobile,'1[3-9][0-9]+')
            union all
            select
                cast(mobile as bigint) mobile
            from
                upload_table.wdh_uploadmobile_data
            where
                3 in ($dim)
                and length(mobile)=11
                and mobile is not null
                and regexp_like(mobile,'1[3-9][0-9]+')
            ) mu
        ) mou
        left join (
            select mobile
            from upload_table.send_fn_user
            where 
                (send_date>=date_add('day',-$id,date_parse('$$enddate','%Y-%m-%d'))
                or sendtag in ('$send_tag')
                    )
                and sendtag not in (
                    select sendtag from upload_table.myshow_send_performance_fn where send_flag='0'
                    )
            union all 
            select mobile
            from upload_table.send_wdh_user
            where 
                (send_date>=date_add('day',-$id,date_parse('$$enddate','%Y-%m-%d'))
                or sendtag in ('$send_tag')
                    )
                and sendtag not in (
                    select sendtag from upload_table.myshow_send_performance_fn where send_flag='0'
                    )
            ) mm
        on mm.mobile=mou.mobile
    where
        mm.mobile is null
    ) as c
where
    rank<=$limit
;
