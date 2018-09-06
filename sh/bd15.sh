#!/bin/bash
#项目购票信息
source ./fuc.sh
so=`fun detail_myshow_saleorder.sql d`
soi=`fun dp_myshow__s_orderidentification.sql u`
md=`fun myshow_dictionary.sql`

file="bd15"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    so.order_id,
    maoyan_order_id,
    md2.value2 as pt,
    UserName,
    IDNumber,
    mobile,
    so.performance_id,
    order_create_time,
    pay_time,
    md.value2,
    show_name,
    show_id,
    ticket_price,
    salesplan_name,
    detailedaddress,
    ticket_num,
    totalprice
from (
    $so
    where
        pay_time is not null
        and ((pay_time>='\$\$begindate'
        and pay_time<'\$\$enddate')
        or 1=\$pay_flag)
        and performance_id in (\$performance_id)
    ) so
    left join (
        select distinct
            PerformanceID as performance_id,
            OrderID as order_id,
            UserName,
            IDNumber
        $soi
            and performanceid in (\$performance_id)
        ) soi
    using(order_id)
    left join (
        $md
        and key_name='order_refund_status'
        ) md
    on md.key=so.order_refund_status
    left join (
        $md
        and key_name='sellchannel'
        ) md2
    on md2.key=so.sellchannel
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
