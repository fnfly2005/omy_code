/*交易时销售计划快照表*/
select
    OrderID,
    PerformanceName,
    PerformanceID,
    ShowName,
    TicketID TicketClassID,
    SalesPlanTicketPrice
from
    origindb.dp_myshow__s_ordersalesplansnapshot
where
    OrderID is not null
    and CreateTime>='-time3'
    and CreateTime<'-time2'
