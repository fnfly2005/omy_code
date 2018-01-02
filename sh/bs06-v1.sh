#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql`
md=`fun my_dictionary.sql`

file="bs06"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(partition_date,1,7) mt,
    value2,
    0 as sp_num,
    count(distinct order_id) as order_num,
    sum(TotalPrice) as gmv
from
    (
    $spo
    ) as spo
    left join 
    (
    $md
    and key_name='sellchannel'
    ) as md
    on spo.sellchannel=md.key
group by
    1,2
union all
select
    substr(partition_date,1,7) mt,
    '全部' as value2,
    count(distinct performance_id) as sp_num,
    count(distinct order_id) as order_num,
    sum(TotalPrice) as gmv
from
    (
    $spo
    ) as spo
    left join 
    (
    $md
    and key_name='sellchannel'
    ) as md
    on spo.sellchannel=md.key
group by
    1,2 
$lim">${attach}

echo "succuess,detail see ${attach}"
