#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

so=`fun detail_myshow_saleorder.sql` 
soi=`fun dp_myshow__s_orderidentification.sql`
md=`fun myshow_dictionary.sql`

file="bd15"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    usermobileno,
    UserName,
    IDNumber,
    maoyan_order_id,
    order_create_time,
    value2
from (
    $so
    and performance_id=\$performance_id
    ) so
    left join (
    $soi
    and performanceid=\$performance_id
    ) soi
    using(order_id)
    left join (
    $md
    and key_name='order_refund_status'
    ) md
    on md.key=so.order_refund_status
group by
    1,2,3,4,5,6
$lim">${attach}

echo "succuess,detail see ${attach}"
