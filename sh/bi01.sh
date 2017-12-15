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
dp=`fun dim_myshow_performance`
ssp=`fun dp_myshow__s_settlementpayment`
sos=`fun dp_myshow__s_ordersalesplansnapshot`
dc=`fun dim_myshow_customer`

file="bi01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    -99 as customer_type_id,
    -99 as area_1_level_name,
    sum(TotalPrice) TotalPrice,
    sum(GrossProfit) GrossProfit,
    count(distinct case when activity_id is not null then activity_id 
    else dp.performance_id end) performance_num
from
    (
    $ssp
    ) ssp
    join 
    (
    $sos
    ) sos
    on ssp.OrderID=sos.OrderID
    left join 
    (
    $dp
    ) dp
    on dp.performance_id=sos.performance_id
    left join 
    (
    $dc
    ) dc
    on dc.customer_id=ssp.TPID
group by
    1,2
    ">${attach}
echo "succuess,detail see ${attach}"
