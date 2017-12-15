#!/bin/bash
clock="00"
t1=${1:-`date -v -1d +"%Y-%m-%d ${clock}:00:00"`}
t2=${2:-`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) + 86400) +"%Y-%m-%d ${clock}:00:00"`}
t3=`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) - 86400) +"%Y-%m-%d ${clock}:00:00"`
path="/Users/fannian/Documents/my_code/"
fun() {
echo `cat ${path}sql/${1}.sql | sed "s/-time1/${2:-${t1% *}}/g;
s/-time2/${3:-${t2% *}}/g;s/-time3/${4:-${t3% *}}/g" | grep -iv "/\*"`
}
ssp=`fun dp_myshow__s_salesplan`
ds=`fun dim_myshow_show`
dc=`fun dim_myshow_customer`
file="bd05"
lim=";"
attach="${path}doc/${file}.sql"

echo "select
    customer_type_name,
    area_1_level_name,
    area_2_level_name,
    category_name,
    count(distinct performance_id) ap_num
from
    (
    $ssp
    ) ssp
    join 
    (
    $ds
    ) ds
    on ssp.show_id=ds.show_id
    left join
    (
    $dc
    ) dc 
    on dc.customer_id=ssp.customer_id
group by
    1,2,3,4
    ">${attach}
echo "succuess,detail see ${attach}"
