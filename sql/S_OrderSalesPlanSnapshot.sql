/*交易时销售计划快照表*/
select
    OrderID,
    PerformanceName,
    PerformanceID,
    ShowName,
    TicketID TicketClassID,
    SalesPlanTicketPrice
from
    S_OrderSalesPlanSnapshot
where
    OrderID is not null
    and CreateTime>='-time3'
    and CreateTime<'-time2'