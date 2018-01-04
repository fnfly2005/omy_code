select
    substr(partition_date,1,7) as mt,
    sum(setnumber*salesplan_count) as t_num
from
    (
    select partition_date, order_id, sellchannel, customer_id, performance_id, totalprice, grossprofit, setnumber, salesplan_count from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
    ) as spo
group by
    1
;
select
    count(distinct shop_id) as_num,
    count(distinct case when dc.customer_type_id=2 then shop_id end) s_num
from
    (
    select partition_date, performance_id, customer_id, shop_id, salesplan_sellout_flag from mart_movie.detail_myshow_salesplan where salesplan_id is not null and partition_date>='$time1' and partition_date<'$time2'
    ) as dss
    left join
    (
    select customer_id, case when customer_type_id=1 then customer_shortname else customer_type_name end customer_lvl0_name, customer_type_id, customer_type_name, customer_lvl1_name from mart_movie.dim_myshow_customer where customer_id is not null
    ) as dc 
    on dc.customer_id=dss.customer_id
    

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
    
