
select
    substr(spo.dt,1,7) as mt,
    dc.customer_type_name,
    dc.customer_lvl1_name,
    dmp.city_name,
    dmp.performance_name,
    count(distinct spo.order_id) as order_num,
    sum(spo.salesplan_count*spo.setnumber) as ticket_num,
    sum(spo.TotalPrice) as TotalPrice,
    sum(spo.grossprofit) as grossprofit
from
    (
    select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, project_id, bill_id from mart_movie.detail_myshow_salepayorder where partition_date>='$time1' and partition_date<'$time2'
    ) as spo
    join
    (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
    and performance_name like '%$name%'
    ) dmp
    on spo.performance_id=dmp.performance_id
    left join 
    (
    select customer_id, case when customer_type_id=1 then customer_shortname else customer_type_name end customer_lvl0_name, customer_type_id, customer_type_name, customer_lvl1_name, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
    ) dc
    on spo.customer_id=dc.customer_id
group by
    1,2,3,4,5
;
