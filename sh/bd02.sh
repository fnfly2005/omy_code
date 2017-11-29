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
sd=`fun dp_myshow__s_dpcitylist`
sc=`fun dp_myshow__s_category`
sp=`fun dp_myshow__s_performance`
bam=`fun dp_myshow__bs_activitymap`

file="bd02"
lim=";"
attach="${path}doc/${file}.sql"
cn="('北京','天津')"

echo "select
    substr(so.PaidTime,1,7) mt,
    sd.cityname,
    sc.Name,
    so.tp_type,
    count(distinct sos.PerformanceID) p_num,
    count(distinct so.OrderID) so_num,
    sum(so.TotalPrice) TotalPrice,
    sum(so.SalesPlanCount*sos.SetNum) tic_num
from
    (
    $sd
    and cityname in $cn
    ) sd
    join 
    (
    $sp
    ) sp on sd.cityid=sp.CityID
    left join
    (
    $sc
    ) sc on sp.CategoryID=sc.CategoryID
    join 
    (
    $sos
    ) sos on sos.PerformanceID=sp.PerformanceID
    join 
    (
    $so
    ) so on sos.OrderID=sos.OrderID
group by
    1,2,3,4
$lim">${attach}

echo "select
    substr(bam.CreateTime,1,7) mt,
    sd.cityname,
    sc.Name,
    bam.tp_type,
    count(distinct sp.PerformanceID) p_num,
from
    (
    $sd
    and cityname in $cn
    ) sd
    join 
    (
    $sp
    ) sp on sd.cityid=sp.CityID
    left join
    (
    $sc
    ) sc on sp.CategoryID=sc.CategoryID
    left join 
    (
    $bam
    ) bam on bam.ActivityID=sp.bsperformanceid
group by
    1,2,3,4
$lim">>${attach}
echo "succuess,detail see ${attach}"
