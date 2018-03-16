/*订单关联实名制用户购票信息*/
select
    PerformanceID as performance_id,
    OrderID as order_id,
    UserName,
    IDNumber
from
    origindb.dp_myshow__s_orderidentification
where
    TicketNumber>0
