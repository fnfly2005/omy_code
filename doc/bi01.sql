
select
    -99 as customer_type_id,
    -99 as area_1_level_name,
    sum(TotalPrice) TotalPrice,
    sum(GrossProfit) GrossProfit,
    count(distinct case when activity_id is not null then activity_id 
    else dp.performance_id end) performance_num
from
    (
    select OrderID, TPID, TotalPrice, GrossProfit from origindb.dp_myshow__s_settlementpayment where OrderID is not null and PayTime>='2017-12-11' and PayTime<'2017-12-12'
    ) ssp
    join 
    (
    select OrderID, PerformanceName, PerformanceID performance_id, ShowName, TicketID TicketClassID, SalesPlanTicketPrice, SetNum from origindb.dp_myshow__s_ordersalesplansnapshot where OrderID is not null and CreateTime>='2017-12-10' and CreateTime<'2017-12-12'
    ) sos
    on ssp.OrderID=sos.OrderID
    left join 
    (
    select performance_id, activity_id, performance_name, area_1_level_name, area_2_level_name from mart_movie.dim_myshow_performance
    ) dp
    on dp.performance_id=sos.performance_id
    left join 
    (
    select customer_id, case when customer_type_id=1 then customer_shortname else customer_type_name end customer_type_name, customer_type_id from mart_movie.dim_myshow_customer where customer_id is not null
    ) dc
    on dc.customer_id=ssp.TPID
group by
    1,2
    
