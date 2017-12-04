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
sos=`fun dp_myshow__s_ordersalesplansnapshot`
scu=`fun dp_myshow__s_customer`

file="bs04"
lim=";"
attach="${path}doc/${file}.sql"

echo "select
    substr(so.PaidTime,1,7) mt,
    case when so.tp_type='渠道' then scu.ShortName
    else so.tp_type end tp_type,
    count(distinct sos.PerformanceID) p_num,
    count(distinct so.OrderID) so_num,
    sum(so.TotalPrice) TotalPrice,
from
    (
    $so
    ) so
    join 
    (
    $sos
    ) sos on so.OrderID=sos.OrderID
    left join (
    $scu
    ) scu on scu.TPID=so.TPID
group by
    1,2
$lim">${attach}

echo "succuess,detail see ${attach}"