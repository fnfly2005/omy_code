#!/bin/bash
clock="00"
t1=${1:-`date -v -1d +"%Y-%m-%d ${clock}:00:00"`}
t2=${2:-`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) + 86400) +"%Y-%m-%d ${clock}:00:00"`}
t3=`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) - 86400) +"%Y-%m-%d ${clock}:00:00"`
path="/Users/fannian/Documents/my_code/"
fun() {
echo `cat ${path}sql/${1}.sql | sed "s/-time1/${2:-${t1% *}}/g;
s/-time2/${3:-${t2% *}}/g;s/-time3/${4:-${t3% *}}/g"`
}
so=`fun dp_myshow__s_order`
sos=`fun dp_myshow__s_ordersalesplansnapshot`
sod=`fun dp_myshow__s_orderdelivery`
bam=`fun dp_myshow__bs_activitymap`
sc=`fun dp_myshow__s_customer`
sp=`fun dp_myshow__s_performance`
md=`fun detail_flow_pv_wide_report`
file="bs01"
attach="${path}doc/${file}.sql"

echo "select
    substr(so.PaidTime,1,10) dt,
    sp.PerformanceID,
    sos.PerformanceName,
    bam.TPSProjectID,
    so.TPID,
    so.tp_type,
    sc.Name,
    count(distinct so.OrderID) Order_num,
    count(distinct so.MTUserID) user_num,
    count(distinct 
        case when so.RefundStatus='已退款' 
        then so.MTUserID end) re_user_num,
    sum(so.SalesPlanCount) sp_num,
    sum(so.TotalPrice) TotalPrice,
    sum(case when so.RefundStatus='已退款' 
        then so.TotalPrice end) re_TotalPrice,
    sum(sod.ExpressFee) ExpressFee,
    sum(so.SalesPlanCount*so.SalesPlanSupplyPrice) SupplyPrice
from
    (
    $sp
    and PerformanceID=$3
    ) sp 
    join (
    $sos
    and PerformanceID=$3
    ) sos 
    on sp.PerformanceID=sos.PerformanceID
    join (
    $so
    ) so
    on sos.orderid=so.orderid
    left join (
    $sc
    ) sc
    on sc.TPID=so.TPID
    left join (
    $bam
    ) bam
    on bam.TPID=so.TPID and bam.ActivityID=sp.bsperformanceid
    left join (
    $sod
    ) sod on sod.orderid=so.orderid
group by
    1,2,3,4,5,6,7;">${attach}

echo "select
    partition_date,
    count(distinct union_id) uv
from
    (
    $md
    and page_id=40000390
    and custom['performance_id']=$3
    ) md
group by
    1">>${attach}
