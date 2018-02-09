/*订单明细表*/
select
    order_id,
    sellchannel,
    totalprice,
    customer_id,
    performance_id,
    meituan_userid,
    dianping_userid,
    pay_time,
    consumed_time,
    show_endtime,
    show_starttime,
    order_create_time
from
    mart_movie.detail_myshow_saleorder
where
    pay_time is not null
    and pay_time>='$$begindate'
    and pay_time<'$$enddate'
