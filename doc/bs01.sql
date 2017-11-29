select
    substr(so.PaidTime,1,10) dt,
    sp.PerformanceID,
    sos.PerformanceName,
    bam.TPSProjectID,
    so.TPID,
    so.tp_type,
    sc.Name,
    count(distinct so.OrderID) Order_num,
    count(distinct so.MTUserID) user_num,
    count(distinct 
        case when so.RefundStatus='已退款' 
        then so.MTUserID end) re_user_num,
    sum(so.SalesPlanCount) sp_num,
    sum(so.TotalPrice) TotalPrice,
    sum(case when so.RefundStatus='已退款' 
        then so.TotalPrice end) re_TotalPrice,
    sum(sod.ExpressFee) ExpressFee,
    sum(so.SalesPlanCount*so.SalesPlanSupplyPrice) SupplyPrice
from
    (
    /*演出项目信息表*/ select PerformanceID, CategoryID, bsperformanceid from origindb.dp_myshow__s_performance where PerformanceID is not null
    and PerformanceID=24173
    ) sp 
    join (
    /*交易时销售计划快照表*/ select OrderID, PerformanceName, PerformanceID, ShowName, TicketID TicketClassID, SalesPlanTicketPrice from origindb.dp_myshow__s_ordersalesplansnapshot where OrderID is not null and CreateTime>='2017-11-14' and CreateTime<'2017-11-29'
    and PerformanceID=24173
    ) sos 
    on sp.PerformanceID=sos.PerformanceID
    join (
    /*订单表*/ select case when TPID<6 then '渠道' else '自营' end tp_type, case SellChannel when 1 then '点评' when 2 then '美团' when 3 then '微信' when 4 then '小程序' when 5 then '猫眼' when 6 then '微信演出赛事' else '其他' end SellChannel, case RefundStatus when 0 then '未发起' when 1 then '发起失败' when 2 then '发起成功' when 3 then '退款中' when 4 then '退款失败' when 5 then '已退款' else '其他' end RefundStatus, OrderID, TPID, MTUserID, PaidTime, SalesPlanCount, SalesPlanSellPrice, SalesPlanSupplyPrice, TotalPrice from origindb.dp_myshow__s_order where ReserveStatus in (7,9) and PaidTime is not null and PaidTime>='2017-11-15' and PaidTime<'2017-11-29'
    ) so
    on sos.orderid=so.orderid
    left join (
    /*演出客户表*/ select TPID, Name from origindb.dp_myshow__s_customer where TPID is not null
    ) sc
    on sc.TPID=so.TPID
    left join (
    /*演出项目商品匹配表*/ select ActivityID, TPID, TPSProjectID from origindb.dp_myshow__bs_activitymap where TPID is not null
    ) bam
    on bam.TPID=so.TPID and bam.ActivityID=sp.bsperformanceid
    left join (
    /*快递记录表*/ select OrderID, ExpressFee from origindb.dp_myshow__s_orderdelivery where OrderDeliveryID is not null and CreateTime>='2017-11-14' and CreateTime<'2017-11-29'
    ) sod on sod.orderid=so.orderid
group by
    1,2,3,4,5,6,7;
select
    partition_date,
    count(distinct union_id) uv
from
    (
    /*新美大流量宽表*/ select partition_date, union_id from mart_flow.detail_flow_pv_wide_report where partition_date>='2017-11-15' and partition_date<'2017-11-29'
    and page_id=40000390
    and custom['performance_id']=24173
    ) md
group by
    1
