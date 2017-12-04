select
    substr(so.PaidTime,1,7) mt,
    case when sc.Name is null then '其他'
    else sc.Name end Name,
    so.sellchannel,
    count(distinct so.MTUserID) so_user,
    count(distinct so.OrderID) so_num,
    sum(so.TotalPrice) TotalPrice
from
    (
    select OrderID, PerformanceName, PerformanceID, ShowName, TicketID TicketClassID, SalesPlanTicketPrice, SetNum from origindb.dp_myshow__s_ordersalesplansnapshot where OrderID is not null and CreateTime>='2015-12-31' and CreateTime<'2017-12-03'
    ) sos 
    left join
    (
    select PerformanceID, CategoryID, cityid, bsperformanceid, TicketStatus from origindb.dp_myshow__s_performance where PerformanceID is not null
    ) sp
    on sos.PerformanceID=sp.PerformanceID
    left join 
    (
    select CategoryID, Name from origindb.dp_myshow__S_Category where CategoryID is not null
    ) sc on sp.CategoryID=sc.CategoryID
    join 
    (
    select case when TPID<6 then '渠道' else '自营' end tp_type, case SellChannel when 1 then '点评' when 2 then '美团' when 3 then '微信' when 4 then '小程序' when 5 then '猫眼' when 6 then '微信演出赛事' when 7 then '微信钱包-小程序' else '其他' end SellChannel, case RefundStatus when 0 then '未发起' when 1 then '发起失败' when 2 then '发起成功' when 3 then '退款中' when 4 then '退款失败' when 5 then '已退款' else '其他' end RefundStatus, OrderID, MYOrderID, TPID, MTUserID, PaidTime, SalesPlanCount, SalesPlanSellPrice, SalesPlanSupplyPrice, TotalPrice from origindb.dp_myshow__s_order where ReserveStatus in (7,9) and PaidTime is not null and PaidTime>='2016-01-01' and PaidTime<'2017-12-03'
    ) so on so.OrderID=sos.OrderID
group by
    1,2,3
;
