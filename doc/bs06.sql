分业务单元销售及动销项目
select
    substr(PaidTime,1,7) mt,
    tp_type,
    sum(TotalPrice) GMV,
    count(distinct PerformanceID) cp,
    count(distinct OrderID) SO
from
    (
    select case when TPID<6 then '渠道' else '自营' end tp_type, case SellChannel when 1 then '点评' when 2 then '美团' when 3 then '微信吃喝玩乐' when 4 then '微信搜索小程序' when 5 then '猫眼' else case when SellChannel in (6,7) then '微信演出赛事' else '未知' end end SellChannel, case ReserveStatus when 8 then '出票失败' when 9 then '出票成功' when 7 then '出票中' when 6 then '支付成功' else '未知' end ReserveStatus, case RefundStatus when 0 then '未发起' when 1 then '发起失败' when 2 then '发起成功' when 3 then '退款中' when 4 then '退款失败' when 5 then '已退款' else '未知' end RefundStatus, OrderID, MYOrderID, TPID, MTUserID, PaidTime, SalesPlanCount, SalesPlanSellPrice, SalesPlanSupplyPrice, TotalPrice from origindb.dp_myshow__s_order where ReserveStatus>=6 and PaidTime is not null and PaidTime>='2017-10-01' and PaidTime<'2017-12-01'
    ) so
    join 
    (
    select OrderID, PerformanceName, PerformanceID, ShowName, TicketID TicketClassID, SalesPlanTicketPrice, SetNum from origindb.dp_myshow__s_ordersalesplansnapshot where OrderID is not null and CreateTime>='2017-09-30' and CreateTime<'2017-12-01'
    ) sos
    on so.OrderID=sos.OrderID
group by
    1,2
    ;
分入口UV
select
substr(partition_date,1,7) mt,
new_app_name,
sum(uv) uv
from mart_movie.aggr_myshow_pv_platform
where
partition_date>='2017-10-01'
and partition_date<'2017-12-01'
group by
1,2
;
团购动销项目
select substr(x.pay_time,1,7) mt,
       count(distinct z.deal_id) cp
  from mart_movie.detail_maoyan_order_new_info x
  join mart_movie.detail_maoyan_order_sale_cost_new_info y
    on x.order_id=y.order_id
  join mart_movie.dim_deal_new z
    on y.deal_id=z.deal_id
 WHERE x.pay_time>='2017-10-01'
   and x.pay_time<'2017-12-01'
   and z.category=12
 group by 1;
微票非渠道分销
select 
from_unixtime(of.payment_time/1000, '%Y-%m') months,
case when of.order_src=2 then '微信' 
when of.order_src=12 then '手Q'
when of.order_src in (15,16) then '格瓦拉'
when of.order_src in (8,9) then '娱票儿'
when of.order_src =14 then '小程序'
when of.order_src =7 then 'M站'
end order_src,
truncate(sum(of.total_money)/100, 2) as gmv,
count(distinct order_id) as so
from order_form of
where
of.payment_time>=1000*unix_timestamp('2017-10-01 00:00:00')
and of.payment_time<1000*unix_timestamp('2017-12-01 00:00:00')
and of.payment_time is not null
and of.order_src in (2,12,15,16,8,9,14,7)
group by 1,2；
微票动销
SELECT 
substr(date,1,7) mt,
count(distinct item_id) cp
from report_sales_flow
where
pay_no is not null
and date>='2017-10-01'
and date<'2017-12-01'
and order_src in (2,12,15,16,8,9,14,7)
group by
1;
微票渠道分销
select 
from_unixtime(of.create_time/1000, '%Y-%m') months,
truncate(sum(of.total_money)/100, 2) as gmv,
count(distinct order_id) as so

from order_form of
where 
of.create_time >= 1000*unix_timestamp('2017-10-01 00:00:00')
and of.create_time < 1000*unix_timestamp('2017-12-01 00:00:00')
and of.order_src in (11,21)
group by 1

