#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

so=`fun dp_myshow__s_order.sql`
sos=`fun dp_myshow__s_ordersalesplansnapshot.sql`
dmp=`fun dim_myshow_performance.sql`
dc=`fun dim_myshow_customer.sql`

file="bd07"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(so.PaidTime,1,7) mt,
    dc.customer_type_name,
    dmp.category_name,
    dmp.area_1_level_name,
    dmp.area_2_level_name,
    dmp.province_name,
    sum(TotalPrice) TotalPrice
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
    $dmp
    ) dmp
    on sos.performance_id=dmp.performance_id
    join 
    (
    $dc
    ) dc
    on so.TPID=dc.customer_id
group by
    1,2,3,4,5,6
$lim">${attach}

echo "succuess,detail see ${attach}"

