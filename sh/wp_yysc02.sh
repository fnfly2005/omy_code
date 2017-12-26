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
dic=`fut dictionary.sql`

file="wp_yysc02"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(dt,1,7) mt,
    dict_value,
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
    left join 
    (
    $it
    ) it
    on ii.type_id=it.id
    left join
    (
    $dic
    and group_name='ticket_source'
    ) dic 
    on dic.dict_key=ii.source
group by
    1,2,3
$lim">${attach}
echo "succuess,detail see ${attach}"
