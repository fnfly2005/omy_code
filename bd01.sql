select
    so.OrderID,
    spss.PerformanceName,
    so.PaidTime,
    spss.ShowName,
    stc.Description,
    so.RefundStatus,
    so.SalesPlanCount,
    so.SalesPlanSellPrice,
    so.TotalPrice
from
(select
    OrderID,
    TPID,
    PaidTime,
    case RefundStatus
        when 0 then "未发起"
        when 1 then "发起失败"
        when 2 then "发起成功"
        when 3 then "退款中"
        when 4 then "退款失败"
    else "其他" end RefundStatus,
    SalesPlanCount,
    SalesPlanSellPrice,
    TotalPrice
from
    S_Order
where
    TPID>=6
    and ReserveStatus in (7,9)
    and RefundStatus<>5
    and PaidTime is not null) so
    join 
(select
    OrderID,
    PerformanceName,
    ShowName,
    TicketID
from
    S_OrderSalesPlanSnapshot
where
    PerformanceID=16998) spss on so.OrderID=spss.OrderID
    join 
(select
    TPID
from
    BS_ActivityMap
where
    TPSProjectID=22313) am on so.TPID=am.TPID
    left join
(select
    TicketClassID,
    Description
from
    S_TicketClass) stc on spss.TicketID=stc.TicketClassID
