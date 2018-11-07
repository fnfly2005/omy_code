#!/bin/bash
#--------------------mysensitiveycsensitivereadme-------------------
#*************************api1.0*******************
# 优化输出方式,优化函数处理
path="$private_home/my_code/"
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
opa=`fun dp_myshow__s_orderpartner.sql`
par=`fun dp_myshow__s_partner.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    dt,
    partner_name,
    count(distinct so.order_id) as order_num,
    sum(totalprice) as totalprice,
    sum(ticket_num) ticket_num
from (
    $so
        and sellchannel=11
        ) so
    left join (
        $opa
        ) opa
    on so.order_id=opa.order_id
    left join (
        $par
        ) par
    on opa.partner_id=par.partner_id
group by
    1,2
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
