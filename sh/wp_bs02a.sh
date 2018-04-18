#!/bin/bash
path="/Users/fannian/Documents/my_code/"
clock="00"
t1=${1:-`date -v -1d +"%Y-%m-%d ${clock}:00:00"`}
t2=${2:-`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) + 86400) +"%Y-%m-%d ${clock}:00:00"`}
t3=`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) - 86400) +"%Y-%m-%d ${clock}:00:00"`
fut() {
echo `grep -iv "\-time" ${path}sql/${1} | grep -iv "/\*"`
}

file="wp_bs02"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    from_unixtime(create_time/1000,'%Y-%m-%d') dt,
    item_id,
    order_id,
    order_src,
    passport_user_mobile as mobile,
    receive_delivery_mobile as receive_mobile,
    payment_bill_id pay_no,
    (total_money/100) as total_money
from
    report_order_sum
where
    create_time<=1523813755795
$lim">${attach}
echo "succuess,detail see ${attach}"
