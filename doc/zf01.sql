
select
    * 
from
(select
    case when show_endtime is null 
        and show_starttime<='2018-01-06'
    then 1
        when length(show_endtime)<=0 
        and show_starttime<='2018-01-06'
    then 2
        when show_endtime<='2017-09-01' 
        and show_starttime<='2018-01-06'
    then 3
        when show_endtime<='2018-01-06'
        and show_endtime>'2017-09-01' 
    then 4
    else 0 end as flag,
    order_id,
    consumed_time,
    show_endtime,
    show_starttime,
    pay_time,
    order_create_time
from
    (
    select order_id, sellchannel, totalprice, customer_id, performance_id, meituan_userid, pay_time, consumed_time, show_endtime, show_starttime, order_create_time from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$time1' and pay_time<'$time2'
    and order_reserve_status=9
    and order_create_time>='2017-09-01'
    and order_refund_status=0
    and consumed_time is null
    ) as so) as s1
where
    s1.flag<>0
;
