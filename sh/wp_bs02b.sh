#!/bin/bash
path="/Users/fannian/Documents/my_code/"
fut() {
echo `grep -iv "\-time" ${path}sql/${1} | grep -iv "/\*"`
}
it=`fut item_type.sql`
ven=`fut venue.sql`
cit=`fut city.sql`
pro=`fut province.sql`
ii=`fut item_info.sql`

file="wp_bs02"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    ii.item_id,
    ii.item_name,
    ii.city_id,
    ii.type_id,
    it.type_lv1_name,
    it.type_lv2_name,
    ii.venue_id,
    ven.venue_name,
    ven.venue_type,
    cit.city_name,
    cit.province_id,
    pro.province_name
from (
    $ii
    ) ii
    left join (
    $it
    and it1.is_visible is not null
    and it1.name<>'子分类'
    ) it
    on ii.type_id=it.type_id
    left join (
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
