select
    substr(so.pay_time,1,7) as mt,
    count(distinct so.meituan_userid) as user_num,
    count(distinct so.order_id) as order_num,
    sum(so.totalprice) as totalprice
from
    (
    select order_id, sellchannel, totalprice, customer_id, performance_id, meituan_userid, pay_time from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$time1' and pay_time<'$time2'
    ) as so
group by
    1
;
