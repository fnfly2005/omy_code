#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql` 
cus=`fun dim_myshow_customer.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(dt,1,7) as mt,
    coalesce(cus.customer_type_name,'全部') as customer_type_name,
    coalesce(cus.customer_lvl1_name,'全部') as customer_lvl1_name,
    count(distinct spo.order_id) as order_num,
    sum(spo.salesplan_count*spo.setnumber) as ticket_num,
    sum(spo.totalprice) as totalprice,
    sum(spo.grossprofit) as grossprofit
from
    (
    $spo
    ) spo
    left join (
    $cus
    ) cus
    on spo.customer_id=cus.customer_id
group by
    substr(dt,1,7),
    cus.customer_type_name,
    cus.customer_lvl1_name
grouping sets(
(substr(dt,1,7),cus.customer_type_name),
(substr(dt,1,7),cus.customer_type_name,cus.customer_lvl1_name)
)
$lim">${attach}

echo "succuess,detail see ${attach}"
