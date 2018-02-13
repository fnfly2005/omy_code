
select
    usermobileno,
    city_name,
    province_name
from
    (
    select order_id, usermobileno, sellchannel, city_id, totalprice, customer_id, performance_id, meituan_userid, dianping_userid, pay_time, consumed_time, show_endtime, show_starttime, order_create_time from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
    ) so
    join (
    select city_id, city_name, province_name from mart_movie.dim_myshow_city where city_id is not null
    and province_name like '%$name%'
    ) ci
    on so.city_id=ci.city_id
group by
    1,2,3
;
