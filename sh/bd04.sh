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
so=`fun dp_myshow__s_order` 
dc=`fun dim_myshow_customer`
file="bd04"
lim=";"
attach="${path}doc/${file}.sql"

echo "select
    customer_type_name,
    count(distinct OrderID) Order_num,
    sum(TotalPrice) TotalPrice,
    count(distinct MTUserID) MTUser
from
    (
    $so
    ) so
    join 
    (
    $dc
    and customer_type_id=1
    ) dc
    on so.TPID=dc.customer_id
group by
    1
    ">${attach}
echo "succuess,detail see ${attach}"
