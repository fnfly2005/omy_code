select
    dt,
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
    select partition_date as dt, performance_id, customer_id, shop_id, show_id, salesplan_sellout_flag, project_id, salesplan_id from mart_movie.detail_myshow_salesplan where salesplan_id is not null and partition_date>='$$begindate' and partition_date<'$$enddate'
    and salesplan_sellout_flag=0
    ) dms
    left join
    (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
    ) dmp
    using(performance_id)
    left join
    (
    select customer_id, customer_type_id, customer_type_name, customer_lvl1_name, customer_name, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
    and customer_name not in ('广州丁添米贸易有限公司','上海劳益文化传媒有限公司','北京有票科技有限公司','广州颐星文化传播有限公司')
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
