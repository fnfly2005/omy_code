#!/bin/bash
path="/Users/fannian/Documents/my_code/"
d1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$d1'),1,10)/g" | grep -iv "/\*"`
}

per=`fun dim_myshow_performance.sql` 
spo=`fun detail_myshow_salepayorder.sql`
so=`fun detail_wg_saleorder.sql`
dit=`fun dim_wg_item.sql`

file="bd21"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    '范特西' as ds,
    per.province_name,
    per.city_name,
    per.category_name,
    per.shop_name,
    per.performance_id,
    per.performance_name,
    sp1.order_num,
    sp1.totalprice
from (
    $per
    and (
        regexp_like(performance_name,'\$name')=true
        or performance_id in (\$id)
        )
    ) as per
    join (
    select
        performance_id,
        count(distinct order_id) as order_num,
        sum(totalprice) as totalprice
    from mart_movie.detail_myshow_salepayorder
    where
        partition_date<'\$\$today'
    group by
        1
    ) as sp1
    on per.performance_id=sp1.performance_id
union all
select
    '微格' as ds,
    province_name,
    city_name,
    type_lv1_name as category_name,
    venue_name as shop_name,
    item_no as performance_id,
    title_cn as performance_name,
    order_num,
    totalprice
from (
    $dit
    where regexp_like(title_cn,'\$name')=true
        or item_no in (\$id)
    ) dit
    join (
    select
        item_id,
        count(distinct order_id) as order_num,
        sum(total_money) as totalprice
    from upload_table.detail_wg_saleorder
    where pay_no is not null
    group by
        1
    ) so
    on so.item_id=dit.item_id
$lim">${attach}

echo "succuess,detail see ${attach}"
