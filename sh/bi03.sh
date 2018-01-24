#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

dp=`fun dim_myshow_performance.sql`
spo=`fun detail_myshow_salepayorder.sql`
file="bs03"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    meituan_userid,
    dianping_userid,
    coalesce(category_id,-99) category_id,
    first_pay_order_date,
    last_pay_order_date,
    pay_dt_num
from
(select
    meituan_userid,
    dianping_userid,
    category_id,
    min(dt) as first_pay_order_date,
    max(dt) as last_pay_order_date, 
    count(distinct dt) as pay_dt_num,
    min(case when sellchannel in 1,
from
(
select
    meituan_userid,
    dianping_userid,
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
group by
    meituan_userid,
    dianping_userid,
    category_id
grouping sets(
(meituan_userid,dianping_userid),
(meituan_userid,dianping_userid,category_id)
)
) as s2
$lim">${attach}

echo "succuess,detail see ${attach}"

