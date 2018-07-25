#!/bin/bash
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

so=`fun detail_myshow_saleorder.sql t`
md=`fun myshow_dictionary.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(pay_time,1,10) dt,
    'y' as type,
    '团购' as lv1_type,
    sum(purchase_price) as totalprice,
    count(distinct order_id) as order_num,
    sum(quantity) as ticket_num
from
    mart_movie.detail_maoyan_order_sale_cost_new_info
where
    pay_time is not null
    and pay_time>='\$\$today{-1d}'
    and pay_time<'\$\$today{-0d}'
    and deal_id in (
        select
            mydealid
        from
            origindb.dp_myshow__s_deal
            )
group by
    1,2,3
union all
select
    dt,
    key1 as type,
    value4 as lv1_type,
    sum(totalprice) as totalprice,
    count(distinct order_id) as order_num,
    sum(ticket_num) as ticket_num
from (
    $so
    ) so
    left join (
        $md
        and key_name='sellchannel'
        ) md
    on so.sellchannel=md.key
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
