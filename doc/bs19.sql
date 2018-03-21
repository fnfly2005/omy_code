
select
    CityName,
    count(distinct so.OrderID) Order_num,
    sum(so.TotalPrice) TotalPrice
from (
    /*交易时销售计划快照表*/ select OrderID, PerformanceName, PerformanceID, ShowName, TicketID TicketClassID, SalesPlanTicketPrice from S_OrderSalesPlanSnapshot where OrderID>=1007457 and OrderID<1037693
    and PerformanceID=34150
    ) sos
    join ( 
    /*订单表*/ select case when TPID<6 then "渠道" else "自营" end tp_type, case SellChannel when 1 then "点评" when 2 then "美团" when 3 then "微信吃喝玩乐" when 4 then "微信演出赛事" when 5 then "猫眼" when 6 then "微信演出赛事" when 7 then "微信演出赛事" when 8 then "格瓦拉" else "其他" end SellChannel, case RefundStatus when 0 then "未发起" when 1 then "发起失败" when 2 then "发起成功" when 3 then "退款中" when 4 then "退款失败" when 5 then "已退款" else "其他" end RefundStatus, OrderID, TPID, MTUserID, PaidTime, SalesPlanCount, SalesPlanSellPrice, SalesPlanSupplyPrice, TotalPrice from S_Order where PaidTime is not null and OrderID>=1007457 and OrderID<1037693
    ) so
    using(OrderID)
    join (
    /*快递记录表*/ select OrderID, CityName, ExpressFee from S_OrderDelivery where OrderID>=1007457 and OrderID<1037693
    ) sod
    on sod.OrderID=sos.OrderID
group by
    1
;
