
select
    mt,
    case when sor.order_id is null then 0
    else 1 end isrefund,
    sum(so.totalprice) as gmv,
    sum(income) as income,
    sum(expense) as expense
from (
    select substr(pay_time,1,7) as mt, substr(pay_time,1,10) as dt, substr(pay_time,12,2) as ht, order_id, maoyan_order_id, usermobileno as mobile, recipientidno, sellchannel, city_id, totalprice, customer_id, performance_id, meituan_userid, dianping_userid, show_name, show_id, pay_time, consumed_time, show_endtime, show_starttime, order_create_time, order_refund_status, setnumber, salesplan_count, setnumber*salesplan_count as ticket_num, ticket_price, province_name, city_name, ticketclass_description, detailedaddress, salesplan_id, salesplan_name from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
        and sellchannel not in (5,7,8,9,10,11)
        ) so
    left join (
    select orderid order_id from origindb.dp_myshow__s_orderrefund where orderrefundid is not null and finishtime is not null
        ) sor
    on sor.order_id=so.order_id
    left join (
    select OrderID as order_id, tpid as custom_id, paytime, totalprice, grossprofit, income, expense from origindb.dp_myshow__s_settlementpayment where paytime>='$$begindate' and paytime<'$$enddate'
        ) ssp
    on ssp.order_id=so.order_id
group by
    1,2
union all
select
    substr(sc.pay_time,1,7) as mt,
    case when yn=0 then 1
    else 0 end as isrefund,
    sum(purchase_price) as gmv,
    sum(purchase_price) as income,
    sum(purchase_price) as expense
from (
    select 
        pay_time,
        order_id,
        purchase_price
    from 
        mart_movie.detail_maoyan_order_sale_cost_new_info
    where 
        pay_time>='$$begindate'
        and pay_time<'$$enddate'
        and deal_id in (
            select deal_id
            from mart_movie.dim_deal_new
            where category=12
            )
    ) as sc
    left join mart_movie.detail_maoyan_order_new_info mon
    on mon.order_id=sc.order_id
group by
    1,2
;
