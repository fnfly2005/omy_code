
select
    substr(partition_date,1,7) as mt,
    customer_type_name,
    count(distinct performance_id) as sp_num,
    count(distinct order_id) as order_num,
    sum(totalprice) as totalprice,
    sum(grossprofit) as grossprofit
from
    (
    select partition_date, order_id, sellchannel, customer_id, performance_id, totalprice, grossprofit from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
    ) as so
    left join 
    (
    select customer_id, case when customer_type_id=1 then customer_shortname else customer_type_name end customer_lvl0_name, customer_type_id, customer_type_name, customer_lvl1_name from mart_movie.dim_myshow_customer where customer_id is not null
    ) as dc
    using(customer_id)
group by
    1,2
;
