#!/bin/bash
path="/Users/fannian/Documents/my_code/"
fun() {
echo `cat ${path}sql/${1} | sed "s/-time1/${2}/g;
s/-time2/${3}/g;s/-time3/${4}/g"`
}
so=`fun S_Order.sql ${1} ${2}`
soi=`fun S_OrderIdentification.sql ${1} ${2}`

file="bs20"
attach="${path}doc/${file}.sql"
lim=";"

echo "
select
    UserName,
    IDType,
    IDNumber
from (
    $soi
    and PerformanceID=${3}
    ) soi
    join ( 
    $so
    and RefundStatus<>5
    ) so
    using(OrderID)
group by
    1,2,3
$lim
">${attach}
