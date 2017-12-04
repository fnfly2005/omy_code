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
so=`fun S_Order` 
sod=`fun S_OrderDelivery`
sc=`fun S_Category`
sp=`fun S_Performance`
sos=`fun S_OrderSalesPlanSnapshot`

file="yh01a"
attach="${path}doc/${file}.sql"
echo "
select
    sc.Name,
    count(1),
    count(case when so.TotalPrice-sod.ExpressFee-sos.SalesPlanTicketPrice*SalesPlanCount<0
    then 1 end)
from
    (
    $so
    ) so
   join (
    $sod
    ) sod using(OrderID)
    join (
    $sos
    ) sos on so.OrderID=sos.OrderID
    left join (
    $sp
    ) sp on sp.PerformanceID=sos.PerformanceID
    left join (
    $sc
    ) sc on sc.CategoryID=sp.CategoryID
group by
    1
limit 100
"|tee ${attach}

file="yh01b"
attach="${path}doc/${file}.sql"
echo "
select
    sc.Name,
    sum(sos.SalesPlanTicketPrice*SalesPlanCount-(so.TotalPrice-sod.ExpressFee)) discount,
    sum(so.TotalPrice) TotalPrice
from
    (
    $so
    ) so
   join (
    $sod
    ) sod using(OrderID)
    join (
    $sos
    ) sos on so.OrderID=sos.OrderID
    left join (
    $sp
    ) sp on sp.PerformanceID=sos.PerformanceID
    left join (
    $sc
    ) sc on sc.CategoryID=sp.CategoryID
where
    so.TotalPrice-sod.ExpressFee-sos.SalesPlanTicketPrice*SalesPlanCount<0
group by
    1
limit 100
"|tee ${attach}
