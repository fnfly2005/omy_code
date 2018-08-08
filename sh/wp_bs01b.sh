#!/bin/bash
source ./fuc.sh

ii=`fun item_info.sql`
it=`fun item_type.sql`
ven=`fun venue.sql`
cit=`fun city.sql`
pro=`fun province.sql`

file="wp_bs01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    ii.item_id,
    ii.performance_name,
    ii.performance_id,
    ii.city_id,
    ii.type_id,
    it.type_lv1_name,
    it.type_lv2_name,
    ii.venue_id,
    ven.shop_name,
    ven.venue_type,
    cit.city_name,
    cit.province_id,
    pro.province_name
from (
    $ii
    ) ii
    join (
    $it
    ) it
    on ii.type_id=it.type_id
    join (
    $ven
    ) ven
    on ven.venue_id=ii.venue_id
    left join (
    $cit
    ) cit
    on cit.city_id=ii.city_id
    left join (
    $pro
    ) pro
    on pro.province_id=cit.province_id
$lim">${attach}
echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
