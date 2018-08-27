/*订单关联实名制用户购票信息*/
select
    id,
    PerformanceID as performance_id,
    OrderID as order_id,
    UserName,
    IDNumber,
    TicketNumber
from
    origindb.dp_myshow__s_orderidentification
where
    idtype=1
    and (createtime>='2018-07-14'
        or (createtime<'2018-07-14'
        and ticketnumber>0))
