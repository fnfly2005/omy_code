
select 
    mobile
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
                active_date>='$$begindate'
                and active_date<'$$enddate'
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
            union all
            select
                mobile
            from
                mart_movie.dim_myshow_movieuser
            where
                active_date>='$$begindate'
                and active_date<'$$enddate'
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
            ) mu
        ) mou
        left join upload_table.myshow_mark mm
        on mm.usermobileno=mou.mobile
        and $id=1
    where
        mm.usermobileno is null
    ) as c
where
    rank<=$limit
;
