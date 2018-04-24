#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

per=`fun dim_myshow_performance.sql`
psr=`fun dp_myshow__s_performancesaleremind.sql` 
md=`fun myshow_dictionary.sql`
file="bs25"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(pay_time,1,10) as dt,
    count(distinct order_id) order_num,
    sum(totalprice) totalprice,
    count(distinct case when phonenumber is not null
        then order_id end) sm_order_num,
    sum(case when phonenumber is not null
        then totalprice end) sm_totalprice
from (
    select
        PerformanceID
    from
        origindb.dp_myshow__s_performancesaleremind
    where
        Status=1
        and NeedRemind=1
    group by
        1
        ) sps
    join mart_movie.detail_myshow_saleorder so
    on so.performance_id=sps.performanceid
    and so.sellchannel not in (8,9,10,11)
    and pay_time is not null
    and pay_time>='\$\$begindate'
    and pay_time<'\$\$enddate'
    left join origindb.dp_myshow__s_messagepush sm
    on so.performance_id=sm.performanceid
    and so.usermobileno=sm.phonenumber
group by
    1
$lim">${attach}

echo "succuess,detail see ${attach}"
