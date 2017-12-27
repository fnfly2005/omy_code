/*订单明细表*/
select
    order_id,
    totalprice,
    customer_id,
    performance_id,
    pay_time
from
    mart_movie.detail_myshow_saleorder
where
    pay_time is not null
    and pay_time>='$time1'
    and pay_time<'$time2'
