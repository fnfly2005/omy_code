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
of=`fut order_form_offline.sql`
rsf=`fut report_sales_flow_offline.sql`
item="('1712073160')"

file="wp_bd01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select distinct
    passport_user_mobile
from
    (
    $of
    ) of
    join 
    (
    $rsf
    ) rsf
    on of.order_id=rsf.order_id
    join
    (
    $ii
    and item_no in $item
    ) ii
    on rsf.item_id=ii.id
$lim">${attach}

echo "succuess,detail see ${attach}"
