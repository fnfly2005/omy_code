#!/bin/bash
source ./fuc.sh

per=`fun dim_wg_performance.sql`
pea=`fun dim_wg_performance.sql u`
typ=`fun dim_wg_type.sql`
cim=`fun dim_wg_citymap.sql`
cit=`fun dim_myshow_city.sql`
cat=`fun dim_myshow_category.sql`

file="dim_wg_performance_s"
lim=";"
attach="${path}etl/${file}.sql"

echo "
select
    item_no as performance_id,
    item_id,
    performance_name,
    case when cat.category_id is null then 8
    else cat.category_id end as category_id,
    case when cat.category_name is null then '其他'
    else cat.category_name end as category_name,
    cim.city_id,
    case when cit.city_name is null then '其他'
    else cit.city_name end as city_name,
    cit.province_id,
    cit.province_name,
    area_1_level_id,
    area_1_level_name,
    area_2_level_id,
    area_2_level_name,
    venue_id,
    shop_name,
    type_id,
    type_lv2_name,
    venue_type
from (
    $per
        and item_no is not null
    union all
    select
        item_id,
        performance_name,
        row_number() over (order by item_id)+1804043364 as item_no,
        city_id,
        type_id,
        category_name,
        type_lv2_name,
        venue_id,
        shop_name,
        city_name,
        venue_type,
        province_id,
        province_name
    $pea
        and item_no is null
    ) per
    left join (
        $typ
        ) typ
    on typ.type_lv1_name=per.category_name
    left join (
        $cim
        ) cim
    on cim.city_name=per.city_name
    left join (
        $cit
        ) as cit
        on cit.city_id=cim.city_id
    left join (
        $cat
        ) as cat
        on cat.category_id=typ.category_id
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
