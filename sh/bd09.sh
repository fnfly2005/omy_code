#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql`
per=`fun dim_myshow_performance.sql`
cus=`fun dim_myshow_customer.sql`

file="bd09"
lim=";"
attach="${path}doc/${file}.sql"
name='$name'

echo "
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
    per.performance_name,
    count(distinct spo.order_id) as order_num,
    sum(spo.salesplan_count*spo.setnumber) as ticket_num,
    sum(spo.TotalPrice) as TotalPrice,
    sum(spo.grossprofit) as grossprofit
from
    (
    $spo
    ) as spo
    join
    (
    $per
    and performance_name like '%$name%'
    ) per
    on spo.performance_id=per.performance_id
    left join 
    (
    $cus
    ) cus
    on spo.customer_id=cus.customer_id
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
    per.performance_name
order by
    spo.dt
$lim">${attach}

echo "succuess,detail see ${attach}"
