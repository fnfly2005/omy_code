
select distinct
    MYOrderID,
    IDNumber,
    UserName,
    UserMobileNo,
    PerformanceID,
    CreateTime,
    RefundStatus
from (
    /*订单关联实名制用户购票信息*/ select OrderID, PerformanceID, UserName, IDType, IDNumber from S_OrderIdentification where OrderID>
    and PerformanceID in ()
    ) soi
    join ( 
    /*订单表*/ select orderid as order_id, sellchannel, clientplatform, dpuserid as dianping_userid, mtuserid as meituan_userid, usermobileno, dpcityid as city_id, salesplanid as salesplan_id, salesplansupplyprice as supply_price, salesplansellprice as sell_price, salesplancount as salesplan_count, totalprice, myorderid as maoyan_order_id, tpid as customer_id, tporderid, reservestatus as order_reserve_status, deliverstatus as order_deliver_status, refundstatus as order_refund_status, createtime as order_create_time, lockedtime, payexpiretime, paidtime as pay_time, ticketedtime as ticketed_time, showstatus, wxopenid, prepayid as prepay_id, needrealname, consumedtime as consumed_time, needseat, totalticketprice from S_Order where OrderID> and OrderID<=
    and RefundStatus<>5
    ) so
    using(OrderID)
limit 10000;

