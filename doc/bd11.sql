select
    partition_date,
    customer_type_name,
    customer_lvl1_name,
    area_1_level_name,
    area_2_level_name,
    province_name,
    city_name,
    category_name,
    dms.performance_id,
    performance_name,
    shop_name,
    case when dpr.bd_name is null then '无'
    else dpr.bd_name end as bd_name
from
    (
    select partition_date, performance_id, customer_id, shop_id, show_id, salesplan_sellout_flag, project_id from mart_movie.detail_myshow_salesplan where salesplan_id is not null and partition_date>='$time1' and partition_date<'$time2'
    and salesplan_sellout_flag=0
    ) dms
    left join
    (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
    ) dmp
    using(performance_id)
    left join
    (
    select customer_id, case when customer_type_id=1 then customer_shortname else customer_type_name end customer_lvl0_name, customer_type_id, customer_type_name, customer_lvl1_name, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
    ) dc
    on dms.customer_id=dc.customer_id
    left join 
    (
    select project_id, insteaddelivery, bd_name from mart_movie.dim_myshow_project where project_id is not null
    ) dpr
    on dpr.project_id=dms.project_id
group by
    1,2,3,4,5,6,7,8,9,10,11,12
;
