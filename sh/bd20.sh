#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

sho=`fun dim_dp_shop.sql` 
sal=`fun dim_myshow_salesplan.sql`
per=`fun dim_myshow_performance.sql`
file="bd20"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select 
    dp_shop_id,
    dp_shop_name,
    dp_province_name,
    dp_city_name,
    dp_district_name,
    category_name,
    count(distinct performance_id) performance_no,
    count(distinct show_id) show_no,
    avg(ticket_price) as ticket_price
from (
    select
        dp_shop_id,
        dp_shop_name,
        dp_province_name,
        dp_city_name,
        dp_district_name,
        category_name,
        performance_id,
        show_id,
        avg(ticket_price) as ticket_price
    from (
        $sal
        where show_starttime>='\$\$begindate'
            and show_starttime<'\$\$enddate'
        ) sal 
        join (
        $sho
        where dp_city_name like '上海%'
        and dp_district_name like '徐汇%'
        ) sho
        on sho.dp_shop_id=sal.shop_id
    group by
        1,2,3,4,5,6,7,8
    ) ss
group by
    1,2,3,4,5,6
union all
select 
    dp_shop_id,
    dp_shop_name,
    dp_province_name,
    dp_city_name,
    dp_district_name,
    '全部' as category_name,
    count(distinct performance_id) performance_no,
    count(distinct show_id) show_no,
    avg(ticket_price) as ticket_price
from (
    select
        dp_shop_id,
        dp_shop_name,
        dp_province_name,
        dp_city_name,
        dp_district_name,
        performance_id,
        show_id,
        avg(ticket_price) as ticket_price
    from (
        $sal
        where show_starttime>='\$\$begindate'
            and show_starttime<'\$\$enddate'
        ) sal 
        join (
        $sho
        where dp_city_name like '上海%'
        and dp_district_name like '徐汇%'
        ) sho
        on sho.dp_shop_id=sal.shop_id
    group by
        1,2,3,4,5,6,7
    ) ss
group by
    1,2,3,4,5
$lim">${attach}

echo "succuess,detail see ${attach}"

