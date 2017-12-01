
select
    s1.dt,
    s1.tp_type,
    s1.s_p_num,
    s2.a_p_num,
    s1.TotalPrice
from
(select
    substr(so.PaidTime,1,10) dt,
    'all' tp_type,
    count(distinct sos.PerformanceID) s_p_num,
    sum(so.TotalPrice) TotalPrice
from
    (
    select OrderID, PerformanceName, PerformanceID, ShowName, TicketID TicketClassID, SalesPlanTicketPrice, SetNum from origindb.dp_myshow__s_ordersalesplansnapshot where OrderID is not null and CreateTime>='2017-11-23' and CreateTime<'2017-12-01'
    ) sos
    join 
    (
    select case when TPID<6 then '渠道' else '自营' end tp_type, case SellChannel when 1 then '点评' when 2 then '美团' when 3 then '微信' when 4 then '小程序' when 5 then '猫眼' when 6 then '微信演出赛事' when 7 then '微信钱包-小程序' else '其他' end SellChannel, case RefundStatus when 0 then '未发起' when 1 then '发起失败' when 2 then '发起成功' when 3 then '退款中' when 4 then '退款失败' when 5 then '已退款' else '其他' end RefundStatus, OrderID, MYOrderID, TPID, MTUserID, PaidTime, SalesPlanCount, SalesPlanSellPrice, SalesPlanSupplyPrice, TotalPrice from origindb.dp_myshow__s_order where ReserveStatus in (7,9) and PaidTime is not null and PaidTime>='2017-11-24' and PaidTime<'2017-12-01'
    ) so on so.OrderID=sos.OrderID
group by
    1,2
union all
select
    substr(so.PaidTime,1,10) dt,
    so.tp_type,
    count(distinct sos.PerformanceID) s_p_num,
    sum(so.TotalPrice) TotalPrice
from
    (
    select OrderID, PerformanceName, PerformanceID, ShowName, TicketID TicketClassID, SalesPlanTicketPrice, SetNum from origindb.dp_myshow__s_ordersalesplansnapshot where OrderID is not null and CreateTime>='2017-11-23' and CreateTime<'2017-12-01'
    ) sos
    join 
    (
    select case when TPID<6 then '渠道' else '自营' end tp_type, case SellChannel when 1 then '点评' when 2 then '美团' when 3 then '微信' when 4 then '小程序' when 5 then '猫眼' when 6 then '微信演出赛事' when 7 then '微信钱包-小程序' else '其他' end SellChannel, case RefundStatus when 0 then '未发起' when 1 then '发起失败' when 2 then '发起成功' when 3 then '退款中' when 4 then '退款失败' when 5 then '已退款' else '其他' end RefundStatus, OrderID, MYOrderID, TPID, MTUserID, PaidTime, SalesPlanCount, SalesPlanSellPrice, SalesPlanSupplyPrice, TotalPrice from origindb.dp_myshow__s_order where ReserveStatus in (7,9) and PaidTime is not null and PaidTime>='2017-11-24' and PaidTime<'2017-12-01'
    ) so on so.OrderID=sos.OrderID
group by
    1,2) s1
join 
(select
    bam.tp_type,
    count(distinct sp.PerformanceID) a_p_num
from
    (
    select PerformanceID, CategoryID, cityid, bsperformanceid, TicketStatus from origindb.dp_myshow__s_performance where PerformanceID is not null
    and TicketStatus in (2,3)
    ) sp
    left join 
    (
    select ActivityID, case when TPID<6 then '渠道' else '自营' end tp_type, TPID, TPSProjectID from origindb.dp_myshow__bs_activitymap where TPID is not null
    ) bam on sp.BSPerformanceID=bam.ActivityID
group by
    1
union all
select
    'all' tp_type,
    count(distinct PerformanceID) a_p_num
from
    (
    select PerformanceID, CategoryID, cityid, bsperformanceid, TicketStatus from origindb.dp_myshow__s_performance where PerformanceID is not null
    and TicketStatus in (2,3)
    ) sp2
group by
    1
    ) s2 on s2.tp_type=s1.tp_type
union all
select
    'week' dt,
    s1.tp_type,
    s1.s_p_num,
    s2.a_p_num,
    s1.TotalPrice
from
(select
    'all' tp_type,
    count(distinct sos.PerformanceID) s_p_num,
    sum(so.TotalPrice) TotalPrice
from
    (
    select OrderID, PerformanceName, PerformanceID, ShowName, TicketID TicketClassID, SalesPlanTicketPrice, SetNum from origindb.dp_myshow__s_ordersalesplansnapshot where OrderID is not null and CreateTime>='2017-11-23' and CreateTime<'2017-12-01'
    ) sos
    join 
    (
    select case when TPID<6 then '渠道' else '自营' end tp_type, case SellChannel when 1 then '点评' when 2 then '美团' when 3 then '微信' when 4 then '小程序' when 5 then '猫眼' when 6 then '微信演出赛事' when 7 then '微信钱包-小程序' else '其他' end SellChannel, case RefundStatus when 0 then '未发起' when 1 then '发起失败' when 2 then '发起成功' when 3 then '退款中' when 4 then '退款失败' when 5 then '已退款' else '其他' end RefundStatus, OrderID, MYOrderID, TPID, MTUserID, PaidTime, SalesPlanCount, SalesPlanSellPrice, SalesPlanSupplyPrice, TotalPrice from origindb.dp_myshow__s_order where ReserveStatus in (7,9) and PaidTime is not null and PaidTime>='2017-11-24' and PaidTime<'2017-12-01'
    ) so on so.OrderID=sos.OrderID
group by
    1
union all
select
    so.tp_type,
    count(distinct sos.PerformanceID) s_p_num,
    sum(so.TotalPrice) TotalPrice
from
    (
    select OrderID, PerformanceName, PerformanceID, ShowName, TicketID TicketClassID, SalesPlanTicketPrice, SetNum from origindb.dp_myshow__s_ordersalesplansnapshot where OrderID is not null and CreateTime>='2017-11-23' and CreateTime<'2017-12-01'
    ) sos
    join 
    (
    select case when TPID<6 then '渠道' else '自营' end tp_type, case SellChannel when 1 then '点评' when 2 then '美团' when 3 then '微信' when 4 then '小程序' when 5 then '猫眼' when 6 then '微信演出赛事' when 7 then '微信钱包-小程序' else '其他' end SellChannel, case RefundStatus when 0 then '未发起' when 1 then '发起失败' when 2 then '发起成功' when 3 then '退款中' when 4 then '退款失败' when 5 then '已退款' else '其他' end RefundStatus, OrderID, MYOrderID, TPID, MTUserID, PaidTime, SalesPlanCount, SalesPlanSellPrice, SalesPlanSupplyPrice, TotalPrice from origindb.dp_myshow__s_order where ReserveStatus in (7,9) and PaidTime is not null and PaidTime>='2017-11-24' and PaidTime<'2017-12-01'
    ) so on so.OrderID=sos.OrderID
group by
    1) s1
join 
(select
    bam.tp_type,
    count(distinct sp.PerformanceID) a_p_num
from
    (
    select PerformanceID, CategoryID, cityid, bsperformanceid, TicketStatus from origindb.dp_myshow__s_performance where PerformanceID is not null
    and TicketStatus in (2,3)
    ) sp
    left join 
    (
    select ActivityID, case when TPID<6 then '渠道' else '自营' end tp_type, TPID, TPSProjectID from origindb.dp_myshow__bs_activitymap where TPID is not null
    ) bam on sp.BSPerformanceID=bam.ActivityID
group by
    1
union all
select
    'all' tp_type,
    count(distinct PerformanceID) a_p_num
from
    (
    select PerformanceID, CategoryID, cityid, bsperformanceid, TicketStatus from origindb.dp_myshow__s_performance where PerformanceID is not null
    and TicketStatus in (2,3)
    ) sp2
group by
    1
    ) s2 on s2.tp_type=s1.tp_type
;

select
    dt,
    tp_type,
    PerformanceID,
    PerformanceName,
    TotalPrice,
    rank
from
(select
    dt,
    tp_type,
    PerformanceID,
    PerformanceName,
    TotalPrice,
    row_number() over (PARTITION BY dt,tp_type order by TotalPrice desc) rank
from
(select
    substr(so.PaidTime,1,10) dt,
    'all' tp_type,
    sos.PerformanceID,
    sos.PerformanceName,
    sum(so.TotalPrice) TotalPrice
from
    (
    select OrderID, PerformanceName, PerformanceID, ShowName, TicketID TicketClassID, SalesPlanTicketPrice, SetNum from origindb.dp_myshow__s_ordersalesplansnapshot where OrderID is not null and CreateTime>='2017-11-23' and CreateTime<'2017-12-01'
    ) sos
    join 
    (
    select case when TPID<6 then '渠道' else '自营' end tp_type, case SellChannel when 1 then '点评' when 2 then '美团' when 3 then '微信' when 4 then '小程序' when 5 then '猫眼' when 6 then '微信演出赛事' when 7 then '微信钱包-小程序' else '其他' end SellChannel, case RefundStatus when 0 then '未发起' when 1 then '发起失败' when 2 then '发起成功' when 3 then '退款中' when 4 then '退款失败' when 5 then '已退款' else '其他' end RefundStatus, OrderID, MYOrderID, TPID, MTUserID, PaidTime, SalesPlanCount, SalesPlanSellPrice, SalesPlanSupplyPrice, TotalPrice from origindb.dp_myshow__s_order where ReserveStatus in (7,9) and PaidTime is not null and PaidTime>='2017-11-24' and PaidTime<'2017-12-01'
    ) so on so.OrderID=sos.OrderID
group by
    1,2,3,4
union all
select
    substr(so.PaidTime,1,10) dt,
    so.tp_type,
    sos.PerformanceID,
    sos.PerformanceName,
    sum(so.TotalPrice) TotalPrice
from
    (
    select OrderID, PerformanceName, PerformanceID, ShowName, TicketID TicketClassID, SalesPlanTicketPrice, SetNum from origindb.dp_myshow__s_ordersalesplansnapshot where OrderID is not null and CreateTime>='2017-11-23' and CreateTime<'2017-12-01'
    ) sos
    join 
    (
    select case when TPID<6 then '渠道' else '自营' end tp_type, case SellChannel when 1 then '点评' when 2 then '美团' when 3 then '微信' when 4 then '小程序' when 5 then '猫眼' when 6 then '微信演出赛事' when 7 then '微信钱包-小程序' else '其他' end SellChannel, case RefundStatus when 0 then '未发起' when 1 then '发起失败' when 2 then '发起成功' when 3 then '退款中' when 4 then '退款失败' when 5 then '已退款' else '其他' end RefundStatus, OrderID, MYOrderID, TPID, MTUserID, PaidTime, SalesPlanCount, SalesPlanSellPrice, SalesPlanSupplyPrice, TotalPrice from origindb.dp_myshow__s_order where ReserveStatus in (7,9) and PaidTime is not null and PaidTime>='2017-11-24' and PaidTime<'2017-12-01'
    ) so on so.OrderID=sos.OrderID
group by
    1,2,3,4) s1
    ) s2
where
    rank<=10
union all
select
    'week' dt,
    tp_type,
    PerformanceID,
    PerformanceName,
    TotalPrice,
    rank
from
(select
    tp_type,
    PerformanceID,
    PerformanceName,
    TotalPrice,
    row_number() over (PARTITION BY tp_type order by TotalPrice desc) rank
from
(select
    'all' tp_type,
    sos.PerformanceID,
    sos.PerformanceName,
    sum(so.TotalPrice) TotalPrice
from
    (
    select OrderID, PerformanceName, PerformanceID, ShowName, TicketID TicketClassID, SalesPlanTicketPrice, SetNum from origindb.dp_myshow__s_ordersalesplansnapshot where OrderID is not null and CreateTime>='2017-11-23' and CreateTime<'2017-12-01'
    ) sos
    join 
    (
    select case when TPID<6 then '渠道' else '自营' end tp_type, case SellChannel when 1 then '点评' when 2 then '美团' when 3 then '微信' when 4 then '小程序' when 5 then '猫眼' when 6 then '微信演出赛事' when 7 then '微信钱包-小程序' else '其他' end SellChannel, case RefundStatus when 0 then '未发起' when 1 then '发起失败' when 2 then '发起成功' when 3 then '退款中' when 4 then '退款失败' when 5 then '已退款' else '其他' end RefundStatus, OrderID, MYOrderID, TPID, MTUserID, PaidTime, SalesPlanCount, SalesPlanSellPrice, SalesPlanSupplyPrice, TotalPrice from origindb.dp_myshow__s_order where ReserveStatus in (7,9) and PaidTime is not null and PaidTime>='2017-11-24' and PaidTime<'2017-12-01'
    ) so on so.OrderID=sos.OrderID
group by
    1,2,3
union all
select
    so.tp_type,
    sos.PerformanceID,
    sos.PerformanceName,
    sum(so.TotalPrice) TotalPrice
from
    (
    select OrderID, PerformanceName, PerformanceID, ShowName, TicketID TicketClassID, SalesPlanTicketPrice, SetNum from origindb.dp_myshow__s_ordersalesplansnapshot where OrderID is not null and CreateTime>='2017-11-23' and CreateTime<'2017-12-01'
    ) sos
    join 
    (
    select case when TPID<6 then '渠道' else '自营' end tp_type, case SellChannel when 1 then '点评' when 2 then '美团' when 3 then '微信' when 4 then '小程序' when 5 then '猫眼' when 6 then '微信演出赛事' when 7 then '微信钱包-小程序' else '其他' end SellChannel, case RefundStatus when 0 then '未发起' when 1 then '发起失败' when 2 then '发起成功' when 3 then '退款中' when 4 then '退款失败' when 5 then '已退款' else '其他' end RefundStatus, OrderID, MYOrderID, TPID, MTUserID, PaidTime, SalesPlanCount, SalesPlanSellPrice, SalesPlanSupplyPrice, TotalPrice from origindb.dp_myshow__s_order where ReserveStatus in (7,9) and PaidTime is not null and PaidTime>='2017-11-24' and PaidTime<'2017-12-01'
    ) so on so.OrderID=sos.OrderID
group by
    1,2,3) s1
    ) s2
where
    rank<=10
;
