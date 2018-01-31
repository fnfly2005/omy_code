#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql`
dmp=`fun dim_myshow_performance.sql`
dc=`fun dim_myshow_customer.sql`

file="bd09"
lim=";"
attach="${path}doc/${file}.sql"
name='$name'

echo "
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
    $spo
    ) as spo
    join
    (
    $dmp
    and performance_name like '%$name%'
    ) dmp
    on spo.performance_id=dmp.performance_id
    left join 
    (
    $dc
    ) dc
    on spo.customer_id=dc.customer_id
group by
    1,2,3,4,5
$lim">${attach}

echo "succuess,detail see ${attach}"
