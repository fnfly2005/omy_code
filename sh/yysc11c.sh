#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

so=`fun detail_myshow_saleorder.sql` 
per=`fun dim_myshow_performance.sql`

file="yysc11"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    province_name,
    coalesce(city_name,'全部') as city_name,
    coalesce(category_name,'全部') as category_name,
    count(distinct usermobileno) as user_num
from (
    $per
    ) per
    join (
        select 
            usermobileno,
            performance_id
        from 
            mart_movie.detail_myshow_saleorder
        where 
            order_create_time>='\$\$begindate'
            and order_create_time<'\$\$enddate'
        ) so
    on so.performance_id=per.performance_id
group by
    category_name,
    province_name,
    city_name
grouping sets(
    (province_name),
    (province_name,city_name),
    (category_name,province_name),
    (category_name,province_name,city_name)
    ) 
$lim">${attach}

echo "succuess,detail see ${attach}"
