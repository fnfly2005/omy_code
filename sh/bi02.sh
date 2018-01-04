#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql`
dp=`fun dim_myshow_performance.sql`
file="bi02"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    performance_id,
    sum(totalprice) as totalprice
from
    (
    $spo
    ) as spo
group by
    1
$lim">${attach}

echo "succuess,detail see ${attach}"

