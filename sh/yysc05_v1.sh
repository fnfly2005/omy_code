#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

so=`fun detail_myshow_saleorder.sql`
dp=`fun dim_myshow_performance.sql`
dic=`fun my_dictionary.sql`
file="yysc05"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
mt,
coalesce(value2,'全部') as sellchannel,
coalesce(category_name,'全部') as category_name,
user_num,
order_num,
totalprice
from
(select
    substr(so.pay_time,1,7) as mt,
    dic.value2,
    dp.category_name,
    count(distinct so.meituan_userid) as user_num,
    count(distinct so.order_id) as order_num,
    sum(so.totalprice) as totalprice
from
    (
    $so
    ) as so
    join 
    (
    $dp
    ) as dp
    on so.performance_id=dp.performance_id
    left join
    (
    $dic
    and key_name='sellchannel'
    ) as dic
    on dic.key=so.sellchannel
group by
    substr(so.pay_time,1,7),
    dic.value2,
    dp.category_name
grouping sets
    (
    (substr(so.pay_time,1,7),
    dic.value2,
    dp.category_name),
    substr(so.pay_time,1,7)
    )) as test
$lim">${attach}

echo "succuess,detail see ${attach}"
