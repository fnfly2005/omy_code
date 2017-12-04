select
    substr(so.PaidTime,1,10) dt,
    case when so.tp_type='渠道' then sc.ShortName
    else so.tp_type end tp_type,
    count(distinct so.OrderID) Order_num,
    count(distinct so.MTUserID) user_num,
    sum(so.SalesPlanCount) sp_num,
    sum(so.SalesPlanCount*sos.SetNum) st_num,
    sum(so.TotalPrice) TotalPrice,
    sum(sod.ExpressFee) ExpressFee,
    sum(so.SalesPlanCount*so.SalesPlanSupplyPrice) SupplyPrice
from
    (
    select OrderID, PerformanceName, PerformanceID, ShowName, TicketID TicketClassID, SalesPlanTicketPrice, SetNum from origindb.dp_myshow__s_ordersalesplansnapshot where OrderID is not null and CreateTime>='2017-09-30' and CreateTime<'2017-11-01'
    ) sos 
    join (
    select case when TPID<6 then '渠道' else '自营' end tp_type, case SellChannel when 1 then '点评' when 2 then '美团' when 3 then '微信' when 4 then '小程序' when 5 then '猫眼' when 6 then '微信演出赛事' when 7 then '微信钱包-小程序' else '其他' end SellChannel, case RefundStatus when 0 then '未发起' when 1 then '发起失败' when 2 then '发起成功' when 3 then '退款中' when 4 then '退款失败' when 5 then '已退款' else '其他' end RefundStatus, OrderID, MYOrderID, TPID, MTUserID, PaidTime, SalesPlanCount, SalesPlanSellPrice, SalesPlanSupplyPrice, TotalPrice from origindb.dp_myshow__s_order where ReserveStatus in (7,9) and PaidTime is not null and PaidTime>='2017-10-01' and PaidTime<'2017-11-01'
    ) so
    on sos.orderid=so.orderid
    left join (
    select TPID, Name, ShortName from origindb.dp_myshow__s_customer where TPID is not null
    ) sc
    on sc.TPID=so.TPID
    left join (
    select OrderID, ExpressFee from origindb.dp_myshow__s_orderdelivery where OrderDeliveryID is not null and CreateTime>='2017-09-30' and CreateTime<'2017-11-01'
    ) sod on sod.orderid=so.orderid
group by
    1,2
;

select
    case when ssp.tp_type='渠道' then scu.ShortName
    else ssp.tp_type end tp_type,
    sum(GrossProfit) GrossProfit
from
    (
    select GrossProfit, TPID, case when TPID<6 then "渠道" else "自营" end tp_type from S_SettlementPayment where SettlementPaymentID is not null and PayTime>='2017-10-01' and PayTime<'2017-11-01'
    ) ssp
    left join 
    (
    select TPID, Name, ShortName from S_Customer where TPID is not null
    ) scu 
    on ssp.TPID=scu.TPID
group by
    1
;
