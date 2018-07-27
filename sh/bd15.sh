#!/bin/bash
#实时数据详见bs20a.sh
#--------------------猫眼演出readme-------------------
#*************************api1.0*******************
# 优化输出方式,优化函数处理
path=""
fun() {
    if [ $2x == dx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '/where/,$'d`
    elif [ $2x == ux ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '1,/from/'d | sed '1s/^/from/'`
    elif [ $2x == tx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g"`
    elif [ $2x == utx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g" | sed '1,/from/'d | sed '1s/^/from/'`
    else
        echo `cat ${path}sql/${1} | grep -iv "/\*"`
    fi
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
    ticket_price,
    salesplan_name,
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
