#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

oni=`fun detail_maoyan_order_new_info.sql`
cni=`fun detail_maoyan_order_sale_cost_new_info.sql`

file="bs07"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select 
    substr(dt,1,7) as mt,
    sum(total_money) as total_money,
    count(distinct oni.order_id) as order_num,
    sum(quantity) sku_num,
    count(distinct deal_id) dea_num
from (
    $oni
    ) oni
    join (
    $cni
    ) cni
    on oni.order_id=cni.order_id
group by 
    1
$lim">${attach}
echo "succuess,detail see ${attach}"
