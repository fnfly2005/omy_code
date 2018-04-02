#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

so=`fun detail_wg_saleorder.sql` 
per=`fun dim_wg_item.sql`

file="bd19"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    province_name,
    coalesce(city_name,'全部') as city_name,
    coalesce(type_lv1_name,'全部') as type_lv1_name,
    count(distinct order_mobile) as user_num
from (
    $per
    ) per
    join (
        select 
            order_mobile,
            item_id
        from 
            upload_table.detail_wg_saleorder
        ) so
    on so.item_id=per.item_id
group by
    type_lv1_name,
    province_name,
    city_name
grouping sets(
    (province_name),
    (province_name,city_name),
    (type_lv1_name,province_name),
    (type_lv1_name,province_name,city_name)
    ) 
$lim">${attach}

echo "succuess,detail see ${attach}"
