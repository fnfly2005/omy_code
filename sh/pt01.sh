#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

so=`fun detail_myshow_saleorder.sql` 
file="pt01"
lim=";"
attach="${path}doc/${file}.sql"

echo "select
    substr(pay_time,1,10) as dt,
    count(distinct order_id) as order_num,
    count(distinct case when customer_id>=6 then order_id end) as z_order_num,
    sum(totalprice) as totalprice,
    count(distinct performance_id) as sp_num
from
    (
    $so
    ) so
group by
    1
$lim">${attach}

echo "succuess,detail see ${attach}"

