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
sod=`fun dp_myshow__s_orderdelivery`
sc=`fun dp_myshow__s_customer`
sp=`fun dp_myshow__s_performance`
bam=`fun dp_myshow__bs_activitymap`
md=`fun detail_flow_pv_wide_report`
ssp=`fun S_SettlementPayment`
scu=`fun S_Customer`
file="bs02"
attach="${path}doc/${file}.sql"
lim=";"

echo "select
    substr(so.PaidTime,1,10) dt,
    case when so.tp_type='渠道' then sc.ShortName
    else so.tp_type end tp_type,
    count(distinct so.OrderID) Order_num,
    count(distinct so.MTUserID) user_num,
    sum(so.SalesPlanCount) sp_num,
    sum(so.SalesPlanCount*sos.SetNum) st_num,
    sum(so.TotalPrice) TotalPrice,
    sum(sod.ExpressFee) ExpressFee,
    sum(so.SalesPlanCount*so.SalesPlanSupplyPrice) SupplyPrice
from
    (
    $sos
    ) sos 
    join (
    $so
    ) so
    on sos.orderid=so.orderid
    left join (
    $sc
    ) sc
    on sc.TPID=so.TPID
    left join (
    $sod
    ) sod on sod.orderid=so.orderid
group by
    1,2
$lim">${attach}
#substr(ssp.PaidTime,1,10) dt,
echo "
select
    case when ssp.tp_type='渠道' then scu.ShortName
    else ssp.tp_type end tp_type,
    sum(GrossProfit) GrossProfit
from
    (
    $ssp
    ) ssp
    left join 
    (
    $scu
    ) scu 
    on ssp.TPID=scu.TPID
group by
    1
$lim">>${attach}
