select
    substr(pay_time,1,10) as dt,
    count(distinct order_id) as order_num,
    count(distinct case when customer_id>=6 then order_id end) as z_order_num,
    sum(totalprice) as totalprice,
    count(distinct performance_id) as sp_num
from
    (
    select order_id, sellchannel, totalprice, customer_id, performance_id, meituan_userid, dianping_userid, pay_time, consumed_time, show_endtime, show_starttime, order_create_time from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$time1' and pay_time<'$time2'
    ) so
group by
    1
;
