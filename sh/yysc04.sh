#!/bin/bash
clock="00"
t1=${1:-`date -v -1d +"%Y-%m-%d ${clock}:00:00"`}
t2=${2:-`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) + 86400) +"%Y-%m-%d ${clock}:00:00"`}
t3=`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) - 86400) +"%Y-%m-%d ${clock}:00:00"`
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} |  sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}
ssp=`fun dp_myshow__s_settlementpayment.sql` 
sos=`fun dp_myshow__s_ordersalesplansnapshot.sql`
dp=`fun dim_myshow_performance.sql`
fp=`fun detail_flow_pv_wide_report.sql`

file="yysc04"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    sp.dt,
    sp.city_name,
    performance_name,
    pv,
    uv,
    Order_num,
    TotalPrice,
    GrossProfit
from
    (select
    substr(ssp.PayTime,1,10) dt,
    dp.city_name,
    dp.performance_id,
    dp.performance_name,
    count(distinct ssp.OrderID) Order_num,
    sum(TotalPrice) TotalPrice,
    sum(GrossProfit) GrossProfit
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
    on sos.performance_id=dp.performance_id
group by
    1,2,3,4) sp
left join 
(select
    dt,
    performance_id,
    count(1) pv,
    count(distinct union_id) uv
from
    (
    $fp
    ) fp
where
    performance_id is not null
group by
    1,2) vp
    on sp.performance_id=vp.performance_id
    and sp.dt=vp.dt
$lim">${attach}

echo "
select
    sp.dt,
    sp.city_name,
    sp.category_name,
    pv,
    uv,
    Order_num,
    TotalPrice,
    GrossProfit
from
    (select
    substr(ssp.PayTime,1,10) dt,
    dp.city_id,
    dp.city_name,
    dp.category_id,
    dp.category_name,
    count(distinct ssp.OrderID) Order_num,
    sum(TotalPrice) TotalPrice,
    sum(GrossProfit) GrossProfit
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
    on sos.performance_id=dp.performance_id
group by
    1,2,3,4,5) sp
left join 
(select
    dt,
    dp.city_id,
    dp.category_id,
    count(1) pv,
    count(distinct union_id) uv
from
    (
    $fp
    ) fp
    join
    (
    $dp
    ) dp
    on fp.performance_id=dp.performance_id 
    and fp.performance_id is not null
group by
    1,2,3) vp
    on sp.city_id=vp.city_id
    and sp.dt=vp.dt
    and sp.category_id=vp.category_id
$lim">>${attach}
echo "succuess,detail see ${attach}"
