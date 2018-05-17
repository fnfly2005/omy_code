#!/bin/bash
#历史数据详见bd15.sh
path="/Users/fannian/Documents/my_code/"
fun() {
echo `cat ${path}sql/${1} | sed "s/-time1/${2}/g;
s/-time2/${3}/g;s/-time3/${4}/g"`
}
so=`fun S_Order.sql ${3}`
soi=`fun S_OrderIdentification.sql ${3}`

file="ss_bs01"
attach="${path}doc/${file}.sql"
lim="limit 10000;"


echo "
select distinct
    MYOrderID,
    IDNumber,
    UserName,
    UserMobileNo,
    PerformanceID,
    CreateTime,
    RefundStatus
from (
    $soi
    and PerformanceID in (${2})
    ) soi
    join ( 
    $so
    and RefundStatus<>5
    ) so
    using(OrderID)
$lim
">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
