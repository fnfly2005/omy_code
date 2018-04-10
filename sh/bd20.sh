#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

sho=`fun dim_dp_shop.sql` 
sal=`fun dim_myshow_salesplan.sql`
per=`fun dim_myshow_performance.sql`
spo=`fun detail_myshow_salepayorder.sql`

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
    ss.performance_id,
    performance_name,
    show_no,
    ticket_price,
    order_num,
    totalprice,
    sku_num
from (
    select
        dp_shop_id,
        dp_shop_name,
        dp_province_name,
        dp_city_name,
        dp_district_name,
        category_name,
        performance_id,
        performance_name,
        count(distinct show_id) show_no,
        avg(ticket_price) as ticket_price
    from (
        select
            shop_id,
            category_name,
            performance_id,
            performance_name,
            show_id,
            avg(ticket_price) as ticket_price
        from
            mart_movie.dim_myshow_salesplan
        where show_starttime>='\$\$begindate'
            and show_starttime<'\$\$enddate'
        group by
            1,2,3,4,5
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
    left join (
        select
            performance_id,
            count(distinct order_id) as order_num,
            sum(totalprice) totalprice,
            sum(setnumber*salesplan_count) sku_num
        from
            mart_movie.detail_myshow_salepayorder
        group by
            1
        ) spo
        on spo.performance_id=ss.performance_id
$lim">${attach}

echo "succuess,detail see ${attach}"

