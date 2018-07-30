#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api2.0*******************
#实时订单导入，实时数据
path="/Users/fannian/Documents/my_code/"
fun() {
    if [ $2x == dx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '/where/,$'d`
    elif [ $2x == ux ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '1,/from/'d | sed '1s/^/from/'`
    elif [ $2x == tx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/-time1/$3/g;s/-time2/$4/g"`
    elif [ $2x == utx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/-time1/$3/g;s/-time2/$4/g" | sed '1,/from/'d | sed '1s/^/from/'`
    else
        echo `cat ${path}sql/${1} | grep -iv "/\*"`
    fi
}
beg_key=2951001

so=`fun S_Order.sql t $beg_key`
sos=`fun S_OrderSalesPlanSnapshot.sql t $beg_key`

file="ss_bs02"
attach="${path}doc/${file}.sql"
lim="limit 20000;"

echo "
select so.order_id,
sellchannel,
dianping_userid,
meituan_userid,
usermobileno,
city_id,
salesplan_id,
supply_price,
sell_price,
salesplan_count,
totalprice,
maoyan_order_id,
customer_id,
order_reserve_status,
order_deliver_status,
order_refund_status,
order_create_time,
pay_time,
ticketed_time,
totalticketprice,
performance_id,
performance_name,
shop_name,
ticketclass_id,
ticketclass_description,
show_id,
show_name,
show_starttime,
salesplan_name,
setnumber,
ticket_price
from ($so) as so
join ($sos) as sos
on so.order_id=sos.order_id
$lim
">${attach}
$sos

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
