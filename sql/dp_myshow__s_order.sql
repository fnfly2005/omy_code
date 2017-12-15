/*订单表*/
select
    case SellChannel
        when 1 then '点评'
        when 2 then '美团'
        when 3 then '微信吃喝玩乐'
        when 4 then '微信搜索小程序'
        when 5 then '猫眼'
    else 
        case when SellChannel in (6,7) then '微信演出赛事'
        else '未知' 
        end 
    end SellChannel,
    case ReserveStatus 
        when 8 then '出票失败'
        when 9 then '出票成功'
        when 7 then '出票中'
        when 6 then '支付成功'
        else '未知'
        end ReserveStatus,
    case RefundStatus
        when 0 then '未发起'
        when 1 then '发起失败'
        when 2 then '发起成功'
        when 3 then '退款中'
        when 4 then '退款失败'
        when 5 then '已退款'
    else '未知' end RefundStatus,
    OrderID,
    MYOrderID,
    TPID,
    MTUserID,
    PaidTime,
    SalesPlanCount,
    SalesPlanSellPrice,
    SalesPlanSupplyPrice,
    TotalPrice
from
    origindb.dp_myshow__s_order
where
    ReserveStatus>=6
    and PaidTime is not null
    and PaidTime>='$time1'
    and PaidTime<'$time2'
