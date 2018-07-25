#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api1.0*******************
# 优化输出方式,优化函数处理
path="/Users/fannian/Documents/my_code/"
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

so=`fun detail_myshow_saleorder.sql t`
md=`fun myshow_dictionary.sql`
ogi=`fun dp_myshow__s_ordergift.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    dt,
    value1,
    case when ogi.order_id is null then '非赠票'
    else '赠票' end as gift_flag,
    sum(totalprice) as totalprice,
    count(distinct so.order_id) as order_num,
    sum(ticket_num) ticket_num
from (
    $so
    and sellchannel in (9,10)
    ) so
    left join (
    $ogi
    ) ogi
    on so.order_id=ogi.order_id
    left join (
    $md
    and key_name='sellchannel'
    ) md
    on md.key=so.sellchannel
group by
    1,2,3
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
