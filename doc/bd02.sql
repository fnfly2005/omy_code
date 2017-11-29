select
    substr(so.PaidTime,1,7) mt,
    sd.cityname,
    sc.Name,
    so.tp_type,
    count(distinct sos.PerformanceID) p_num,
    count(distinct so.OrderID) so_num,
    sum(so.TotalPrice) TotalPrice,
    sum(so.SalesPlanCount*sos.SetNum) tic_num
from
    (
    /*点评城市维表*/ select cityid, cityname from origindb.dp_myshow__s_dpcitylist where cityid is not null
    and cityname in ('北京','天津')
    ) sd
    join 
    (
    /*演出项目信息表*/ select PerformanceID, CategoryID, cityid, bsperformanceid from origindb.dp_myshow__s_performance where PerformanceID is not null
    ) sp on sd.cityid=sp.CityID
    left join
    (
    /*类别表*/ select CategoryID, Name from origindb.dp_myshow__S_Category where CategoryID is not null
    ) sc on sp.CategoryID=sc.CategoryID
    join 
    (
    /*交易时销售计划快照表*/ select OrderID, PerformanceName, PerformanceID, ShowName, TicketID TicketClassID, SalesPlanTicketPrice, SetNum from origindb.dp_myshow__s_ordersalesplansnapshot where OrderID is not null and CreateTime>='2016-12-31' and CreateTime<'2017-11-29'
    ) sos on sos.PerformanceID=sp.PerformanceID
    join 
    (
    /*订单表*/ select case when TPID<6 then '渠道' else '自营' end tp_type, case SellChannel when 1 then '点评' when 2 then '美团' when 3 then '微信' when 4 then '小程序' when 5 then '猫眼' when 6 then '微信演出赛事' else '其他' end SellChannel, case RefundStatus when 0 then '未发起' when 1 then '发起失败' when 2 then '发起成功' when 3 then '退款中' when 4 then '退款失败' when 5 then '已退款' else '其他' end RefundStatus, OrderID, TPID, MTUserID, PaidTime, SalesPlanCount, SalesPlanSellPrice, SalesPlanSupplyPrice, TotalPrice from origindb.dp_myshow__s_order where ReserveStatus in (7,9) and PaidTime is not null and PaidTime>='2017-01-01' and PaidTime<'2017-11-29'
    ) so on sos.OrderID=sos.OrderID
group by
    1,2,3,4
;
select
    substr(bam.CreateTime,1,7) mt,
    sd.cityname,
    sc.Name,
    bam.tp_type,
    count(distinct sp.PerformanceID) p_num,
from
    (
    /*点评城市维表*/ select cityid, cityname from origindb.dp_myshow__s_dpcitylist where cityid is not null
    and cityname in ('北京','天津')
    ) sd
    join 
    (
    /*演出项目信息表*/ select PerformanceID, CategoryID, cityid, bsperformanceid from origindb.dp_myshow__s_performance where PerformanceID is not null
    ) sp on sd.cityid=sp.CityID
    left join
    (
    /*类别表*/ select CategoryID, Name from origindb.dp_myshow__S_Category where CategoryID is not null
    ) sc on sp.CategoryID=sc.CategoryID
    left join 
    (
    /*演出项目商品匹配表*/ select ActivityID, case when TPID<6 then '渠道' else '自营' end tp_type, TPID, TPSProjectID from origindb.dp_myshow__bs_activitymap where TPID is not null
    ) bam on bam.ActivityID=sp.bsperformanceid
group by
    1,2,3,4
;
