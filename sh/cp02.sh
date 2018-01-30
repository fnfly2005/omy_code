#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql` 
dp=`fun dim_myshow_project.sql`
file="cp02"
lim=";"
attach="${path}doc/${file}.sql"

echo "select
    order_id,
    customer_id,
    bill_id,
    expressfee
from
    (
    $spo
    ) spo
    left join
    (
    $dp
    and insteaddelivery=1
    ) dp
    using(project_id)
$lim">${attach}

echo "succuess,detail see ${attach}"

