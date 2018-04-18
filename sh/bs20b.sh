#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql`
file="bs20"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    min(order_id) min_order_id,
    max(order_id) max_order_id
from (
    $spo
    ) spo
$lim">${attach}

echo "succuess,detail see ${attach}"
