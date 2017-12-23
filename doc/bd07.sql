
select
    substr(so.PaidTime,1,7) mt,
    dc.customer_type_name,
    dmp.category_name,
    dmp.area_1_level_name,
    dmp.area_2_level_name,
    dmp.province_name,
    sum(TotalPrice) TotalPrice
from
    (
    select case SellChannel when 1 then '点评' when 2 then '美团' when 3 then '微信吃喝玩乐' when 4 then '微信搜索小程序' when 5 then '猫眼' else case when SellChannel in (6,7) then '微信演出赛事' else '未知' end end SellChannel, case ReserveStatus when 8 then '出票失败' when 9 then '出票成功' when 7 then '出票中' when 6 then '支付成功' else '未知' end ReserveStatus, case RefundStatus when 0 then '未发起' when 1 then '发起失败' when 2 then '发起成功' when 3 then '退款中' when 4 then '退款失败' when 5 then '已退款' else '未知' end RefundStatus, OrderID, MYOrderID, TPID, MTUserID, PaidTime, SalesPlanCount, SalesPlanSellPrice, SalesPlanSupplyPrice, TotalPrice from origindb.dp_myshow__s_order where ReserveStatus>=6 and PaidTime is not null and PaidTime>='$time1' and PaidTime<'$time2'
    ) so
    join
    (
    select OrderID, PerformanceName, PerformanceID performance_id, ShowName, TicketID TicketClassID, SalesPlanTicketPrice, SetNum from origindb.dp_myshow__s_ordersalesplansnapshot where OrderID is not null and CreateTime>=substr(date_add('day',-1,timestamp'$time1'),1,10) and CreateTime<'$time2'
    ) sos
    on so.OrderID=sos.OrderID
    join
    (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name from mart_movie.dim_myshow_performance
    ) dmp
    on sos.performance_id=dmp.performance_id
    join 
    (
    select customer_id, case when customer_type_id=1 then customer_shortname else customer_type_name end customer_lvl0_name, customer_type_id, customer_type_name from mart_movie.dim_myshow_customer where customer_id is not null
    ) dc
    on so.TPID=dc.customer_id
group by
    1,2,3,4,5,6
;
