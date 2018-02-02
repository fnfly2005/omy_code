
select
    substr(dt,1,7) mt,
    count(1) pv
from (
select
    spo.dt,
    spo.sellchannel,
    cus.customer_type_id,
    spo.performance_id,
    count(1) num
from
    (
    select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, project_id, bill_id, substr(pay_time,12,2) as ht from mart_movie.detail_myshow_salepayorder where partition_date>='$time1' and partition_date<'$time2'
    ) spo
    left join
    (
    select customer_id, case when customer_type_id=1 then customer_shortname else customer_type_name end customer_lvl0_name, customer_type_id, customer_type_name, customer_lvl1_name, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
    ) cus
    on cus.customer_id=spo.customer_id
group by
    spo.dt,
    spo.sellchannel,
    cus.customer_type_id,
    spo.performance_id
grouping sets(
(spo.dt,spo.performance_id),
(spo.dt,spo.sellchannel,spo.performance_id),
(spo.dt,cus.customer_type_id,spo.performance_id),
(spo.dt,spo.sellchannel,cus.customer_type_id,spo.performance_id)
)) s
group by
    1
order by
    1
;
