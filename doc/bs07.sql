
select
    substr(PaidTime,1,7) mt,
    sum(TotalPrice) TotalPrice,
    sum(SetNum*SalesPlanCount) t_num,
    count(distinct so.OrderID) so_nume,
    count(distinct performance_id) sp_num
from
    (
    select case SellChannel when 1 then '点评' when 2 then '美团' when 3 then '微信吃喝玩乐' when 4 then '微信搜索小程序' when 5 then '猫眼' else case when SellChannel in (6,7) then '微信演出赛事' else '未知' end end SellChannel, case ReserveStatus when 8 then '出票失败' when 9 then '出票成功' when 7 then '出票中' when 6 then '支付成功' else '未知' end ReserveStatus, case RefundStatus when 0 then '未发起' when 1 then '发起失败' when 2 then '发起成功' when 3 then '退款中' when 4 then '退款失败' when 5 then '已退款' else '未知' end RefundStatus, OrderID, MYOrderID, TPID, MTUserID, PaidTime, SalesPlanCount, SalesPlanSellPrice, SalesPlanSupplyPrice, TotalPrice from origindb.dp_myshow__s_order where ReserveStatus>=6 and PaidTime is not null and PaidTime>='2017-12-12' and PaidTime<'2017-12-13'
    ) so
    join 
    (
    select OrderID, PerformanceName, PerformanceID performance_id, ShowName, TicketID TicketClassID, SalesPlanTicketPrice, SetNum from origindb.dp_myshow__s_ordersalesplansnapshot where OrderID is not null and CreateTime>='2017-12-11' and CreateTime<'2017-12-13'
    ) sos
    on so.OrderID=sos.OrderID
group by
    1
;

select
    count(distinct shop_id) as_num,
    count(distinct case when customer_type_id=2 then shop_id end) s_num
from
    (
    select ShowID show_id, TPID customer_id, TicketClassID, TicketPrice, SellPrice from origindb.dp_myshow__s_salesplan where TPTicketStatus in (2,3) and (IsLimited = 1 or (IsLimited=0 and CurrentAmount>0))
    ) ssp
    join 
    (
    select show_id, performance_id, activity_id, category_name, area_1_level_name, area_2_level_name, shop_id from mart_movie.dim_myshow_show
    ) ds
    on ssp.show_id=ds.show_id
    join
    (
    select customer_id, case when customer_type_id=1 then customer_shortname else customer_type_name end customer_type_name, customer_type_id from mart_movie.dim_myshow_customer where customer_id is not null
    ) dc 
    on dc.customer_id=ssp.customer_id
    

select substr(x.pay_time,1,7) mt,
    sum(quantity) sq
from mart_movie.detail_maoyan_order_new_info x
join mart_movie.detail_maoyan_order_sale_cost_new_info y
on x.order_id=y.order_id
join mart_movie.dim_deal_new z
on y.deal_id=z.deal_id
WHERE x.pay_time>='2017-10-01'
and x.pay_time<'2017-12-01'
and z.category=12
group by
    1
    
