
select
    sp.dt,
    sp.city_name,
    performance_name,
    pv,
    uv,
    Order_num,
    TotalPrice,
    GrossProfit
from
    (select
    substr(ssp.PayTime,1,10) dt,
    dp.city_name,
    dp.performance_id,
    dp.performance_name,
    count(distinct ssp.OrderID) Order_num,
    sum(TotalPrice) TotalPrice,
    sum(GrossProfit) GrossProfit
from
    (
    select OrderID, TPID, PayTime, TotalPrice, GrossProfit from origindb.dp_myshow__s_settlementpayment where OrderID is not null and PayTime>='$time1' and PayTime<'$time2'
    ) ssp
    join 
    (
    select OrderID, PerformanceName, PerformanceID performance_id, ShowName, TicketID TicketClassID, SalesPlanTicketPrice, SetNum from origindb.dp_myshow__s_ordersalesplansnapshot where OrderID is not null and CreateTime>=substr(date_add('day',-1,timestamp'$time1'),1,10) and CreateTime<'$time2'
    ) sos
    on ssp.OrderID=sos.OrderID
    left join 
    (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, city_id, city_name from mart_movie.dim_myshow_performance
    ) dp
    on sos.performance_id=dp.performance_id
group by
    1,2,3,4) sp
left join 
(select
    dt,
    performance_id,
    count(1) pv,
    count(distinct union_id) uv
from
    (
    select partition_date dt, union_id, case when page_id='40000390' then custom['performance_id'] end performance_id from mart_flow.detail_flow_pv_wide_report where partition_date>='$time1' and partition_date<'$time2'
    ) fp
where
    performance_id is not null
group by
    1,2) vp
    on sp.performance_id=vp.performance_id
    and sp.dt=vp.dt
;

select
    sp.dt,
    sp.city_name,
    sp.category_name,
    pv,
    uv,
    Order_num,
    TotalPrice,
    GrossProfit
from
    (select
    substr(ssp.PayTime,1,10) dt,
    dp.city_id,
    dp.city_name,
    dp.category_id,
    dp.category_name,
    count(distinct ssp.OrderID) Order_num,
    sum(TotalPrice) TotalPrice,
    sum(GrossProfit) GrossProfit
from
    (
    select OrderID, TPID, PayTime, TotalPrice, GrossProfit from origindb.dp_myshow__s_settlementpayment where OrderID is not null and PayTime>='$time1' and PayTime<'$time2'
    ) ssp
    join 
    (
    select OrderID, PerformanceName, PerformanceID performance_id, ShowName, TicketID TicketClassID, SalesPlanTicketPrice, SetNum from origindb.dp_myshow__s_ordersalesplansnapshot where OrderID is not null and CreateTime>=substr(date_add('day',-1,timestamp'$time1'),1,10) and CreateTime<'$time2'
    ) sos
    on ssp.OrderID=sos.OrderID
    left join 
    (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, city_id, city_name from mart_movie.dim_myshow_performance
    ) dp
    on sos.performance_id=dp.performance_id
group by
    1,2,3,4,5) sp
left join 
(select
    dt,
    dp.city_id,
    dp.category_id,
    count(1) pv,
    count(distinct union_id) uv
from
    (
    select partition_date dt, union_id, case when page_id='40000390' then custom['performance_id'] end performance_id from mart_flow.detail_flow_pv_wide_report where partition_date>='$time1' and partition_date<'$time2'
    ) fp
    join
    (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, city_id, city_name from mart_movie.dim_myshow_performance
    ) dp
    on fp.performance_id=dp.performance_id 
    and fp.performance_id is not null
group by
    1,2,3) vp
    on sp.city_id=vp.city_id
    and sp.dt=vp.dt
    and sp.category_id=vp.category_id
;
