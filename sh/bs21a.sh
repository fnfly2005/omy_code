#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

oni=`fun detail_maoyan_order_new_info.sql` 
cni=`fun detail_maoyan_order_sale_cost_new_info.sql`

file="bs21"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    dt,
    count(distinct order_id) order_num,
    sum(quantity) quantity,
    sum(total_money) total_money
from (
    $oni
    ) oni
group by
    1
$lim">${attach}

echo "succuess,detail see ${attach}"

