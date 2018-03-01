
select
    csd.mobile_phone,
    cit.city_name,
    cit.province_name
from (
    select city_id, mt_city_id, city_name, province_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
    and province_name like '%$name%'
    ) cit
    join (
    select cinema_id, city_id from mart_movie.dim_cinema where cinema_id is not null
    ) cin
    on cin.city_id=cit.mt_city_id
    join (
    select cinema_id, mobile_phone from mart_movie.aggr_discount_card_seat_dwd where pay_time>'2018-02-01' and pay_time>='$$begindate' and pay_time<'$$enddate'
    ) csd
    on csd.cinema_id=cin.cinema_id
group by
    csd.mobile_phone,
    cit.city_name,
    cit.province_name
limit 400000
;
