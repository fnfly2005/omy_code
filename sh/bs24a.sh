#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql`
cit=`fun dim_myshow_city.sql`
per=`fun dim_myshow_performance.sql`

file="bs24"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    category_name,
    spo.performance_id,
    performance_name,
    ticket_price,
    sell_price,
    count(distinct order_id) as order_num
from (
    $per
    and city_name in ('郑州')
    ) per
    join (
    $spo
    ) spo
    on spo.performance_id=per.performance_id
group by
    1,2,3,4,5
$lim">${attach}

echo "succuess,detail see ${attach}"
