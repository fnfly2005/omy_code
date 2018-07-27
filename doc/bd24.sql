
select
    case when 0 in ($dim) then 
        substr(dt,1,7) 
    else 'all' end as mt,
    case when 1 in ($dim) then dt
    else 'all' end as dt,
    case when 2 in ($dim) then md.value2 
    else 'all' end as pt,
    case when 3 in ($dim) then customer_type_name
    else 'all' end as customer_type_name,
    case when 3 in ($dim) then customer_lvl1_name
    else 'all' end as customer_lvl1_name,
    case when 4 in ($dim) then customer_name
    else 'all' end as customer_name,
    area_1_level_name,
    area_2_level_name,
    province_name,
    city_name,
    category_name,
    spo.performance_id,
    performance_name,
    shop_name,
    case when 3 not in ($dim) and 4 not in ($dim) then 'all'
        when dpr.bd_name is null then '无'
    else dpr.bd_name end as bd_name,
    sum(order_num) as order_num,
    sum(ticket_num) as ticket_num,
    sum(TotalPrice) as TotalPrice,
    sum(grossprofit) as grossprofit
from (
    select
        partition_date as dt,
        sellchannel,
        customer_id,
        project_id,
        performance_id,
        count(distinct order_id) as order_num,
        sum(salesplan_count*setnumber) as ticket_num,
        sum(TotalPrice) as TotalPrice,
        sum(grossprofit) as grossprofit
    from 
        mart_movie.detail_myshow_salepayorder
    where 
        partition_date>='$$begindate'
        and partition_date<'$$enddate'
        and category_id in ($category_id)
    group by
        1,2,3,4,5
    ) spo
    left join (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, province_id, city_id, city_name, shop_id, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
    ) dmp
    using(performance_id)
    left join (
    select customer_id, customer_type_id, customer_type_name, customer_lvl1_name, customer_name, customer_shortname, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
    ) dc
    on spo.customer_id=dc.customer_id
    left join (
    select project_id, insteaddelivery, bd_name from mart_movie.dim_myshow_project where project_id is not null
    ) dpr
    on dpr.project_id=spo.project_id
    left join (
    select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where key_name is not null
    and key_name='sellchannel'
    ) md
    on md.key=spo.sellchannel
group by
    1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
;
