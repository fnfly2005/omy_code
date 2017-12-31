#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

so=`fun detail_myshow_saleorder.sql`
dp=`fun dim_myshow_performance.sql`
file="yysc05"
lim=";"
attach="${path}doc/${file}.sql"

echo "select
    substr(so.pay_time,1,7) as mt,
    sellchannel,
    category_name,
    count(distinct so.order_id) as order_num,
    sum(so.totalprice) as totalprice
from
    (
    $so
    ) as so
    join 
    (
    $dp
    ) as dp
    using(performance_id)
group by
    1,2,3
$lim">${attach}

echo "succuess,detail see ${attach}"

