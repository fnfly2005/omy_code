/*订单支付明细表*/
select
    partition_date,
    order_id,
    sellchannel,
    customer_id,
    performance_id,
    show_id,
    totalprice,
    grossprofit,
    setnumber,
    salesplan_count
from
    mart_movie.detail_myshow_salepayorder
where
    partition_date>='2017-10-01'
    and partition_date>='$time1'
    and partition_date<'$time2'
