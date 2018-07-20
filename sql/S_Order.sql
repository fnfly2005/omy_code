/*订单表*/
select 
    orderid as order_id,
    sellchannel,
    dpuserid as dianping_userid,
    mtuserid as meituan_userid,
    usermobileno,
    dpcityid as city_id,
    salesplanid as salesplan_id,
    salesplansupplyprice as supply_price,
    salesplansellprice as sell_price,
    salesplancount as salesplan_count,
    totalprice,
    myorderid as maoyan_order_id,
    tpid as customer_id,
    reservestatus as order_reserve_status,
    deliverstatus as order_deliver_status,
    refundstatus as order_refund_status,
    createtime as order_create_time,
    paidtime as pay_time,
    ticketedtime as ticketed_time,
    totalticketprice
from
    S_Order
where
    OrderID>-time1
