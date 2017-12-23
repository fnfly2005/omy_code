select
    partition_date,
    customer_type_name,
    customer_lvl0_name,
    area_1_level_name,
    area_2_level_name,
    category_name,
    count(distinct dms.performance_id) ap_num
from
    (
    select partition_date, performance_id, customer_id, salesplan_sellout_flag from mart_movie.detail_myshow_salesplan where salesplan_id is not null and partition_date>='$time1' and partition_date<'$time2'
    and salesplan_sellout_flag=0
    ) dms
    left join
    (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name from mart_movie.dim_myshow_performance
    ) dmp
    using(performance_id)
    left join
    (
    select customer_id, case when customer_type_id=1 then customer_shortname else customer_type_name end customer_lvl0_name, customer_type_id, customer_type_name from mart_movie.dim_myshow_customer where customer_id is not null
    ) dc
    on dms.customer_id=dc.customer_id
group by
    1,2,3,4,5,6
;
