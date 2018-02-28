#!/bin/bash
path="/Users/fannian/Documents/my_code/"
clock="00"
t1=${1:-`date -v -1d +"%Y-%m-%d ${clock}:00:00"`}
t2=${2:-`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) + 86400) +"%Y-%m-%d ${clock}:00:00"`}
t3=`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) - 86400) +"%Y-%m-%d ${clock}:00:00"`
fun() {
echo `cat ${path}sql/${1} | sed "s/-time1/${2:-${t1% *}}/g;
s/-time2/${3:-${t2% *}}/g;s/-time3/${4:-${t3% *}}/g"`
}


ii=`fun item_info.sql` 
it=`fun item_type.sql`
rsf=`fun report_sales_flow.sql`
of=`fun order_form.sql`

file="bs17"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(of.dt,1,7) as mt,
    it.name,
    sum(of.total_money) as total_money
from (
    $of 
    ) of
    join (
    $rsf
    ) rsf
    on of.order_id=rsf.order_id
    and of.ismaoyan=0
    and rsf.ismaoyan=0
    join (
        $ii
        ) ii
    on rsf.item_id=ii.id
    join (
        $it
        ) it
    on ii.type_id=it.id
group by
    1,2
$lim">${attach}

echo "succuess,detail see ${attach}"

