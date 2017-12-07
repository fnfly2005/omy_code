select
    substr(so.PaidTime,1,7) mt,
    dp.province_name,
    sc.Name,
    case when so.tp_type='渠道' then scu.ShortName
    else so.tp_type end tp_type,
    count(distinct sos.PerformanceID) p_num,
    count(distinct so.OrderID) so_num,
    sum(so.TotalPrice) TotalPrice,
    sum(so.SalesPlanCount*sos.SetNum) tic_num,
    sum(ssp.GrossProfit) GrossProfit
from
    (
    select case when TPID<6 then '渠道' else '自营' end tp_type, case SellChannel when 1 then '点评' when 2 then '美团' when 3 then '微信' when 4 then '小程序' when 5 then '猫眼' when 6 then '微信演出赛事' when 7 then '微信钱包-小程序' else '其他' end SellChannel, case RefundStatus when 0 then '未发起' when 1 then '发起失败' when 2 then '发起成功' when 3 then '退款中' when 4 then '退款失败' when 5 then '已退款' else '其他' end RefundStatus, OrderID, MYOrderID, TPID, MTUserID, PaidTime, SalesPlanCount, SalesPlanSellPrice, SalesPlanSupplyPrice, TotalPrice from origindb.dp_myshow__s_order where ReserveStatus in (7,9) and PaidTime is not null and PaidTime>='2017-01-01' and PaidTime<'2017-12-01'
    ) so 
    join 
    (
    select OrderID, PerformanceName, PerformanceID, ShowName, TicketID TicketClassID, SalesPlanTicketPrice, SetNum from origindb.dp_myshow__s_ordersalesplansnapshot where OrderID is not null and CreateTime>='2016-12-31' and CreateTime<'2017-12-01'
    ) sos 
    on so.OrderID=sos.OrderID
    join 
    (
    select OrderID, GrossProfit from origindb.dp_myshow__s_settlementpayment where OrderID is not null and PayTime>='2017-01-01' and PayTime<'2017-12-01'
    ) ssp
    on so.OrderID=ssp.OrderID
    left join 
    (
    select PerformanceID, CategoryID, cityid, bsperformanceid, TicketStatus from origindb.dp_myshow__s_performance where PerformanceID is not null
    ) sp 
    on sos.PerformanceID=sp.PerformanceID
    join 
    (
    select TPID, Name, ShortName from origindb.dp_myshow__s_customer where TPID is not null
    ) scu on scu.TPID=so.TPID
    left join
    (
    select CategoryID, Name from origindb.dp_myshow__S_Category where CategoryID is not null
    ) sc on sp.CategoryID=sc.CategoryID
    left join 
    (
    select cityid, ProvinceID, cityname from origindb.dp_myshow__s_dpcitylist where cityid is not null
    ) sd
    on sd.cityid=sp.CityID
    left join 
    (
    select province_id, province_name from upload_table.dim_province
    ) dp on dp.province_id=sd.ProvinceID
group by
    1,2,3,4
;
/*在线项目数*/
select
    dp.province_name,
    sc.Name,
    case when bam.tp_type='渠道' then scu.ShortName
    else bam.tp_type end tp_type,
    count(distinct case when sp.BSPerformanceID is not null then sp.BSPerformanceID else sp.PerformanceID end) a_p_num
from
    (
    select PerformanceID, CategoryID, cityid, bsperformanceid, TicketStatus from origindb.dp_myshow__s_performance where PerformanceID is not null
    and TicketStatus in (2,3)
    and EditStatus=1
    ) sp 
    left join
    (
    select ActivityID, case when TPID<6 then '渠道' else '自营' end tp_type, TPID, TPSProjectID from origindb.dp_myshow__bs_activitymap where TPID is not null
    ) bam on sp.BSPerformanceID=bam.ActivityID
    left join 
    (
    select CategoryID, Name from origindb.dp_myshow__S_Category where CategoryID is not null
    ) sc on sp.CategoryID=sc.CategoryID
    left join 
    (
    select cityid, ProvinceID, cityname from origindb.dp_myshow__s_dpcitylist where cityid is not null
    ) sd
    on sd.cityid=sp.CityID
    left join 
    (
    select province_id, province_name from upload_table.dim_province
    ) dp on dp.province_id=sd.ProvinceID
    left join 
    (
    select TPID, Name, ShortName from origindb.dp_myshow__s_customer where TPID is not null
    ) scu on scu.TPID=bam.TPID
group by
    1,2,3
;
