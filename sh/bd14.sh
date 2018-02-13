#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

so=`fun detail_myshow_saleorder.sql` 
ci=`fun dim_myshow_city.sql`

file="bd14"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    usermobileno,
    city_name,
    province_name
from
    (
    $so
    ) so
    join (
    $ci
    and province_name like '%\$name%'
    ) ci
    on so.city_id=ci.city_id
group by
    1,2,3
$lim">${attach}

echo "succuess,detail see ${attach}"

