#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

so=`fun detail_myshow_saleorder.sql` 
ci=`fun dim_myshow_city.sql`

file="yysc11"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    area_2_level_name,
    province_name,
    '全部' city_name,
    approx_distinct(usermobileno) user_num
from (
    $ci
    ) ci
    join (
        select 
            usermobileno,
            city_id
        from 
            mart_movie.detail_myshow_saleorder
        where 
            order_create_time>='\$\$begindate'
            and order_create_time<'\$\$enddate'
    ) so
    on so.city_id=ci.city_id
group by
    1,2,3
union all
select
    area_2_level_name,
    province_name,
    city_name,
    approx_distinct(usermobileno) user_num
from (
    $ci
    ) ci
    join (
        select 
            usermobileno,
            city_id
        from 
            mart_movie.detail_myshow_saleorder
        where 
            order_create_time>='\$\$begindate'
            and order_create_time<'\$\$enddate'
    ) so
    on so.city_id=ci.city_id
group by
    1,2,3
$lim">${attach}

echo "succuess,detail see ${attach}"
