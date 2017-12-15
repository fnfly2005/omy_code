select
    substr(so.PaidTime,1,7) mt,
    count(distinct so.MTUserID) s_uv,
    count(distinct so.orderid) s_o,
    sum(so.TotalPrice) gmv,
    sum(ssp.GrossProfit) gp
from
    (
    select OrderID, GrossProfit from origindb.dp_myshow__s_settlementpayment where OrderID is not null and PayTime>='2017-01-01' and PayTime<'2017-12-01'
    ) ssp
    join 
    (
    select case when TPID<6 then '渠道' else '自营' end tp_type, case SellChannel when 1 then '点评' when 2 then '美团' when 3 then '微信' when 4 then '小程序' when 5 then '猫眼' when 6 then '微信演出赛事' when 7 then '微信钱包-小程序' else '其他' end SellChannel, case RefundStatus when 0 then '未发起' when 1 then '发起失败' when 2 then '发起成功' when 3 then '退款中' when 4 then '退款失败' when 5 then '已退款' else '其他' end RefundStatus, OrderID, MYOrderID, TPID, MTUserID, PaidTime, SalesPlanCount, SalesPlanSellPrice, SalesPlanSupplyPrice, TotalPrice from origindb.dp_myshow__s_order where ReserveStatus in (7,9) and PaidTime is not null and PaidTime>='2017-01-01' and PaidTime<'2017-12-01'
    ) so
    on ssp.orderid=so.orderid
group by
    1

