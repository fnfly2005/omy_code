#!/bin/bash
path="/Users/fannian/Documents/my_code/"
fun() {
echo `cat ${path}sql/${1} | sed "s/-time1/${2}/g;
s/-time2/${3}/g;s/-time3/${4}/g"`
}
so=`fun S_Order.sql ${1} ${2}`
sos=`fun S_OrderSalesPlanSnapshot.sql ${1} ${2}`
sod=`fun S_OrderDelivery.sql ${1} ${2}`

file="bs19"
attach="${path}doc/${file}.sql"
lim=";"

echo "
select
    CityName,
    count(distinct so.OrderID) Order_num,
    sum(so.TotalPrice) TotalPrice
from (
    $sos
    and PerformanceID=${3}
    ) sos
    join ( 
    $so
    ) so
    using(OrderID)
    join (
    $sod
    ) sod
    on sod.OrderID=sos.OrderID
group by
    1
$lim
">${attach}
