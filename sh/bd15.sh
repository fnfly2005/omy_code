#!/bin/bash
#2.0 2018-08-14
source ./fuc.sh
so=`fun detail_myshow_saleorder.sql`
soi=`fun dp_myshow__s_orderidentification.sql u`
md=`fun myshow_dictionary.sql`

file="bd15"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    so.order_id,
    maoyan_order_id,
    name_id,
    mobile,
    so.performance_id,
    order_create_time,
    pay_time,
    value2,
    show_name,
    show_id,
    ticket_price,
    salesplan_name,
    detailedaddress,
    ticket_num,
    totalprice
from (
    $so
        and performance_id in (\$performance_id)
    ) so
    left join (
        select
            PerformanceID as performance_id,
            OrderID as order_id,
            map_agg(UserName,IDNumber) as name_id
        $soi
            and performanceid in (\$performance_id)
        group by
            1,2
        ) soi
    using(order_id)
    left join (
    $md
    and key_name='order_refund_status'
    ) md
    on md.key=so.order_refund_status
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
