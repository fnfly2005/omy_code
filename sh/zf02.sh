#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql` 
cus=`fun dim_myshow_customer.sql`
file="zf02"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(dt,1,7) mt,
    count(1) pv
from (
select
    spo.dt,
    spo.sellchannel,
    cus.customer_type_id,
    spo.performance_id,
    count(1) num
from
    (
    $spo
    ) spo
    left join
    (
    $cus
    ) cus
    on cus.customer_id=spo.customer_id
group by
    spo.dt,
    spo.sellchannel,
    cus.customer_type_id,
    spo.performance_id
grouping sets(
(spo.dt,spo.performance_id),
(spo.dt,spo.sellchannel,spo.performance_id),
(spo.dt,cus.customer_type_id,spo.performance_id),
(spo.dt,spo.sellchannel,cus.customer_type_id,spo.performance_id)
)) s
group by
    1
order by
    1
$lim">${attach}

echo "succuess,detail see ${attach}"

