#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

so=`fun detail_myshow_saleorder.sql`
dmp=`fun dim_myshow_performance.sql`
dc=`fun dim_myshow_customer.sql`

file="bd10"
lim=";"
attach="${path}doc/${file}.sql"
shop='$shop'
city='$city'

echo "
select
    substr(so.pay_time,1,7) mt,
    dc.customer_type_name,
    customer_lvl1_name,
    dmp.city_name,
    dmp.performance_name,
    dmp.shop_name,
    sum(TotalPrice) TotalPrice
from
    (
    $so
    ) so
    join
    (
    $dmp
    ) dmp
    on so.performance_id=dmp.performance_id
    join 
    (
    $dc
    ) dc
    on so.customer_id=dc.customer_id
where
    dmp.shop_name like '%$shop%'
    and dmp.city_name like '%$city%'
group by
    1,2,3,4,5,6
$lim">${attach}

echo "succuess,detail see ${attach}"
