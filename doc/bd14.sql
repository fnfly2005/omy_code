
select 
    usermobileno,
    row_number() over (order by 1) rank
from (
    select distinct
        so.usermobileno
    from (
        select distinct
            city_id
        from (
            select city_id, mt_city_id, city_name, province_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
            and province_name in ('$name')
            union all
            select city_id, mt_city_id, city_name, province_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
            and city_name in ('$name')
            ) c1
        ) ci
        left join (
        select
            usermobileno,
            city_id
        from
            mart_movie.detail_myshow_saleorder
        where order_create_time>='$$begindate'
            and order_create_time<'$$enddate'
        ) so
        on so.city_id=ci.city_id
        left join upload_table.myshow_mark mm
        on mm.usermobileno=so.usermobileno
        and $id=1
    where
        mm.usermobileno is null
    ) as cs
where
    mm.usermobileno is not null
;
