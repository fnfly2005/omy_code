select
    sc.Name,
    so.OrderID,
    so.MYOrderID,
    so.PaidTime,
    so.RefundStatus,
    sos.PerformanceID,
    sos.PerformanceName,
    sos.ShowName,
    st.Description,
    sod.ExpressFee,
    so.SalesPlanCount,
    so.SalesPlanSellPrice,
    so.SalesPlanSupplyPrice,
    so.TotalPrice
from
    (
    select case when TPID<6 then '渠道' else '自营' end tp_type, case SellChannel when 1 then '点评' when 2 then '美团' when 3 then '微信' when 4 then '小程序' when 5 then '猫眼' when 6 then '微信演出赛事' when 7 then '微信钱包-小程序' else '其他' end SellChannel, case RefundStatus when 0 then '未发起' when 1 then '发起失败' when 2 then '发起成功' when 3 then '退款中' when 4 then '退款失败' when 5 then '已退款' else '其他' end RefundStatus, OrderID, MYOrderID, TPID, MTUserID, PaidTime, SalesPlanCount, SalesPlanSellPrice, SalesPlanSupplyPrice, TotalPrice from origindb.dp_myshow__s_order where ReserveStatus in (7,9) and PaidTime is not null
    and TPID>=6
    ) so 
join (
    select OrderID, PerformanceName, PerformanceID, ShowName, TicketID TicketClassID, SalesPlanTicketPrice, SetNum from origindb.dp_myshow__s_ordersalesplansnapshot where OrderID is not null
    and PerformanceID in (24260)
    ) sos
    on sos.OrderID=so.OrderID
left join (
    select TPID, Name from origindb.dp_myshow__s_customer where TPID is not null
    and TPID>=6
    ) sc 
    on sc.TPID=so.TPID
left join (
    select TicketClassID, PerformanceID, Description from origindb.dp_myshow__s_ticketclass where TicketClassID is not null
    ) st
    on st.TicketClassID=sos.TicketClassID
left join (
    select OrderID, ExpressFee from origindb.dp_myshow__s_orderdelivery where OrderDeliveryID is not null
    ) sod
    on sod.OrderID=so.OrderID