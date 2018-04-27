#!/bin/bash
path="/Users/fannian/Documents/my_code/"
clock="00"
t1=${1:-`date -v -1d +"%Y-%m-%d ${clock}:00:00"`}
t2=${2:-`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) + 86400) +"%Y-%m-%d ${clock}:00:00"`}
t3=`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) - 86400) +"%Y-%m-%d ${clock}:00:00"`
fut() {
echo `grep -iv "\-time" ${path}sql/${1} | grep -iv "/\*"`
}
ii=`fut item_info.sql`
it=`fut item_type.sql`
ven=`fut venue.sql`
cit=`fut city.sql`
pro=`fut province.sql`

file="wp_bs01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    ii.item_id,
    ii.item_no,
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
