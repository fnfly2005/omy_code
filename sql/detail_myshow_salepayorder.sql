/*订单支付明细表*/
select
    partition_date as dt,
    order_id,
    sellchannel,
    customer_id,
    performance_id,
    meituan_userid,
    show_id,
    totalprice,
    grossprofit,
    setnumber,
    salesplan_count,
    expressfee,
    project_id,
    bill_id,
    salesplan_id
from
    mart_movie.detail_myshow_salepayorder
where
    partition_date>='$time1'
    and partition_date<'$time2'
