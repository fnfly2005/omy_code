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
of=`fut order_form.sql`
rsf=`fut report_sales_flow.sql`
item="('1706302530')"
type="('流行')"

file="wp_yysc01"
lim=";"
attach="${path}doc/${file}.sql"
echo "
select
    dt,
    name,
    title_cn,
    count(distinct of.order_id) so_num,
    sum(of.total_money) so_gmv
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
    join 
    (
    $it
    ) it
    on ii.type_id=it.id
group by
    1,2,3
$lim">${attach}

echo "
select
    substr(dt,1,7) mt,
    name,
    count(distinct of.order_id) so_num,
    sum(of.total_money) so_gmv
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
    ) ii
    on rsf.item_id=ii.id
    join 
    (
    $it
    and name in $type
    ) it
    on ii.type_id=it.id
group by
    1,2
$lim">>${attach}
echo "succuess,detail see ${attach}"
