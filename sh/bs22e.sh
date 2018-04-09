#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

ii=`fun detail_wg_iteminterests.sql`

file="bs22"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    count(1) as num,
    count(distinct user_id) as user_num
from (
    $ii
    ) ii
$lim">${attach}

echo "succuess,detail see ${attach}"

