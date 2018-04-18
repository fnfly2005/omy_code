#!/bin/bash
path="/Users/fannian/Documents/my_code/"
clock="00"
t1=${1:-`date -v -1d +"%Y-%m-%d ${clock}:00:00"`}
t2=${2:-`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) + 86400) +"%Y-%m-%d ${clock}:00:00"`}
t3=`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) - 86400) +"%Y-%m-%d ${clock}:00:00"`
fut() {
echo `grep -iv "\-time" ${path}sql/${1} | grep -iv "/\*"`
}
it=`fut item_type.sql`
ven=`fut venue.sql`
cit=`fut city.sql`
pro=`fut province.sql`

file="wp_bs02"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    ii.item_id,
    replace(ii.title_cn,',',' ') as item_name,
    ii.city_id,
    ii.type_id,
    it.type_lv1_name,
    it.type_lv2_name,
    ii.venue_id,
    replace(ven.venue_name,',',' ') as venue_name,
    ven.venue_type,
    cit.city_name,
    cit.province_id,
    pro.province_name
from (
    select
        id as item_id,
        title_cn,
        type_id,
        venue_id,
        city_id
    from
        item_info
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
echo "succuess,detail see ${attach}"
