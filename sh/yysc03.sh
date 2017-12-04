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
sc=`fun dp_myshow__s_category`
sp=`fun dp_myshow__s_performance`

file="yysc03"
lim=";"
attach="${path}doc/${file}.sql"

echo "select
    substr(so.PaidTime,1,7) mt,
    case when sc.Name is null then '其他'
    else sc.Name end Name,
    so.sellchannel,
    count(distinct so.MTUserID) so_user,
    count(distinct so.OrderID) so_num,
    sum(so.TotalPrice) TotalPrice
from
    (
    $sos
    ) sos 
    left join
    (
    $sp
    ) sp
    on sos.PerformanceID=sp.PerformanceID
    left join 
    (
    $sc
    ) sc on sp.CategoryID=sc.CategoryID
    join 
    (
    $so
    ) so on so.OrderID=sos.OrderID
group by
    1,2,3
$lim">${attach}

echo "succuess,detail see ${attach}"
