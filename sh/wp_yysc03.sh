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
of=`fut order_form.sql`
rsf=`fut report_sales_flow.sql`
cit=`fut city.sql`
pro=`fut province.sql`
del=`fut order_delivery.sql`

item="('351556626')"

file="wp_yysc03"
lim=";"
attach="${path}doc/${file}.sql"
echo "
select
    dt,
    count(distinct of.order_id) so_num,
    sum(of.total_money) so_gmv
from (
        $ii
        and item_no in $item
        ) ii
    join (
        $rsf
        ) rsf
    on rsf.item_id=ii.id
    join (
        $of
        ) of
    on of.order_id=rsf.order_id
group by
    1
$lim">${attach}

echo "succuess,detail see ${attach}"
