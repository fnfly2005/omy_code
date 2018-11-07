#!/bin/bash
path="$private_home/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

dic=`fun myshow_dictionary.sql`
spo=`fun detail_myshow_salepayorder.sql`
file="bi03"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    mtsensitive_userid,
    dpsensitive_userid,
    value3,
    coalesce(category_id,-99) category_id,
    first_pay_order_date,
    last_pay_order_date,
    pay_dt_num
from
(select
    mtsensitive_userid,
    dpsensitive_userid,
    value3,
    category_id,
    min(dt) as first_pay_order_date,
    max(dt) as last_pay_order_date, 
    count(distinct dt) as pay_dt_num
from
(
select
    mtsensitive_userid,
    dpsensitive_userid,
    sellchannel,
    case when category_id is null then 8
    when category_id=0 then 8
    else category_id end as category_id,
    partition_date as dt
from
    mart_movie.detail_myshow_salepayorder
where
    partition_date>='2017-10-01'
    ) as s1
    join 
    (
    $dic
    and key_name='sellchannel'
    ) as dic
    on s1.sellchannel=dic.key
group by
    mtsensitive_userid,
    dpsensitive_userid,
    value3,
    category_id
grouping sets(
(mtsensitive_userid,dpsensitive_userid,value3),
(mtsensitive_userid,dpsensitive_userid,value3,category_id)
)
) as s2
$lim">${attach}

echo "succuess,detail see ${attach}"
