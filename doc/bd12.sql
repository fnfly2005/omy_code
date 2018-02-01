
select
    spo.dt,
    cus.customer_type_name,
    cus.customer_lvl1_name,
    per.area_1_level_name,
    per.area_2_level_name,
    per.province_name,
    per.city_name,
    per.category_name,
    per.shop_name,
    per.performance_id,
    per.performance_name,
    pro.bd_name,
    count(distinct spo.order_id) as order_num,
    sum(spo.salesplan_count*spo.setnumber) as ticket_num,
    sum(spo.TotalPrice) as TotalPrice,
    sum(spo.grossprofit) as grossprofit
from
    (
    select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, project_id, bill_id, substr(pay_time,12,2) as ht from mart_movie.detail_myshow_salepayorder where partition_date>='$time1' and partition_date<'$time2'
    ) spo
    left join
    (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
    ) per
    on spo.performance_id=per.performance_id
    left join
    (
    select project_id, insteaddelivery, bd_name from mart_movie.dim_myshow_project where project_id is not null
    ) pro
    on spo.project_id=pro.project_id
    left join
    (
    select customer_id, case when customer_type_id=1 then customer_shortname else customer_type_name end customer_lvl0_name, customer_type_id, customer_type_name, customer_lvl1_name, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
    ) cus
    on cus.customer_id=spo.customer_id
group by
    spo.dt,
    cus.customer_type_name,
    cus.customer_lvl1_name,
    per.area_1_level_name,
    per.area_2_level_name,
    per.province_name,
    per.city_name,
    per.category_name,
    per.shop_name,
    per.performance_id,
    per.performance_name,
    pro.bd_name
order by
    spo.dt
;
