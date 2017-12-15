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
ssp=`fun dp_myshow__s_settlementpayment` 
so=`fun dp_myshow__s_order`

file="bs05"
lim=";"
attach="${path}doc/${file}.sql"

echo "select
    substr(so.PaidTime,1,7) mt,
    count(distinct so.MTUserID) s_uv,
    count(distinct so.orderid) s_o,
    sum(so.TotalPrice) gmv,
    sum(ssp.GrossProfit) gp
from
    (
    $ssp
    ) ssp
    join 
    (
    $so
    ) so
    on ssp.orderid=so.orderid
group by
    1
">${attach}
echo "succuess,detail see ${attach}"
