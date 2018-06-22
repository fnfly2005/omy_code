#!/bin/bash
#实时数据详见bs20a.sh
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
select distinct
    so.order_id,
    maoyan_order_id,
    IDNumber,
    UserName,
    mobile,
    so.performance_id,
    order_create_time,
    value2,
    show_name,
    show_id,
    ticketclass_description,
    detailedaddress,
    TicketNumber
from (
    $so
    and performance_id in (\$performance_id)
    ) so
    left join (
    $soi
    and performanceid in (\$performance_id)
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
