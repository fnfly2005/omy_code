select
    substr(so.PaidTime,1,7) mt,
    case when so.tp_type='渠道' then scu.ShortName
    else so.tp_type end tp_type,
    SellChannel,
    count(distinct so.OrderID) so_num,
    sum(so.TotalPrice) TotalPrice,
    sum(so.SalesPlanCount*sos.SetNum) tic_num
from
    (
    select case when TPID<6 then '渠道' else '自营' end tp_type, case SellChannel when 1 then '点评' when 2 then '美团' when 3 then '微信' when 4 then '小程序' when 5 then '猫眼' when 6 then '微信演出赛事' when 7 then '微信钱包-小程序' else '其他' end SellChannel, case RefundStatus when 0 then '未发起' when 1 then '发起失败' when 2 then '发起成功' when 3 then '退款中' when 4 then '退款失败' when 5 then '已退款' else '其他' end RefundStatus, OrderID, MYOrderID, TPID, MTUserID, PaidTime, SalesPlanCount, SalesPlanSellPrice, SalesPlanSupplyPrice, TotalPrice from origindb.dp_myshow__s_order where ReserveStatus in (7,9) and PaidTime is not null and PaidTime>='2017-10-01' and PaidTime<'2017-12-01'
    ) so
    join 
    (
    select OrderID, PerformanceName, PerformanceID, ShowName, TicketID TicketClassID, SalesPlanTicketPrice, SetNum from origindb.dp_myshow__s_ordersalesplansnapshot where OrderID is not null and CreateTime>='2017-09-30' and CreateTime<'2017-12-01'
    ) sos on so.OrderID=sos.OrderID
    left join (
    select TPID, Name, ShortName from origindb.dp_myshow__s_customer where TPID is not null
    ) scu on scu.TPID=so.TPID
group by
    1,2,3
;
