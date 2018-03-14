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
    so.usermobileno,
    ci.city_name
from (
    select
        city_id,
        city_name
    from (
        $ci
        and province_name in ('\$name')
        union all
        $ci
        and city_name in ('\$name')
        ) c1
    group by
        1,2
    ) ci
    join (
    select
        usermobileno,
        city_id
    from
        mart_movie.detail_myshow_saleorder
    where order_create_time>='\$\$begindate'
        and order_create_time<'\$\$enddate'
    group by
        1,2
    ) so
    on so.city_id=ci.city_id
$lim">${attach}

echo "succuess,detail see ${attach}"

