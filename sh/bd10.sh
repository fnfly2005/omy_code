#!/bin/bash
path="$private_home/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql`
per=`fun dim_myshow_performance.sql`
cus=`fun dim_myshow_customer.sql`

file="bd10"
lim=";"
attach="${path}doc/${file}.sql"
shop='$shop'

echo "
select
    spo.dt,
    cus.customer_type_name,
    cus.customer_lvl1_name,
    per.city_name,
    per.category_name,
    per.shop_name,
    per.performance_id,
    per.performance_name,
    count(distinct spo.order_id) as order_num,
    sum(spo.salesplan_count*spo.setnumber) as ticket_num,
    sum(spo.TotalPrice) as TotalPrice,
    sum(spo.grossprofit) as grossprofit
from
    (
    $spo
    ) spo
    join
    (
    $per
    and shop_name like '%$shop%'
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
    per.city_name,
    per.category_name,
    per.shop_name,
    per.performance_id,
    per.performance_name
order by
    spo.dt
$lim">${attach}

echo "succuess,detail see ${attach}"
