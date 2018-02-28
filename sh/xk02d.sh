#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql` 
per=`fun dim_myshow_performance.sql`

file="xk02"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    spo.dt,
    category_name,
    count(distinct spo.order_id) as order_num,
    sum(spo.salesplan_count*spo.setnumber) as ticket_num,
    sum(spo.totalprice) as totalprice,
    sum(spo.grossprofit) as grossprofit
from (
    $spo
    and sellchannel=8
    ) spo
   left join (
   $per
   ) per
   on spo.performance_id=per.performance_id
group by
    1,2
$lim">${attach}

echo "succuess,detail see ${attach}"
