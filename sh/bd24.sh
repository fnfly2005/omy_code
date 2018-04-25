#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql`
dmp=`fun dim_myshow_performance.sql`
dc=`fun dim_myshow_customer.sql`
dpr=`fun dim_myshow_project.sql`
md=`fun myshow_dictionary.sql`

file="bd24"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    case when 0 in (\$dim) then 
        substr(dt,1,7) 
    else 'all' end as mt,
    case when 1 in (\$dim) then dt
    else 'all' end as dt,
    case when 2 in (\$dim) then md.value2 
    else 'all' end as pt,
    case when 3 in (\$dim) then customer_type_name
    else 'all' end as customer_type_name,
    case when 3 in (\$dim) then customer_lvl1_name
    else 'all' end as customer_lvl1_name,
    area_1_level_name,
    area_2_level_name,
    province_name,
    city_name,
    category_name,
    spo.performance_id,
    performance_name,
    shop_name,
    case when 3 not in (\$dim) then 'all'
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
        partition_date>='\$\$begindate'
        and partition_date<'\$\$enddate'
    group by
        1,2,3,4,5
    ) spo
    left join (
    $dmp
    ) dmp
    using(performance_id)
    left join (
    $dc
    ) dc
    on spo.customer_id=dc.customer_id
    left join (
    $dpr
    ) dpr
    on dpr.project_id=spo.project_id
    left join (
    $md
    and key_name='sellchannel'
    ) md
    on md.key=spo.sellchannel
group by
    1,2,3,4,5,6,7,8,9,10,11,12,13,14
$lim">${attach}

echo "succuess,detail see ${attach}"
