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
sd=`fun dp_myshow__s_dpcitylist`
dp=`fun dim_province`
sc=`fun dp_myshow__s_category`
sp=`fun dp_myshow__s_performance`
bam=`fun dp_myshow__bs_activitymap`
scu=`fun dp_myshow__s_customer`
dmp=`fun detail_myshow_performance_performancesnapshotid`
ssp=`fun dp_myshow__s_settlementpayment`

file="bd03"
lim=";"
attach="${path}doc/${file}.sql"

echo "select
    substr(so.PaidTime,1,7) mt,
    dp.province_name,
    sc.Name,
    case when so.tp_type='渠道' then scu.ShortName
    else so.tp_type end tp_type,
    count(distinct sos.PerformanceID) p_num,
    count(distinct so.OrderID) so_num,
    sum(so.TotalPrice) TotalPrice,
    sum(so.SalesPlanCount*sos.SetNum) tic_num,
    sum(ssp.GrossProfit) GrossProfit
from
    (
    $so
    ) so 
    join 
    (
    $sos
    ) sos 
    on so.OrderID=sos.OrderID
    join 
    (
    $ssp
    ) ssp
    on so.OrderID=ssp.OrderID
    left join 
    (
    $sp
    ) sp 
    on sos.PerformanceID=sp.PerformanceID
    join 
    (
    $scu
    ) scu on scu.TPID=so.TPID
    left join
    (
    $sc
    ) sc on sp.CategoryID=sc.CategoryID
    left join 
    (
    $sd
    ) sd
    on sd.cityid=sp.CityID
    left join 
    (
    $dp
    ) dp on dp.province_id=sd.ProvinceID
group by
    1,2,3,4
$lim">${attach}

echo "/*在线项目数*/
select
    dp.province_name,
    sc.Name,
    case when bam.tp_type='渠道' then scu.ShortName
    else bam.tp_type end tp_type,
    count(distinct case when sp.BSPerformanceID is not null then sp.BSPerformanceID else sp.PerformanceID end) a_p_num
from
    (
    $sp
    and TicketStatus in (2,3)
    and EditStatus=1
    ) sp 
    left join
    (
    $bam
    ) bam on sp.BSPerformanceID=bam.ActivityID
    left join 
    (
    $sc
    ) sc on sp.CategoryID=sc.CategoryID
    left join 
    (
    $sd
    ) sd
    on sd.cityid=sp.CityID
    left join 
    (
    $dp
    ) dp on dp.province_id=sd.ProvinceID
    left join 
    (
    $scu
    ) scu on scu.TPID=bam.TPID
group by
    1,2,3
$lim">>${attach}

echo "succuess,detail see ${attach}"
