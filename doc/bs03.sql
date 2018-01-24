
select
    meituan_userid,
    dianping_userid,
    coalesce(category_id,-99) category_id,
    first_pay_order_date,
    last_pay_order_date,
    pay_dt_num
from
(select
    meituan_userid,
    dianping_userid,
    category_id,
    min(dt) as first_pay_order_date,
    max(dt) as last_pay_order_date, 
    count(distinct dt) as pay_dt_num
from
(select
    meituan_userid,
    dianping_userid,
    case when dp.category_id is null then 8
    when dp.category_id=0 then 8
    else dp.category_id end as category_id,
    substr(pay_time,1,10) as dt
from
    (
    select order_id, sellchannel, totalprice, customer_id, performance_id, meituan_userid, dianping_userid, pay_time, consumed_time, show_endtime, show_starttime, order_create_time from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$time1' and pay_time<'$time2'
    ) as so
    left join
    (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
    ) as dp
    on so.performance_id=dp.performance_id) as s1
group by
    meituan_userid,
    dianping_userid,
    category_id
grouping sets(
(meituan_userid,dianping_userid),
(meituan_userid,dianping_userid,category_id)
)
) as s2
;
