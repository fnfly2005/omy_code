
select
    mobile_phone,
    row_number() over (order by 1) rank
from (
    select distinct
        csd.mobile_phone
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
        ) cin
        on cin.city_id=cit.mt_city_id
        left join (
        select cinema_id, mobile_phone from mart_movie.aggr_discount_card_seat_dwd where mobile_phone is not null and order_time>='$$begindate' and order_time<'$$enddate'
        ) csd
        on csd.cinema_id=cin.cinema_id
        left join upload_table.myshow_mark mm
        on mm.usermobileno=csd.mobile_phone
        and $id=1
    where
        mm.usermobileno is null
    ) iis
where
     mobile_phone is not null
;
