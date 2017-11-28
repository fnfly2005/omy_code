
select
    sc.Name,
    sum(sos.SalesPlanTicketPrice*SalesPlanCount-(so.TotalPrice-sod.ExpressFee)) discount,
    sum(so.TotalPrice) TotalPrice
from
    (
    /*订单表*/ select case when TPID<6 then "渠道" else "自营" end tp_type, case SellChannel when 1 then "点评" when 2 then "美团" when 3 then "微信" when 4 then "小程序" when 5 then "猫眼" when 6 then "微信演出赛事" else "其他" end SellChannel, case RefundStatus when 0 then "未发起" when 1 then "发起失败" when 2 then "发起成功" when 3 then "退款中" when 4 then "退款失败" when 5 then "已退款" else "其他" end RefundStatus, OrderID, TPID, MTUserID, PaidTime, SalesPlanCount, SalesPlanSellPrice, SalesPlanSupplyPrice, TotalPrice from S_Order where ReserveStatus in (7,9) and PaidTime is not null and PaidTime>='2017-11-23' and PaidTime<'2017-11-24'
    ) so
   join (
    /*快递记录表*/ select OrderID, ExpressFee from S_OrderDelivery where CreateTime>='2017-11-22' and CreateTime<'2017-11-24'
    ) sod using(OrderID)
    join (
    /*交易时销售计划快照表*/ select OrderID, PerformanceName, PerformanceID, ShowName, TicketID TicketClassID, SalesPlanTicketPrice from S_OrderSalesPlanSnapshot where CreateTime>='2017-11-22' and CreateTime<'2017-11-24'
    ) sos on so.OrderID=sos.OrderID
    left join (
    /*演出项目信息表*/ select PerformanceID, CategoryID from S_Performance
    ) sp on sp.PerformanceID=sos.PerformanceID
    left join (
    /*类别表*/ select CategoryID, Name from S_Category
    ) sc on sc.CategoryID=sp.CategoryID
where
    so.TotalPrice-sod.ExpressFee-sos.SalesPlanTicketPrice*SalesPlanCount<0
group by
    1
limit 100

