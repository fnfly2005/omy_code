
select
    substr(partition_date,1,7) as mt,
    sum(setnumber*salesplan_count) as t_num
from
    (
    select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, discountamount, income, expense, totalticketprice, project_id, bill_id, salesplan_id, pay_time from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
    ) as spo
group by
    1
;

select
    count(distinct shop_id) as_num,
    count(distinct case when cus.customer_type_id=2 then shop_id end) s_num
from
    (
    select partition_date as dt, performance_id, customer_id, shop_id, show_id, salesplan_sellout_flag, project_id, salesplan_id from mart_movie.detail_myshow_salesplan where salesplan_id is not null and partition_date>='$$begindate' and partition_date<'$$enddate'
    ) as ss
    left join
    (
    select customer_id, customer_type_id, customer_type_name, customer_lvl1_name, customer_name, customer_shortname, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
    ) as cus 
    on cus.customer_id=ss.customer_id
    

select 
    substr(x.pay_time,1,7) mt,
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
    
